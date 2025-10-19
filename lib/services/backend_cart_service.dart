import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../models/cart_item.dart';
import 'api_service.dart';
import 'backend_auth_service.dart';

// CartItem model is now imported from ../models/cart_item.dart

/// Cart model
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

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

/// Cart service using the custom backend API
class BackendCartService {
  static final BackendCartService _instance = BackendCartService._internal();
  factory BackendCartService() => _instance;
  BackendCartService._internal();

  final BackendAuthService _authService = BackendAuthService();

  // Local storage key for guest cart
  static const String _guestCartKey = 'guest_cart';

  // Local cart data for guests
  List<CartItem> _guestCartItems = [];
  double _guestSubtotal = 0.0;
  double _guestTax = 0.0;
  double _guestShipping = 0.0;
  double _guestTotal = 0.0;

  /// Check if user is authenticated
  bool get _isAuthenticated => _authService.currentUser != null;

  /// Load guest cart from local storage
  Future<void> _loadGuestCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_guestCartKey);
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
        _guestCartItems =
            (cartData['items'] as List<dynamic>?)
                ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        _guestSubtotal = (cartData['subtotal'] ?? 0).toDouble();
        _guestTax = (cartData['tax'] ?? 0).toDouble();
        _guestShipping = (cartData['shipping'] ?? 0).toDouble();
        _guestTotal = (cartData['total'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Error loading guest cart: $e');
    }
  }

  /// Save guest cart to local storage
  Future<void> _saveGuestCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'items': _guestCartItems.map((item) => item.toJson()).toList(),
        'subtotal': _guestSubtotal,
        'tax': _guestTax,
        'shipping': _guestShipping,
        'total': _guestTotal,
      };
      await prefs.setString(_guestCartKey, jsonEncode(cartData));
    } catch (e) {
      debugPrint('Error saving guest cart: $e');
    }
  }

  /// Calculate guest cart totals
  void _calculateGuestTotals() {
    _guestSubtotal = _guestCartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    _guestTax = _guestSubtotal * 0.1; // 10% tax
    _guestShipping = _guestSubtotal > 100
        ? 0.0
        : 10.0; // Free shipping over $100
    _guestTotal = _guestSubtotal + _guestTax + _guestShipping;
  }

  /// Get user's cart
  Future<Cart> getCart() async {
    try {
      if (!_isAuthenticated) {
        // Load guest cart from local storage
        await _loadGuestCart();
        _calculateGuestTotals();
        return Cart(
          items: _guestCartItems,
          subtotal: _guestSubtotal,
          tax: _guestTax,
          shipping: _guestShipping,
          total: _guestTotal,
        );
      }

      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.get(
        ApiConfig.cartEndpoint,
        headers: headers,
      );

      final data = response['data'] as Map<String, dynamic>;
      return Cart.fromJson(data);
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
      if (!_isAuthenticated) {
        // Handle guest cart
        await _loadGuestCart();

        // Check if item already exists
        final existingItemIndex = _guestCartItems.indexWhere(
          (item) =>
              item.productId == productId &&
              item.selectedColor == selectedColor &&
              item.selectedSize == selectedSize,
        );

        if (existingItemIndex != -1) {
          // Update quantity
          _guestCartItems[existingItemIndex] = CartItem(
            id: _guestCartItems[existingItemIndex].id,
            productId: productId,
            productName: _guestCartItems[existingItemIndex].productName,
            price: _guestCartItems[existingItemIndex].price,
            quantity: _guestCartItems[existingItemIndex].quantity + quantity,
            selectedColor: selectedColor,
            selectedSize: selectedSize,
            imageUrl: _guestCartItems[existingItemIndex].imageUrl,
            createdAt: _guestCartItems[existingItemIndex].createdAt,
            updatedAt: DateTime.now(),
          );
        } else {
          // Add new item (we'll need product details from somewhere)
          // For now, create a basic item - this should be improved
          final now = DateTime.now();
          final newItem = CartItem(
            id: now.millisecondsSinceEpoch.toString(),
            productId: productId,
            productName:
                'Product $productId', // This should come from product service
            price: 0.0, // This should come from product service
            quantity: quantity,
            selectedColor: selectedColor,
            selectedSize: selectedSize,
            imageUrl: '', // This should come from product service
            createdAt: now,
            updatedAt: now,
          );
          _guestCartItems.add(newItem);
        }

        _calculateGuestTotals();
        await _saveGuestCart();
        return;
      }

      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.post(
        '${ApiConfig.cartEndpoint}/items',
        body: {
          'productId': productId,
          'quantity': quantity,
          'selectedColor': selectedColor,
          'selectedSize': selectedSize,
        },
        headers: headers,
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
      if (!_isAuthenticated) {
        // Handle guest cart
        await _loadGuestCart();

        final itemIndex = _guestCartItems.indexWhere(
          (item) => item.id == cartItemId,
        );
        if (itemIndex != -1) {
          if (quantity <= 0) {
            _guestCartItems.removeAt(itemIndex);
          } else {
            _guestCartItems[itemIndex] = CartItem(
              id: _guestCartItems[itemIndex].id,
              productId: _guestCartItems[itemIndex].productId,
              productName: _guestCartItems[itemIndex].productName,
              price: _guestCartItems[itemIndex].price,
              quantity: quantity,
              selectedColor: _guestCartItems[itemIndex].selectedColor,
              selectedSize: _guestCartItems[itemIndex].selectedSize,
              imageUrl: _guestCartItems[itemIndex].imageUrl,
              createdAt: _guestCartItems[itemIndex].createdAt,
              updatedAt: DateTime.now(),
            );
          }
          _calculateGuestTotals();
          await _saveGuestCart();
        }
        return;
      }

      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.put(
        '${ApiConfig.cartEndpoint}/items/$cartItemId',
        body: {'quantity': quantity},
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      if (!_isAuthenticated) {
        // Handle guest cart
        await _loadGuestCart();

        _guestCartItems.removeWhere((item) => item.id == cartItemId);
        _calculateGuestTotals();
        await _saveGuestCart();
        return;
      }

      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.delete(
        '${ApiConfig.cartEndpoint}/items/$cartItemId',
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      if (!_isAuthenticated) {
        // Handle guest cart
        _guestCartItems.clear();
        _guestSubtotal = 0.0;
        _guestTax = 0.0;
        _guestShipping = 0.0;
        _guestTotal = 0.0;
        await _saveGuestCart();
        return;
      }

      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.delete(ApiConfig.cartEndpoint, headers: headers);
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final cart = await getCart();
      int total = 0;
      for (final item in cart.items) {
        total += item.quantity;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting cart item count: $e');
      return 0;
    }
  }

  /// Check if product is in cart
  Future<bool> isProductInCart(String productId) async {
    try {
      if (!_isAuthenticated) {
        await _loadGuestCart();
        return _guestCartItems.any((item) => item.productId == productId);
      }

      final cart = await getCart();
      return cart.items.any((item) => item.productId == productId);
    } catch (e) {
      debugPrint('Error checking if product in cart: $e');
      return false;
    }
  }

  /// Get cart item for specific product
  Future<CartItem?> getCartItemForProduct(String productId) async {
    try {
      if (!_isAuthenticated) {
        await _loadGuestCart();
        try {
          return _guestCartItems.firstWhere(
            (item) => item.productId == productId,
          );
        } catch (e) {
          return null;
        }
      }

      final cart = await getCart();
      try {
        return cart.items.firstWhere((item) => item.productId == productId);
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting cart item for product: $e');
      return null;
    }
  }
}
