import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

/// Simple local cart model
class Cart {
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  Cart({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
  });
}

/// Cart service using local storage (no backend)
class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _prefsKey = 'local_cart_v1';

  final List<CartItem> _items = [];
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _shipping = 0.0;
  double _total = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get shipping => _shipping;
  double get total => _total;
  int get itemCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(jsonList));
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefsKey);
      _items.clear();
      if (data != null && data.isNotEmpty) {
        final List<dynamic> list = jsonDecode(data);
        for (final item in list) {
          _items.add(CartItem.fromJson(item as Map<String, dynamic>));
        }
      }
      _recalculate();
      notifyListeners();
    } catch (e) {
      debugPrint('Cart load error: $e');
    }
  }

  void _recalculate() {
    _subtotal = _items.fold<double>(0.0, (s, it) => s + it.totalPrice);
    _tax = (_subtotal * 0.0);
    _shipping = _items.isEmpty ? 0.0 : 0.0;
    _total = _subtotal + _tax + _shipping;
  }

  Future<Cart> getCart() async {
    await _load();
    return Cart(
      items: List.unmodifiable(_items),
      subtotal: _subtotal,
      tax: _tax,
      shipping: _shipping,
      total: _total,
    );
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String selectedColor,
    required String selectedSize,
    String? productName,
    double? price,
    String? imageUrl,
  }) async {
    final now = DateTime.now();
    final existingIndex = _items.indexWhere(
      (it) =>
          it.productId == productId &&
          it.selectedColor == selectedColor &&
          it.selectedSize == selectedSize,
    );
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
        updatedAt: now,
      );
    } else {
      _items.add(
        CartItem(
          id: '${productId}_${selectedColor}_${selectedSize}_$now',
          productId: productId,
          productName: productName ?? 'Product',
          price: price ?? 0.0,
          quantity: quantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          imageUrl: imageUrl ?? '',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    _recalculate();
    await _persist();
    notifyListeners();
  }

  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    final index = _items.indexWhere((it) => it.id == cartItemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: quantity,
        updatedAt: DateTime.now(),
      );
      _recalculate();
      await _persist();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _items.removeWhere((it) => it.id == cartItemId);
    _recalculate();
    await _persist();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    _recalculate();
    await _persist();
    notifyListeners();
  }

  Future<int> getCartItemCount() async {
    await _load();
    return itemCount;
  }

  Future<bool> isProductInCart(String productId) async {
    await _load();
    return _items.any((it) => it.productId == productId);
  }

  Future<CartItem?> getCartItemForProduct(String productId) async {
    await _load();
    try {
      return _items.firstWhere((it) => it.productId == productId);
    } catch (_) {
      return null;
    }
  }

  // Aliases used by UI
  Future<void> addItem({
    required String productId,
    required int quantity,
    required String selectedColor,
    required String selectedSize,
    String? productName,
    double? price,
    String? imageUrl,
  }) async {
    await addToCart(
      productId: productId,
      quantity: quantity,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
    );
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await updateCartItem(cartItemId: cartItemId, quantity: quantity);
  }

  Future<void> removeItem(String cartItemId) async {
    await removeFromCart(cartItemId);
  }

  Future<void> clear() async {
    await clearCart();
  }

  Future<void> initialize() async {
    await _load();
  }
}
