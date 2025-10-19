import 'package:flutter/foundation.dart';
import '../models/wishlist_item.dart';
import 'backend_wishlist_service.dart';

/// Wishlist service wrapper for backward compatibility
class WishlistService with ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final BackendWishlistService _backendWishlist = BackendWishlistService();

  // Local cache
  List<WishlistItem> _wishlistItems = [];
  Set<String> _wishlistProductIds = {};

  /// Get user's wishlist
  Future<List<WishlistItem>> getWishlist() async {
    try {
      return await _backendWishlist.getWishlist();
    } catch (e) {
      debugPrint('Error getting wishlist: $e');
      return [];
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    try {
      await _backendWishlist.addToWishlist(productId);
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      rethrow;
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _backendWishlist.removeFromWishlist(productId);
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      rethrow;
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      return await _backendWishlist.isInWishlist(productId);
    } catch (e) {
      debugPrint('Error checking wishlist status: $e');
      return false;
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    try {
      return await _backendWishlist.getWishlistCount();
    } catch (e) {
      debugPrint('Error getting wishlist count: $e');
      return 0;
    }
  }

  /// Check if product is in wishlist (synchronous version for UI)
  bool isInWishlistSync(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  /// Load wishlist data
  Future<void> loadWishlist() async {
    try {
      final wishlist = await _backendWishlist.getWishlist();
      _wishlistItems = wishlist;
      _wishlistProductIds = wishlist.map((item) => item.productId).toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      await _backendWishlist.clearWishlist();
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
      rethrow;
    }
  }

  /// Toggle wishlist status (add if not present, remove if present)
  Future<bool> toggleWishlist(String productId) async {
    try {
      return await _backendWishlist.toggleWishlist(productId);
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      rethrow;
    }
  }

  /// Get wishlist products stream (for UI compatibility)
  Stream<List<WishlistItem>> getWishlistProductsStream() async* {
    while (true) {
      try {
        yield _wishlistItems;
        await Future.delayed(
          const Duration(seconds: 5),
        ); // Poll every 5 seconds
      } catch (e) {
        debugPrint('Error in wishlist stream: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  /// Initialize wishlist service
  Future<void> initialize() async {
    await loadWishlist();
  }
}
