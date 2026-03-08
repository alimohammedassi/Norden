/// Category model — NORDEN Maison de Luxe
class Category {
  final String id;
  final String name;
  final String slug;
  final String? season; // "winter" | "summer" | null (applies to all)
  final String? iconName;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.season,
    this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['name'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? (json['name'] ?? '').toLowerCase(),
      season: json['season'],
      iconName: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'season': season,
    'icon': iconName,
  };

  /// Static fallback list — used while backend is loading or offline
  /// Matches the categories in the backend API specification
  static List<Category> get fallbackCategories => const [
    Category(id: 'suits', name: 'Suits', slug: 'suits'),
    Category(id: 'blazers', name: 'Blazers', slug: 'blazers'),
    Category(id: 'dress-shirts', name: 'Dress Shirts', slug: 'dress-shirts'),
    Category(id: 'trousers', name: 'Trousers', slug: 'trousers'),
    Category(id: 'coats', name: 'Coats', slug: 'coats'),
    Category(id: 'accessories', name: 'Accessories', slug: 'accessories'),
  ];
}
