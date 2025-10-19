/// Cart item model for API compatibility
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String selectedColor;
  final String selectedSize;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert CartItem to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create CartItem from API JSON response
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      selectedColor: json['selectedColor'] ?? '',
      selectedSize: json['selectedSize'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert CartItem to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Create CartItem from Map (for backward compatibility)
  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem.fromJson(map);
  }

  /// Create a copy with updated values
  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get total price for this cart item
  double get totalPrice => price * quantity;
}
