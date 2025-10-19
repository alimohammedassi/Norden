/// Wishlist item model for API compatibility
class WishlistItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert WishlistItem to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create WishlistItem from API JSON response
  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert WishlistItem to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Create WishlistItem from Map (for backward compatibility)
  factory WishlistItem.fromMap(Map<String, dynamic> map, String id) {
    return WishlistItem.fromJson(map);
  }

  /// Create a copy with updated values
  WishlistItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
