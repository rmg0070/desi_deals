import 'package:flutter/material.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/restaurant_detail/restaurant_detail.dart';
import '../presentation/owner_dashboard/owner_dashboard.dart';
import '../presentation/restaurant_discovery/restaurant_discovery.dart';

class AppRoutes {
  static const String initial = '/';
  static const String userProfile = '/user-profile';
  static const String restaurantDetail = '/restaurant-detail';
  static const String ownerDashboard = '/owner-dashboard';
  static const String restaurantDiscovery = '/restaurant-discovery';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const RestaurantDiscovery(),
    userProfile: (context) => const UserProfile(),
    restaurantDetail: (context) => const RestaurantDetail(),
    ownerDashboard: (context) => const OwnerDashboard(),
    restaurantDiscovery: (context) => const RestaurantDiscovery(),
  };
}
