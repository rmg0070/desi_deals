import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';

class UserService {
  static final SupabaseClient _client = SupabaseService.instance.client;

  /// Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response =
          await _client.from('users').select('*').eq('id', user.id).single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Update user profile
  static Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updateData = profile.toJson()
        ..remove('id')
        ..remove('email')
        ..remove('created_at')
        ..['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('users')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  /// Get current device location
  static Future<Position> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (error) {
      throw Exception('Failed to get current location: $error');
    }
  }

  /// Update user location with GPS coordinates
  static Future<UserProfile> updateUserLocation(
      double latitude, double longitude) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get address from coordinates
      String? street, city, zipCode;
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          street = '${place.subThoroughfare ?? ''} ${place.thoroughfare ?? ''}'.trim();
          city = place.locality;
          zipCode = place.postalCode;
        }
      } catch (e) {
        // Continue without address if geocoding fails
      }

      final updateData = {
        'current_lat': latitude,
        'current_lon': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add address data if available
      if (street != null && street.isNotEmpty) updateData['street'] = street;
      if (city != null && city.isNotEmpty) updateData['city'] = city;
      if (zipCode != null && zipCode.isNotEmpty)
        updateData['zip_code'] = zipCode;

      final response = await _client
          .from('users')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update user location: $error');
    }
  }

  /// Update user location with manual address entry
  static Future<UserProfile> updateUserAddress({
    required String street,
    required String city,
    required String zipCode,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Try to geocode the address to get coordinates
      double? latitude, longitude;
      try {
        List<Location> locations =
            await locationFromAddress('$street, $city $zipCode');
        if (locations.isNotEmpty) {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        }
      } catch (e) {
        // Continue without coordinates if geocoding fails
      }

      final updateData = {
        'street': street,
        'city': city,
        'zip_code': zipCode,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add coordinates if available
      if (latitude != null && longitude != null) {
        updateData['current_lat'] = latitude.toString();
        updateData['current_lon'] = longitude.toString();
      }

      final response = await _client
          .from('users')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update user address: $error');
    }
  }

  /// Update user cuisine preferences
  static Future<UserProfile> updateCuisinePreferences(
      List<String> cuisineFilter) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('users')
          .update({
            'cuisine_filter': cuisineFilter,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update cuisine preferences: $error');
    }
  }

  /// Check if user has restaurant admin access
  static Future<List<String>> getUserManagedRestaurants() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('restaurant_admins')
          .select('restaurant_id')
          .eq('user_id', user.id);

      return (response as List)
          .map((item) => item['restaurant_id'] as String)
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch managed restaurants: $error');
    }
  }
}