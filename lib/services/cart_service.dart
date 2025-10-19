import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import 'backend_cart_service.dart';

/// Cart service wrapper for backward compatibility
class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final BackendCartService _backendCart = BackendCartService();

  // Local cache for cart data
  Cart? _cart;
  List<CartItem> _items = [];
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _shipping = 0.0;
  double _total = 0.0;
  int _itemCount = 0;

  // Getters for backward compatibility
  List<CartItem> get items => _items;
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get shipping => _shipping;
  double get total => _total;
  int get itemCount => _itemCount;

  /// Load cart data and update local cache
  Future<void> _loadCart() async {
    try {
      _cart = await _backendCart.getCart();
      _items = _cart?.items ?? [];
      _subtotal = _cart?.subtotal ?? 0.0;
      _tax = _cart?.tax ?? 0.0;
      _shipping = _cart?.shipping ?? 0.0;
      _total = _cart?.total ?? 0.0;
      _itemCount = _items.fold<int>(0, (sum, item) => sum + item.quantity);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  /// Get user's cart
  Future<Cart> getCart() async {
    try {
      return await _backendCart.getCart();
    } catch (e) {
      debugPrint('Error getting cart: $e');
      rethrow;
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String selectedColor,
    required String selectedSize,
  }) async {
    try {
      await _backendCart.addToCart(
        productId: productId,
        quantity: quantity,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      );
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _backendCart.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _backendCart.removeFromCart(cartItemId);
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      await _backendCart.clearCart();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      return await _backendCart.getCartItemCount();
    } catch (e) {
      debugPrint('Error getting cart item count: $e');
      return 0;
    }
  }

  /// Check if product is in cart
  Future<bool> isProductInCart(String productId) async {
    try {
      return await _backendCart.isProductInCart(productId);
    } catch (e) {
      debugPrint('Error checking if product in cart: $e');
      return false;
    }
  }

  /// Get cart item for specific product
  Future<CartItem?> getCartItemForProduct(String productId) async {
    try {
      return await _backendCart.getCartItemForProduct(productId);
    } catch (e) {
      debugPrint('Error getting cart item for product: $e');
      return null;
    }
  }

  /// Add item to cart (alternative method name expected by UI)
  Future<void> addItem({
    required String productId,
    required int quantity,
    required String selectedColor,
    required String selectedSize,
  }) async {
    await addToCart(
      productId: productId,
      quantity: quantity,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
    );
    await _loadCart();
  }

  /// Update quantity (alternative method name expected by UI)
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await updateCartItem(cartItemId: cartItemId, quantity: quantity);
    await _loadCart();
  }

  /// Remove item (alternative method name expected by UI)
  Future<void> removeItem(String cartItemId) async {
    await removeFromCart(cartItemId);
    await _loadCart();
  }

  /// Clear cart (alternative method name expected by UI)
  Future<void> clear() async {
    await clearCart();
    await _loadCart();
  }

  /// Initialize cart service
  Future<void> initialize() async {
    await _loadCart();
  }
}
