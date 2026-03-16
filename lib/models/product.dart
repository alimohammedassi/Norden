/// Product model — NORDEN Maison de Luxe
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final List<String> colors;
  final List<String> sizes;
  final bool isNew;
  final bool isFeatured;
  final int stock;
  final double rating;
  final int reviewCount;

  /// Season slug: "winter" | "summer" | "all"
  final String season;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.colors,
    required this.sizes,
    this.isNew = false,
    this.isFeatured = false,
    this.stock = 0,
    this.rating = 4.8,
    this.reviewCount = 0,
    this.season = 'all',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Product to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'colors': colors,
      'sizes': sizes,
      'isNew': isNew,
      'isFeatured': isFeatured,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'season': season,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Product from API JSON response
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      isNew: json['isNew'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 4.8).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      season: json['season'] ?? 'all',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert Product to Map (for backward compatibility)
  Map<String, dynamic> toMap() => toJson();

  /// Create Product from Map (for backward compatibility)
  factory Product.fromMap(Map<String, dynamic> map, String id) =>
      Product.fromJson(map);

  /// Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    List<String>? colors,
    List<String>? sizes,
    bool? isNew,
    bool? isFeatured,
    int? stock,
    double? rating,
    int? reviewCount,
    String? season,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      season: season ?? this.season,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<Product> getSampleProducts() {
    return [];
  }
}
