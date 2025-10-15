import 'package:flutter/foundation.dart';

/// Cart item model
class CartItem {
  final Map<String, dynamic> product;
  int quantity;
  final String selectedColor;
  final String selectedSize;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
  });

  double get totalPrice => (product['price'] as num).toDouble() * quantity;

  String get uniqueId => '${product['id']}_${selectedColor}_$selectedSize';
}

/// Cart service - Singleton pattern for managing cart state
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.1; // 10% tax

  double get shipping => subtotal > 0 ? 15.0 : 0.0;

  double get total => subtotal + tax + shipping;

  /// Add item to cart
  void addItem({
    required Map<String, dynamic> product,
    required int quantity,
    required String selectedColor,
    required String selectedSize,
  }) {
    final uniqueId = '${product['id']}_${selectedColor}_$selectedSize';

    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (item) => item.uniqueId == uniqueId,
    );

    if (existingIndex >= 0) {
      // Update quantity if item exists
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
    }

    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(String uniqueId, int quantity) {
    final index = _items.indexWhere((item) => item.uniqueId == uniqueId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeItem(String uniqueId) {
    _items.removeWhere((item) => item.uniqueId == uniqueId);
    notifyListeners();
  }

  /// Clear all items
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
