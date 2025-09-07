class Deal {
  final String id;
  final String title;
  final String description;
  final String dealType;
  final double? discountValue;
  final int minimumOrderCents;
  final int? maximumDiscountCents;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.dealType,
    this.discountValue,
    required this.minimumOrderCents,
    this.maximumDiscountCents,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['deal_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dealType: json['deal_type'] ?? '',
      discountValue: json['discount_value']?.toDouble(),
      minimumOrderCents: json['minimum_order_cents'] ?? 0,
      maximumDiscountCents: json['maximum_discount_cents'],
    );
  }

  String get formattedDiscount {
    if (discountValue == null) return '';

    switch (dealType) {
      case 'PERCENT_OFF':
        return '${discountValue!.toInt()}% OFF';
      case 'AMOUNT_OFF':
        return '\$${(discountValue! / 100).toStringAsFixed(2)} OFF';
      case 'FIXED_PRICE':
        return 'Only \$${(discountValue! / 100).toStringAsFixed(2)}';
      case 'BOGO':
        return 'Buy One Get One Free';
      default:
        return '';
    }
  }

  String get formattedMinimumOrder {
    if (minimumOrderCents == 0) return '';
    return 'Min order: \$${(minimumOrderCents / 100).toStringAsFixed(2)}';
  }
}
