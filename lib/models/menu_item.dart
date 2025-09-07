class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final int priceCents;
  final String? imageUrl;
  final bool isAvailable;
  final bool isPopular;
  final List<String> allergens;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.priceCents,
    this.imageUrl,
    required this.isAvailable,
    required this.isPopular,
    required this.allergens,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      priceCents: json['price_cents'] ?? 0,
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      isPopular: json['is_popular'] ?? false,
      allergens:
          json['allergens'] != null ? List<String>.from(json['allergens']) : [],
    );
  }

  String get formattedPrice {
    return '\$${(priceCents / 100).toStringAsFixed(2)}';
  }
}

class MenuCategory {
  final String id;
  final String menuId;
  final String name;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.menuId,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? '',
      menuId: json['menu_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MenuItem.fromJson(item))
              .toList()
          : [],
    );
  }
}
