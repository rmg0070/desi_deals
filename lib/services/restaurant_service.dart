import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math; // Add this import for math operations

import '../models/buffet.dart';
import '../models/deal.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../models/restaurant_hours.dart';
import './supabase_service.dart';
import 'supabase_service.dart';

class RestaurantService {
  static final SupabaseClient _client = SupabaseService.instance.client;

  /// Get nearby restaurants using RPC function
  static Future<List<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
  }) async {
    try {
      final response = await _client.rpc(
        'api_nearby_restaurants',
        params: {
          'u_lat': latitude,
          'u_lon': longitude,
          'radius_m': radiusKm * 1000,
        },
      );

      if (response == null) return [];

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch nearby restaurants: $error');
    }
  }

  /// Get restaurant by ID with location details
  static Future<Restaurant?> getRestaurantById(String restaurantId) async {
    try {
      final response = await _client
          .from('restaurants')
          .select('''
            *,
            restaurant_locations!inner(
              address, city, state, zip_code, latitude, longitude, is_primary
            )
          ''')
          .eq('id', restaurantId)
          .eq('restaurant_locations.is_primary', true)
          .single();

      return Restaurant.fromJson({
        ...response,
        'address': response['restaurant_locations'][0]['address'],
        'city': response['restaurant_locations'][0]['city'],
        'state': response['restaurant_locations'][0]['state'],
        'zip_code': response['restaurant_locations'][0]['zip_code'],
        'latitude': response['restaurant_locations'][0]['latitude'],
        'longitude': response['restaurant_locations'][0]['longitude'],
      });
    } catch (error) {
      throw Exception('Failed to fetch restaurant details: $error');
    }
  }

  /// Get active deals for a restaurant that are running now
  static Future<List<Deal>> getDealsNow(String restaurantId) async {
    try {
      final response = await _client.rpc(
        'api_deals_now',
        params: {'rid': restaurantId},
      );

      if (response == null) return [];

      return (response as List).map((json) => Deal.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch current deals: $error');
    }
  }

  /// Get buffet information available today
  static Future<List<Buffet>> getBuffetToday(String restaurantId) async {
    try {
      final response = await _client.rpc(
        'api_buffet_today',
        params: {'rid': restaurantId},
      );

      if (response == null) return [];

      return (response as List).map((json) => Buffet.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch buffet information: $error');
    }
  }

  /// Get restaurant menu with categories and items
  static Future<List<MenuCategory>> getRestaurantMenu(
      String restaurantId) async {
    try {
      final response = await _client
          .from('menus')
          .select('''
            id, name, description,
            menu_categories!inner(
              id, name, description, sort_order,
              menu_items(
                id, name, description, price_cents, image_url, 
                is_available, is_popular, allergens
              )
            )
          ''')
          .eq('restaurant_id', restaurantId)
          .eq('is_active', true)
          .order('sort_order', referencedTable: 'menu_categories');

      if (response.isEmpty) return [];

      List<MenuCategory> categories = [];
      for (var menu in response) {
        for (var categoryJson in menu['menu_categories']) {
          final items = (categoryJson['menu_items'] as List)
              .map((item) => MenuItem.fromJson(item))
              .where((item) => item.isAvailable)
              .toList();

          if (items.isNotEmpty) {
            categories.add(MenuCategory(
              id: categoryJson['id'],
              menuId: menu['id'],
              name: categoryJson['name'],
              description: categoryJson['description'],
              sortOrder: categoryJson['sort_order'],
              isActive: true,
              items: items,
            ));
          }
        }
      }

      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return categories;
    } catch (error) {
      throw Exception('Failed to fetch restaurant menu: $error');
    }
  }

  /// Get restaurant hours for all days
  static Future<List<RestaurantHours>> getRestaurantHours(
      String restaurantId) async {
    try {
      final response = await _client
          .from('restaurant_hours')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .order('day_of_week');

      return (response as List)
          .map((json) => RestaurantHours.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch restaurant hours: $error');
    }
  }

  /// Search restaurants by cuisine type
  static Future<List<Restaurant>> searchRestaurantsByCuisine({
    required List<String> cuisineTypes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      var query = _client.from('restaurants').select('''
            *,
            restaurant_locations!inner(
              address, city, state, zip_code, latitude, longitude, is_primary
            )
          ''').eq('restaurant_locations.is_primary', true);

      // Add cuisine filter
      if (cuisineTypes.isNotEmpty) {
        query = query.overlaps('cuisine_type', cuisineTypes);
      }

      final response = await query;

      List<Restaurant> restaurants = (response as List).map((json) {
        return Restaurant.fromJson({
          ...json,
          'address': json['restaurant_locations'][0]['address'],
          'city': json['restaurant_locations'][0]['city'],
          'state': json['restaurant_locations'][0]['state'],
          'zip_code': json['restaurant_locations'][0]['zip_code'],
          'latitude': json['restaurant_locations'][0]['latitude'],
          'longitude': json['restaurant_locations'][0]['longitude'],
        });
      }).toList();

      // If location provided, calculate distance and sort
      if (latitude != null && longitude != null) {
        for (var restaurant in restaurants) {
          if (restaurant.latitude != null && restaurant.longitude != null) {
            double distance = _calculateDistance(
              latitude,
              longitude,
              restaurant.latitude!,
              restaurant.longitude!,
            );
            restaurant.copyWith(distanceMeters: distance);
          }
        }
        restaurants.sort((a, b) => (a.distanceMeters ?? double.infinity)
            .compareTo(b.distanceMeters ?? double.infinity));
      }

      return restaurants;
    } catch (error) {
      throw Exception('Failed to search restaurants: $error');
    }
  }

  /// Calculate distance between two coordinates in meters
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = (2 * math.asin(math.sqrt(a))).toDouble();
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

extension RestaurantCopy on Restaurant {
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? phone,
    String? email,
    String? websiteUrl,
    String? mapsUrl,
    String? imageUrl,
    double? averageRating,
    int? totalReviews,
    int? priceRange,
    List<String>? cuisineType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    double? distanceMeters,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      priceRange: priceRange ?? this.priceRange,
      cuisineType: cuisineType ?? this.cuisineType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }
}