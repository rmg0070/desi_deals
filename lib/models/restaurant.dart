class Restaurant {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? websiteUrl;
  final String? mapsUrl;
  final String? imageUrl;
  final double averageRating;
  final int totalReviews;
  final int priceRange;
  final List<String> cuisineType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Location details (from join with restaurant_locations)
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.email,
    this.websiteUrl,
    this.mapsUrl,
    this.imageUrl,
    required this.averageRating,
    required this.totalReviews,
    required this.priceRange,
    required this.cuisineType,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.distanceMeters,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['restaurant_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      phone: json['phone'],
      email: json['email'],
      websiteUrl: json['website_url'],
      mapsUrl: json['maps_url'],
      imageUrl: json['image_url'],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      priceRange: json['price_range'] ?? 1,
      cuisineType: json['cuisine_type'] != null
          ? List<String>.from(json['cuisine_type'])
          : [],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distanceMeters: json['distance_meters']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'website_url': websiteUrl,
      'maps_url': mapsUrl,
      'image_url': imageUrl,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'price_range': priceRange,
      'cuisine_type': cuisineType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'distance_meters': distanceMeters,
    };
  }

  String get formattedDistance {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()}m';
    } else {
      double miles = distanceMeters! * 0.000621371;
      return '${miles.toStringAsFixed(1)} miles';
    }
  }

  String get priceRangeDisplay {
    return '\$' * priceRange;
  }

  String get cuisineDisplay {
    if (cuisineType.isEmpty) return '';
    if (cuisineType.length == 1) return cuisineType.first;
    if (cuisineType.length == 2) return cuisineType.join(' • ');
    return '${cuisineType.take(2).join(' • ')} +${cuisineType.length - 2}';
  }
}
