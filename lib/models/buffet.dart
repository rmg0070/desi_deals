class Buffet {
  final String id;
  final String title;
  final String? description;
  final int adultPriceCents;
  final int? childPriceCents;
  final int? seniorPriceCents;
  final String? startTime;
  final String? endTime;

  Buffet({
    required this.id,
    required this.title,
    this.description,
    required this.adultPriceCents,
    this.childPriceCents,
    this.seniorPriceCents,
    this.startTime,
    this.endTime,
  });

  factory Buffet.fromJson(Map<String, dynamic> json) {
    return Buffet(
      id: json['buffet_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      adultPriceCents: json['adult_price_cents'] ?? 0,
      childPriceCents: json['child_price_cents'],
      seniorPriceCents: json['senior_price_cents'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  String get formattedAdultPrice {
    return '\$${(adultPriceCents / 100).toStringAsFixed(2)}';
  }

  String get formattedChildPrice {
    if (childPriceCents == null) return '';
    return '\$${(childPriceCents! / 100).toStringAsFixed(2)}';
  }

  String get formattedSeniorPrice {
    if (seniorPriceCents == null) return '';
    return '\$${(seniorPriceCents! / 100).toStringAsFixed(2)}';
  }

  String get formattedTimeRange {
    if (startTime == null || endTime == null) return '';
    return '$startTime - $endTime';
  }
}
