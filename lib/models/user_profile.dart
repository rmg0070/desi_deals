class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final double? currentLat;
  final double? currentLon;
  final String? street;
  final String? city;
  final String? zipCode;
  final List<String> cuisineFilter;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.currentLat,
    this.currentLon,
    this.street,
    this.city,
    this.zipCode,
    required this.cuisineFilter,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      currentLat: json['current_lat']?.toDouble(),
      currentLon: json['current_lon']?.toDouble(),
      street: json['street'],
      city: json['city'],
      zipCode: json['zip_code'],
      cuisineFilter: json['cuisine_filter'] != null
          ? List<String>.from(json['cuisine_filter'])
          : [],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'current_lat': currentLat,
      'current_lon': currentLon,
      'street': street,
      'city': city,
      'zip_code': zipCode,
      'cuisine_filter': cuisineFilter,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedAddress {
    List<String> addressParts = [];
    if (street != null && street!.isNotEmpty) addressParts.add(street!);
    if (city != null && city!.isNotEmpty) addressParts.add(city!);
    if (zipCode != null && zipCode!.isNotEmpty) addressParts.add(zipCode!);
    return addressParts.join(', ');
  }

  bool get hasLocation {
    return currentLat != null && currentLon != null;
  }
}
