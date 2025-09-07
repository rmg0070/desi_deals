-- Location: supabase/migrations/20250907055036_restaurant_discovery_system.sql
-- Schema Analysis: No existing schema detected - fresh project
-- Integration Type: Complete restaurant discovery system creation
-- Dependencies: PostGIS extension for location services

-- 1. Extensions and Types
CREATE TYPE public.deal_type AS ENUM ('PERCENT_OFF', 'AMOUNT_OFF', 'BOGO', 'FIXED_PRICE');
CREATE TYPE public.day_of_week AS ENUM ('SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY');
CREATE TYPE public.user_role AS ENUM ('customer', 'restaurant_admin', 'super_admin');

-- 2. Core Tables - User Management
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role DEFAULT 'customer'::public.user_role,
    current_lat DOUBLE PRECISION,
    current_lon DOUBLE PRECISION,
    street TEXT,
    city TEXT,
    zip_code TEXT,
    cuisine_filter TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Restaurant Core Tables
CREATE TABLE public.restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    phone TEXT,
    email TEXT,
    website_url TEXT,
    maps_url TEXT,
    image_url TEXT,
    average_rating DECIMAL(2,1) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    price_range INTEGER DEFAULT 1 CHECK (price_range BETWEEN 1 AND 4),
    cuisine_type TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.restaurant_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    is_primary BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.restaurant_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Menu System
CREATE TABLE public.menus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT 'Main Menu',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.menu_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_id UUID REFERENCES public.menus(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.menu_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price_cents INTEGER NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    is_popular BOOLEAN DEFAULT false,
    allergens TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Deals System
CREATE TABLE public.deals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    deal_type public.deal_type NOT NULL,
    discount_value DECIMAL(10,2),
    minimum_order_cents INTEGER DEFAULT 0,
    maximum_discount_cents INTEGER,
    is_active BOOLEAN DEFAULT true,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.deal_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id UUID REFERENCES public.deals(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Buffet System
CREATE TABLE public.buffet_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    adult_price_cents INTEGER NOT NULL,
    child_price_cents INTEGER,
    senior_price_cents INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.buffet_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buffet_id UUID REFERENCES public.buffet_details(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Admin Management
CREATE TABLE public.restaurant_admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'admin',
    granted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, restaurant_id)
);

-- 8. Essential Indexes for Performance
CREATE INDEX idx_users_location ON public.users(current_lat, current_lon) WHERE current_lat IS NOT NULL;
CREATE INDEX idx_restaurant_locations_coords ON public.restaurant_locations(latitude, longitude);
CREATE INDEX idx_restaurants_cuisine ON public.restaurants USING GIN(cuisine_type);
CREATE INDEX idx_restaurant_hours_day ON public.restaurant_hours(restaurant_id, day_of_week);
CREATE INDEX idx_deals_restaurant_active ON public.deals(restaurant_id, is_active);
CREATE INDEX idx_deal_schedules_day_time ON public.deal_schedules(day_of_week, start_time, end_time);
CREATE INDEX idx_buffet_schedules_day ON public.buffet_schedules(day_of_week);
CREATE INDEX idx_menu_items_category ON public.menu_items(category_id, is_available);
CREATE INDEX idx_restaurant_admins_user ON public.restaurant_admins(user_id);

-- 9. RPC Functions for Core Functionality
CREATE OR REPLACE FUNCTION api_nearby_restaurants(u_lat DOUBLE PRECISION, u_lon DOUBLE PRECISION, radius_m INTEGER DEFAULT 10000)
RETURNS TABLE(
    restaurant_id UUID,
    name TEXT,
    description TEXT,
    phone TEXT,
    image_url TEXT,
    average_rating DECIMAL(2,1),
    total_reviews INTEGER,
    price_range INTEGER,
    cuisine_type TEXT[],
    address TEXT,
    city TEXT,
    distance_meters DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        r.id as restaurant_id,
        r.name,
        r.description,
        r.phone,
        r.image_url,
        r.average_rating,
        r.total_reviews,
        r.price_range,
        r.cuisine_type,
        rl.address,
        rl.city,
        ST_Distance(
            ST_SetSRID(ST_MakePoint(u_lon, u_lat), 4326),
            ST_SetSRID(ST_MakePoint(rl.longitude, rl.latitude), 4326)
        ) * 111320 as distance_meters
    FROM public.restaurants r
    JOIN public.restaurant_locations rl ON r.id = rl.restaurant_id
    WHERE ST_DWithin(
        ST_SetSRID(ST_MakePoint(u_lon, u_lat), 4326),
        ST_SetSRID(ST_MakePoint(rl.longitude, rl.latitude), 4326),
        radius_m / 111320.0
    )
    AND rl.is_primary = true
    ORDER BY distance_meters ASC;
$$;

CREATE OR REPLACE FUNCTION api_deals_now(rid UUID)
RETURNS TABLE(
    deal_id UUID,
    title TEXT,
    description TEXT,
    deal_type TEXT,
    discount_value DECIMAL(10,2),
    minimum_order_cents INTEGER,
    maximum_discount_cents INTEGER
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        d.id as deal_id,
        d.title,
        d.description,
        d.deal_type::TEXT,
        d.discount_value,
        d.minimum_order_cents,
        d.maximum_discount_cents
    FROM public.deals d
    JOIN public.deal_schedules ds ON d.id = ds.deal_id
    WHERE d.restaurant_id = rid
    AND d.is_active = true
    AND (d.start_date IS NULL OR d.start_date <= CURRENT_DATE)
    AND (d.end_date IS NULL OR d.end_date >= CURRENT_DATE)
    AND ds.day_of_week = EXTRACT(DOW FROM CURRENT_TIMESTAMP)::INTEGER
    AND CURRENT_TIME BETWEEN ds.start_time AND ds.end_time;
$$;

CREATE OR REPLACE FUNCTION api_buffet_today(rid UUID)
RETURNS TABLE(
    buffet_id UUID,
    title TEXT,
    description TEXT,
    adult_price_cents INTEGER,
    child_price_cents INTEGER,
    senior_price_cents INTEGER,
    start_time TIME,
    end_time TIME
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        bd.id as buffet_id,
        bd.title,
        bd.description,
        bd.adult_price_cents,
        bd.child_price_cents,
        bd.senior_price_cents,
        bs.start_time,
        bs.end_time
    FROM public.buffet_details bd
    JOIN public.buffet_schedules bs ON bd.id = bs.buffet_id
    WHERE bd.restaurant_id = rid
    AND bd.is_active = true
    AND bs.day_of_week = EXTRACT(DOW FROM CURRENT_TIMESTAMP)::INTEGER;
$$;

-- 10. RLS Setup
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurant_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurant_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menus ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buffet_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buffet_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurant_admins ENABLE ROW LEVEL SECURITY;

-- 11. RLS Policies - Pattern 1: Core User Table
CREATE POLICY "users_manage_own_profiles"
ON public.users
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public Read, Private Write for restaurant data
CREATE POLICY "public_can_read_restaurants"
ON public.restaurants
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_restaurant_locations"
ON public.restaurant_locations
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_restaurant_hours"
ON public.restaurant_hours
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_menus"
ON public.menus
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_menu_categories"
ON public.menu_categories
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_menu_items"
ON public.menu_items
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_deals"
ON public.deals
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_deal_schedules"
ON public.deal_schedules
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_buffet_details"
ON public.buffet_details
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_can_read_buffet_schedules"
ON public.buffet_schedules
FOR SELECT
TO public
USING (true);

-- Admin access policies for restaurant management
CREATE OR REPLACE FUNCTION public.user_manages_restaurant(restaurant_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.restaurant_admins ra
    WHERE ra.user_id = auth.uid() AND ra.restaurant_id = restaurant_uuid
);
$$;

CREATE POLICY "admins_manage_restaurants"
ON public.restaurants
FOR ALL
TO authenticated
USING (public.user_manages_restaurant(id))
WITH CHECK (public.user_manages_restaurant(id));

CREATE POLICY "admins_manage_restaurant_locations"
ON public.restaurant_locations
FOR ALL
TO authenticated
USING (public.user_manages_restaurant(restaurant_id))
WITH CHECK (public.user_manages_restaurant(restaurant_id));

CREATE POLICY "admins_manage_restaurant_hours"
ON public.restaurant_hours
FOR ALL
TO authenticated
USING (public.user_manages_restaurant(restaurant_id))
WITH CHECK (public.user_manages_restaurant(restaurant_id));

CREATE POLICY "admins_manage_menus"
ON public.menus
FOR ALL
TO authenticated
USING (public.user_manages_restaurant(restaurant_id))
WITH CHECK (public.user_manages_restaurant(restaurant_id));

CREATE POLICY "admins_manage_menu_categories"
ON public.menu_categories
FOR ALL
TO authenticated
USING (
    public.user_manages_restaurant((SELECT restaurant_id FROM public.menus WHERE id = menu_id))
)
WITH CHECK (
    public.user_manages_restaurant((SELECT restaurant_id FROM public.menus WHERE id = menu_id))
);

CREATE POLICY "admins_manage_menu_items"
ON public.menu_items
FOR ALL
TO authenticated
USING (
    public.user_manages_restaurant((SELECT m.restaurant_id FROM public.menus m JOIN public.menu_categories mc ON m.id = mc.menu_id WHERE mc.id = category_id))
)
WITH CHECK (
    public.user_manages_restaurant((SELECT m.restaurant_id FROM public.menus m JOIN public.menu_categories mc ON m.id = mc.menu_id WHERE mc.id = category_id))
);

CREATE POLICY "admins_manage_deals"
ON public.deals
FOR ALL
TO authenticated
USING (public.user_manages_restaurant(restaurant_id))
WITH CHECK (public.user_manages_restaurant(restaurant_id));

CREATE POLICY "admins_manage_deal_schedules"
ON public.deal_schedules
FOR ALL
TO authenticated
USING (
    public.user_manages_restaurant((SELECT restaurant_id FROM public.deals WHERE id = deal_id))
)
WITH CHECK (
    public.user_manages_restaurant((SELECT restaurant_id FROM public.deals WHERE id = deal_id))
);

CREATE POLICY "admins_manage_buffet_details"
ON public.buffet_details
FOR ALL
TO authenticated
USING (public.user_manages_restaurant(restaurant_id))
WITH CHECK (public.user_manages_restaurant(restaurant_id));

CREATE POLICY "admins_manage_buffet_schedules"
ON public.buffet_schedules
FOR ALL
TO authenticated
USING (
    public.user_manages_restaurant((SELECT restaurant_id FROM public.buffet_details WHERE id = buffet_id))
)
WITH CHECK (
    public.user_manages_restaurant((SELECT restaurant_id FROM public.buffet_details WHERE id = buffet_id))
);

CREATE POLICY "users_view_restaurant_admins"
ON public.restaurant_admins
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- 12. Triggers for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')::public.user_role
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 13. Mock Data for Testing
DO $$
DECLARE
    user1_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    admin_id UUID := gen_random_uuid();
    rest1_id UUID := gen_random_uuid();
    rest2_id UUID := gen_random_uuid();
    rest3_id UUID := gen_random_uuid();
    menu1_id UUID := gen_random_uuid();
    menu2_id UUID := gen_random_uuid();
    cat1_id UUID := gen_random_uuid();
    cat2_id UUID := gen_random_uuid();
    deal1_id UUID := gen_random_uuid();
    buffet1_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (user1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'customer@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Customer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jane@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Smith"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@restaurant.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Restaurant Admin", "role": "restaurant_admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update user profiles with location data
    UPDATE public.users SET 
        current_lat = 40.7128,
        current_lon = -74.0060,
        street = '123 Main St',
        city = 'New York',
        zip_code = '10001',
        cuisine_filter = ARRAY['Indian', 'Italian', 'Chinese']
    WHERE id = user1_id;

    -- Create restaurants
    INSERT INTO public.restaurants (id, name, description, phone, website_url, image_url, average_rating, total_reviews, price_range, cuisine_type)
    VALUES
        (rest1_id, 'Spice Palace', 'Authentic Indian cuisine with traditional flavors', '(555) 123-4567', 'https://spicepalace.com', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641', 4.5, 156, 2, ARRAY['Indian', 'Vegetarian']),
        (rest2_id, 'Mama Mia Italian', 'Family-owned Italian restaurant since 1985', '(555) 234-5678', 'https://mamamia.com', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5', 4.2, 89, 3, ARRAY['Italian', 'Pizza']),
        (rest3_id, 'Dragon Garden', 'Modern Chinese dining with traditional recipes', '(555) 345-6789', 'https://dragongarden.com', 'https://images.unsplash.com/photo-1563379091339-03246963d96c', 4.7, 203, 2, ARRAY['Chinese', 'Asian']);

    -- Create restaurant locations
    INSERT INTO public.restaurant_locations (restaurant_id, address, city, state, zip_code, latitude, longitude, is_primary)
    VALUES
        (rest1_id, '456 Curry Lane', 'New York', 'NY', '10002', 40.7150, -74.0020, true),
        (rest2_id, '789 Pasta Ave', 'New York', 'NY', '10003', 40.7140, -74.0040, true),
        (rest3_id, '321 Dragon St', 'New York', 'NY', '10004', 40.7110, -74.0080, true);

    -- Create restaurant hours (open 11 AM to 10 PM, Monday to Sunday)
    INSERT INTO public.restaurant_hours (restaurant_id, day_of_week, open_time, close_time)
    SELECT rest_id, dow, '11:00'::time, '22:00'::time
    FROM (VALUES (rest1_id), (rest2_id), (rest3_id)) AS restaurants(rest_id)
    CROSS JOIN generate_series(0, 6) AS dow;

    -- Create menus
    INSERT INTO public.menus (id, restaurant_id, name, description, is_active)
    VALUES
        (menu1_id, rest1_id, 'Dinner Menu', 'Traditional Indian dinner specialties', true),
        (menu2_id, rest2_id, 'Main Menu', 'Italian classics and wood-fired pizzas', true);

    -- Create menu categories
    INSERT INTO public.menu_categories (id, menu_id, name, description, sort_order)
    VALUES
        (cat1_id, menu1_id, 'Curry Dishes', 'Rich and flavorful curry preparations', 1),
        (cat2_id, menu2_id, 'Pizza', 'Wood-fired pizzas with fresh ingredients', 1);

    -- Create menu items
    INSERT INTO public.menu_items (category_id, name, description, price_cents, is_available, is_popular)
    VALUES
        (cat1_id, 'Butter Chicken', 'Creamy tomato-based curry with tender chicken', 1650, true, true),
        (cat1_id, 'Lamb Biryani', 'Aromatic basmati rice with spiced lamb', 1850, true, false),
        (cat1_id, 'Paneer Makhani', 'Rich cottage cheese in creamy gravy', 1450, true, true),
        (cat2_id, 'Margherita Pizza', 'Fresh mozzarella, basil, and tomato sauce', 1200, true, true),
        (cat2_id, 'Pepperoni Pizza', 'Classic pepperoni with mozzarella cheese', 1400, true, false);

    -- Create deals
    INSERT INTO public.deals (id, restaurant_id, title, description, deal_type, discount_value, is_active)
    VALUES
        (deal1_id, rest1_id, '20% Off Lunch', 'Get 20% off on all lunch orders', 'PERCENT_OFF', 20.00, true);

    -- Create deal schedules (Monday to Friday, 12 PM to 3 PM)
    INSERT INTO public.deal_schedules (deal_id, day_of_week, start_time, end_time)
    SELECT deal1_id, dow, '12:00'::time, '15:00'::time
    FROM generate_series(1, 5) AS dow;

    -- Create buffet details
    INSERT INTO public.buffet_details (id, restaurant_id, title, description, adult_price_cents, child_price_cents, is_active)
    VALUES
        (buffet1_id, rest1_id, 'Weekend Buffet', 'All-you-can-eat Indian buffet with 25+ items', 1999, 999, true);

    -- Create buffet schedules (Saturday and Sunday, 12 PM to 9 PM)
    INSERT INTO public.buffet_schedules (buffet_id, day_of_week, start_time, end_time)
    VALUES
        (buffet1_id, 0, '12:00'::time, '21:00'::time), -- Sunday
        (buffet1_id, 6, '12:00'::time, '21:00'::time); -- Saturday

    -- Create restaurant admin relationships
    INSERT INTO public.restaurant_admins (user_id, restaurant_id, role)
    VALUES
        (admin_id, rest1_id, 'admin'),
        (admin_id, rest2_id, 'admin');

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion error: %', SQLERRM;
END $$;