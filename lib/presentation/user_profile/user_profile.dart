import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart' as models; // Add alias for imported UserProfile model
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/account_options_widget.dart';
import './widgets/app_settings_widget.dart';
import './widgets/cuisine_preferences_widget.dart';
import './widgets/location_preferences_widget.dart';
import './widgets/profile_header_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  models.UserProfile? _userProfile; // Use aliased import to avoid naming conflict
  bool _isLoading = true;
  bool _isUpdating = false;
  String _errorMessage = '';

  // Form controllers for manual address entry
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final profile = await UserService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });

      // Pre-fill form controllers with existing address
      if (profile != null) {
        _streetController.text = profile.street ?? '';
        _cityController.text = profile.city ?? '';
        _zipController.text = profile.zipCode ?? '';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocationWithGPS() async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      final position = await UserService.getCurrentLocation();
      final updatedProfile = await UserService.updateUserLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _userProfile = updatedProfile;
        // Update form controllers with new address
        _streetController.text = updatedProfile.street ?? '';
        _cityController.text = updatedProfile.city ?? '';
        _zipController.text = updatedProfile.zipCode ?? '';
      });

      _showSnackBar('Location updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update location: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateLocationWithAddress() async {
    if (_isUpdating) return;

    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final zipCode = _zipController.text.trim();

    if (street.isEmpty || city.isEmpty || zipCode.isEmpty) {
      _showSnackBar('Please fill in all address fields');
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final updatedProfile = await UserService.updateUserAddress(
        street: street,
        city: city,
        zipCode: zipCode,
      );

      setState(() => _userProfile = updatedProfile);
      _showSnackBar('Address updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update address: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateCuisinePreferences(List<String> cuisineFilter) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      final updatedProfile =
          await UserService.updateCuisinePreferences(cuisineFilter);
      setState(() => _userProfile = updatedProfile);
      _showSnackBar('Cuisine preferences updated');
    } catch (e) {
      _showSnackBar('Failed to update preferences: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.profile, // Add required variant parameter
        title: 'Profile',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.restaurantDiscovery);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.restaurantDiscovery);
              break;
            case 1:
              // Already on profile page
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.ownerDashboard);
              break;
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              'Error Loading Profile',
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
              onPressed: _loadUserProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          ProfileHeaderWidget(
            userData: {
              'name': _userProfile?.fullName ?? 'User Name',
              'email': _userProfile?.email ?? 'user@example.com',
              'memberSince': 'Jan 2024',
              'avatar': null,
            }, // Use userData instead of userProfile
            onAvatarTap: () {}, // Add required onAvatarTap callback
          ),

          SizedBox(height: 3.h),

          // Location Preferences
          LocationPreferencesWidget(
            savedAddresses: [], // Use savedAddresses instead of userProfile
            onDeleteAddress: (index) {}, // Add required callback
            onAddAddress: () {}, // Add required callback
          ),

          SizedBox(height: 3.h),

          // Cuisine Preferences
          CuisinePreferencesWidget(
            availableCuisines: [ // Use availableCuisines instead of selectedCuisines
              {'name': 'Italian', 'emoji': '🍝'},
              {'name': 'Chinese', 'emoji': '🥢'},
              {'name': 'Mexican', 'emoji': '🌮'},
              {'name': 'Indian', 'emoji': '🍛'},
            ],
            selectedCuisines: _userProfile?.cuisineFilter ?? [],
            onCuisineToggle: (cuisine) {}, // Remove isUpdating parameter and use onCuisineToggle
          ),

          SizedBox(height: 3.h),

          // Account Options
          AccountOptionsWidget(
            onOptionTap: (option) {}, // Use onOptionTap instead of userProfile
          ),

          SizedBox(height: 3.h),

          // App Settings
          AppSettingsWidget(
            appSettings: { // Add required appSettings parameter
              'distanceUnit': 'miles',
              'pushNotifications': true,
              'locationSharing': true,
              'darkMode': false,
            },
            onSettingChanged: (key, value) {}, // Add required onSettingChanged callback
          ),
        ],
      ),
    );
  }
}