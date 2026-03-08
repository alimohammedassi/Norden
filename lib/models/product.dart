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

  /// Sample products for offline fallback
  static List<Product> getSampleProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: '1',
        name: 'Double-breasted Blazer',
        description:
            'Tailored double-breasted blazer with sharp lapels and premium finish.',
        price: 299.99,
        category: 'Blazers',
        season: 'winter',
        rating: 4.9,
        reviewCount: 128,
        images: [
          'assets/images/Double-breasted_blazer.jpg',
          'assets/images/Single-breasted_blazer (1).jpg',
          'assets/images/Fitted_blazer.jpg',
          'assets/images/Long_blazer.jpg',
        ],
        colors: ['Black', 'Navy', 'Grey'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: true,
        isFeatured: true,
        stock: 15,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      Product(
        id: '2',
        name: 'Classic Trench Coat',
        description:
            'Premium trench coat with a flattering silhouette and water-repellent finish.',
        price: 449.99,
        category: 'Coats',
        season: 'winter',
        rating: 4.8,
        reviewCount: 94,
        images: [
          'assets/images/Trench_coat.jpg',
          'assets/images/Car_coat.jpg',
          'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
          'assets/images/young-man-dressed-coat-isolated-white-wall.jpg',
        ],
        colors: ['Beige', 'Black', 'Navy'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: false,
        isFeatured: true,
        stock: 8,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Product(
        id: '3',
        name: 'Car Coat',
        description:
            'Classic car coat with clean lines and minimalist details for everyday elegance.',
        price: 399.99,
        category: 'Coats',
        season: 'all',
        rating: 4.7,
        reviewCount: 61,
        images: [
          'assets/images/Car_coat.jpg',
          'assets/images/Double-breasted_blazer.jpg',
          'assets/images/Single-breasted_blazer (1).jpg',
          'assets/images/Tie-belt_denim_jacket.jpg',
        ],
        colors: ['Camel', 'Black', 'Navy'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: true,
        isFeatured: false,
        stock: 25,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      Product(
        id: '4',
        name: 'Tie-belt Denim Jacket',
        description:
            'Contemporary tie-belt denim jacket with structured shoulders and refined wash.',
        price: 199.99,
        category: 'Suits',
        season: 'summer',
        rating: 4.6,
        reviewCount: 43,
        images: [
          'assets/images/Tie-belt_denim_jacket.jpg',
          'assets/images/Tie-belt_denim_jacket (2).jpg',
          'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
          'assets/images/young-man-dressed-coat-isolated-white-wall.jpg',
        ],
        colors: ['Blue', 'Black', 'Light Blue'],
        sizes: ['S', 'M', 'L'],
        isNew: false,
        isFeatured: false,
        stock: 20,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),
      Product(
        id: '5',
        name: 'Single-breasted Blazer',
        description:
            'Lightweight single-breasted blazer for effortless layering and polish.',
        price: 319.99,
        category: 'Blazers',
        season: 'summer',
        rating: 4.9,
        reviewCount: 207,
        images: [
          'assets/images/Single-breasted_blazer (1).jpg',
          'assets/images/Double-breasted_blazer.jpg',
          'assets/images/Car_coat.jpg',
          'assets/images/Trench_coat.jpg',
        ],
        colors: ['Black', 'Grey'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: true,
        isFeatured: true,
        stock: 12,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      Product(
        id: '6',
        name: 'Slim Fit Wool-blend Coat',
        description:
            'Warm wool-blend coat with slim silhouette and refined details.',
        price: 469.99,
        category: 'Coats',
        season: 'winter',
        rating: 4.8,
        reviewCount: 156,
        images: [
          'assets/images/Slim_Fit_Wool-blend_coat_Image_2_of_6.jpg',
          'assets/images/young-man-dressed-coat-isolated-white-wall.jpg',
          'assets/images/Trench_coat.jpg',
          'assets/images/Car_coat.jpg',
        ],
        colors: ['Camel', 'Black', 'Navy'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: false,
        isFeatured: true,
        stock: 6,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      Product(
        id: '7',
        name: 'Collarless Blazer',
        description:
            'Modern collarless blazer with a minimalist edge and fine tailoring.',
        price: 279.99,
        category: 'Blazers',
        season: 'all',
        rating: 4.7,
        reviewCount: 82,
        images: [
          'assets/images/Collarless_blazer.jpg',
          'assets/images/Collarless_blazer (1).jpg',
          'assets/images/Collarless_blazer (2).jpg',
          'assets/images/Collarless_blazer (3).jpg',
        ],
        colors: ['Ivory', 'Black', 'Beige'],
        sizes: ['XS', 'S', 'M', 'L'],
        isNew: true,
        isFeatured: false,
        stock: 18,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now,
      ),
      Product(
        id: '8',
        name: 'Padded Jacket',
        description:
            'Insulated padded jacket with a sleek silhouette and premium down filling.',
        price: 349.99,
        category: 'Coats',
        season: 'winter',
        rating: 4.9,
        reviewCount: 315,
        images: [
          'assets/images/Padded_jacket.jpg',
          'assets/images/Padded_jacket (1).jpg',
          'assets/images/Padded_jacket (2).jpg',
          'assets/images/Padded_jacket (3).jpg',
        ],
        colors: ['Black', 'Navy', 'Olive'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        isNew: false,
        isFeatured: true,
        stock: 30,
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now,
      ),
    ];
  }
}
