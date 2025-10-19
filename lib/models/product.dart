/// Product model for API
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
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert Product to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Create Product from Map (for backward compatibility)
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product.fromJson(map);
  }

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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Sample products for testing
  static List<Product> getSampleProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: '1',
        name: 'Vintage Gold Watch',
        description:
            'Elegant vintage-inspired gold watch with leather strap. Perfect for special occasions.',
        price: 299.99,
        category: 'Accessories',
        images: ['assets/images_clothing/vintage_watch.jpg'],
        colors: ['Gold', 'Silver', 'Rose Gold'],
        sizes: ['One Size'],
        isNew: true,
        isFeatured: true,
        stock: 15,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      Product(
        id: '2',
        name: 'Classic Leather Jacket',
        description:
            'Premium genuine leather jacket with vintage styling. Made from the finest materials.',
        price: 599.99,
        category: 'Clothing',
        images: ['assets/images_clothing/leather_jacket.jpg'],
        colors: ['Black', 'Brown', 'Tan'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: false,
        isFeatured: true,
        stock: 8,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Product(
        id: '3',
        name: 'Luxury Silk Scarf',
        description:
            'Handcrafted silk scarf with intricate vintage patterns. A timeless accessory.',
        price: 149.99,
        category: 'Accessories',
        images: ['assets/images_clothing/silk_scarf.jpg'],
        colors: ['Cream', 'Navy', 'Burgundy'],
        sizes: ['One Size'],
        isNew: true,
        isFeatured: false,
        stock: 25,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      Product(
        id: '4',
        name: 'Vintage Denim Jeans',
        description:
            'Classic vintage-style denim jeans with authentic distressing and premium fit.',
        price: 199.99,
        category: 'Clothing',
        images: ['assets/images_clothing/vintage_jeans.jpg'],
        colors: ['Blue', 'Black', 'Light Blue'],
        sizes: ['28', '30', '32', '34', '36'],
        isNew: false,
        isFeatured: false,
        stock: 20,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),
      Product(
        id: '5',
        name: 'Elegant Pearl Necklace',
        description:
            'Sophisticated pearl necklace with vintage charm. Perfect for formal events.',
        price: 399.99,
        category: 'Jewelry',
        images: ['assets/images_clothing/pearl_necklace.jpg'],
        colors: ['White', 'Cream', 'Pink'],
        sizes: ['16"', '18"', '20"'],
        isNew: true,
        isFeatured: true,
        stock: 12,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      Product(
        id: '6',
        name: 'Vintage Wool Coat',
        description:
            'Warm and stylish vintage wool coat with classic tailoring and premium finish.',
        price: 449.99,
        category: 'Clothing',
        images: ['assets/images_clothing/wool_coat.jpg'],
        colors: ['Camel', 'Black', 'Navy'],
        sizes: ['S', 'M', 'L', 'XL'],
        isNew: false,
        isFeatured: true,
        stock: 6,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
    ];
  }
}
