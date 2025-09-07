import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/cuisine_filter_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/location_header_widget.dart';
import './widgets/restaurant_card_widget.dart';
import './widgets/skeleton_card_widget.dart';

class RestaurantDiscovery extends StatefulWidget {
  const RestaurantDiscovery({super.key});

  @override
  State<RestaurantDiscovery> createState() => _RestaurantDiscoveryState();
}

class _RestaurantDiscoveryState extends State<RestaurantDiscovery> {
  // State variables
  List<Restaurant> _restaurants = [];
  List<String> _selectedCuisines = [];
  double _radiusKm = 10.0;
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  String _errorMessage = '';

  // Location state
  double? _currentLat;
  double? _currentLon;
  String _currentAddress = 'Getting your location...';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Try to get user's saved location first
      final userProfile = await UserService.getCurrentUserProfile();
      if (userProfile?.hasLocation == true) {
        setState(() {
          _currentLat = userProfile!.currentLat;
          _currentLon = userProfile.currentLon;
          _currentAddress = userProfile.formattedAddress.isNotEmpty
              ? userProfile.formattedAddress
              : 'Current Location';
        });
        await _loadRestaurants();
      } else {
        // If no saved location, get current GPS location
        await _getCurrentLocation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
      _currentAddress = 'Getting your location...';
    });

    try {
      final position = await UserService.getCurrentLocation();
      await UserService.updateUserLocation(
          position.latitude, position.longitude);

      final updatedProfile = await UserService.getCurrentUserProfile();
      setState(() {
        _currentLat = position.latitude;
        _currentLon = position.longitude;
        _currentAddress = updatedProfile?.formattedAddress.isNotEmpty == true
            ? updatedProfile!.formattedAddress
            : 'Current Location';
      });

      await _loadRestaurants();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _currentAddress = 'Location unavailable';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadRestaurants() async {
    if (_currentLat == null || _currentLon == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Restaurant> restaurants;

      if (_selectedCuisines.isEmpty) {
        restaurants = await RestaurantService.getNearbyRestaurants(
          latitude: _currentLat!,
          longitude: _currentLon!,
          radiusKm: _radiusKm.round(),
        );
      } else {
        restaurants = await RestaurantService.searchRestaurantsByCuisine(
          cuisineTypes: _selectedCuisines,
          latitude: _currentLat,
          longitude: _currentLon,
        );
      }

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load restaurants: $e';
        _isLoading = false;
      });
    }
  }

  void _onCuisineFilterChanged(List<String> selectedCuisines) {
    setState(() {
      _selectedCuisines = selectedCuisines;
    });
    _loadRestaurants();
  }

  void _onRadiusChanged(double radius) {
    setState(() {
      _radiusKm = radius;
    });
    _loadRestaurants();
  }

  void _onRestaurantTap(Restaurant restaurant) {
    Navigator.pushNamed(
      context,
      AppRoutes.restaurantDetail,
      arguments: restaurant.id,
    );
  }

  void _onRefresh() {
    _loadRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.discovery,
        title: 'Discover Restaurants',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: Column(
          children: [
            // Location Header
            LocationHeaderWidget(
              currentLocation: _currentAddress,
              selectedRadius: _radiusKm,
              onRadiusChanged: _onRadiusChanged,
              onLocationTap: _getCurrentLocation,
            ),

            // Cuisine Filter
            CuisineFilterWidget(
              selectedCuisines: _selectedCuisines,
              onCuisineToggle: (cuisine) {
                setState(() {
                  if (_selectedCuisines.contains(cuisine)) {
                    _selectedCuisines.remove(cuisine);
                  } else {
                    _selectedCuisines.add(cuisine);
                  }
                });
                _loadRestaurants();
              },
            ),

            // Radius Slider
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Text(
                    'Radius: ',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: _radiusKm,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_radiusKm.round()} km',
                      onChanged: _onRadiusChanged,
                    ),
                  ),
                  Text(
                    '${_radiusKm.round()} km',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Restaurant List
            Expanded(
              child: _buildRestaurantList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on discovery page
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.userProfile);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.ownerDashboard);
              break;
          }
        },
      ),
    );
  }

  Widget _buildRestaurantList() {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: 6,
        itemBuilder: (context, index) => const SkeletonCardWidget(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: Colors.grey,
            ),
            SizedBox(height: 2.h),
            Text(
              'Error',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return EmptyStateWidget(
        title: 'No Restaurants Found',
        subtitle: 'Try adjusting your filters or search radius',
        actionText: 'Refresh',
        onActionPressed: _onRefresh,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return RestaurantCardWidget(
          restaurant: restaurant.toMap(),
          onTap: () => _onRestaurantTap(restaurant),
          onFavoriteToggle: (restaurantMap) {
            // Handle favorite toggle functionality
          },
        );
      },
    );
  }
}