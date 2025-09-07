class RestaurantHours {
  final String id;
  final String restaurantId;
  final int dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  RestaurantHours({
    required this.id,
    required this.restaurantId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory RestaurantHours.fromJson(Map<String, dynamic> json) {
    return RestaurantHours(
      id: json['id'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'] ?? false,
    );
  }

  String get dayName {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[dayOfWeek % 7];
  }

  String get formattedHours {
    if (isClosed || openTime == null || closeTime == null) {
      return 'Closed';
    }
    return '$openTime - $closeTime';
  }
}
