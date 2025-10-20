import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_item.dart';
import 'product_service.dart';

/// Wishlist service using local storage (no backend)
class WishlistService with ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  static const String _prefsKey = 'local_wishlist_v1';

  List<WishlistItem> _wishlistItems = [];
  Set<String> _wishlistProductIds = {};

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _wishlistItems.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(jsonList));
  }

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefsKey);
      _wishlistItems = [];
      if (data != null && data.isNotEmpty) {
        final List<dynamic> list = jsonDecode(data);
        _wishlistItems = list
            .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _wishlistProductIds = _wishlistItems.map((e) => e.productId).toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Wishlist load error: $e');
    }
  }

  Future<List<WishlistItem>> getWishlist() async {
    await loadWishlist();
    return _wishlistItems;
  }

  Future<void> addToWishlist(String productId) async {
    if (_wishlistProductIds.contains(productId)) return;
    final now = DateTime.now();
    // Try to enrich wishlist entry with product info
    final product = await ProductService().getProduct(productId);
    _wishlistItems.add(
      WishlistItem(
        id: 'w_$productId',
        productId: productId,
        productName: product?.name ?? 'Product',
        price: product?.price ?? 0.0,
        imageUrl: (product?.images.isNotEmpty == true)
            ? product!.images.first
            : '',
        category: product?.category ?? '',
        createdAt: now,
        updatedAt: now,
      ),
    );
    _wishlistProductIds.add(productId);
    await _persist();
    notifyListeners();
  }

  Future<void> removeFromWishlist(String productId) async {
    _wishlistItems.removeWhere((e) => e.productId == productId);
    _wishlistProductIds.remove(productId);
    await _persist();
    notifyListeners();
  }

  Future<bool> isInWishlist(String productId) async {
    await loadWishlist();
    return _wishlistProductIds.contains(productId);
  }

  int getWishlistCountSync() => _wishlistItems.length;

  Future<int> getWishlistCount() async {
    await loadWishlist();
    return _wishlistItems.length;
  }

  bool isInWishlistSync(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  Future<void> clearWishlist() async {
    _wishlistItems.clear();
    _wishlistProductIds.clear();
    await _persist();
    notifyListeners();
  }

  Future<bool> toggleWishlist(String productId) async {
    if (_wishlistProductIds.contains(productId)) {
      await removeFromWishlist(productId);
      return false;
    } else {
      await addToWishlist(productId);
      return true;
    }
  }

  Stream<List<WishlistItem>> getWishlistProductsStream() async* {
    while (true) {
      yield _wishlistItems;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> initialize() async {
    await loadWishlist();
  }
}
