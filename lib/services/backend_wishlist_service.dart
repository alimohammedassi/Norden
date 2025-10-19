import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/wishlist_item.dart';
import 'api_service.dart';
import 'backend_auth_service.dart';

// WishlistItem model is now imported from ../models/wishlist_item.dart

/// Wishlist service using the custom backend API
class BackendWishlistService {
  static final BackendWishlistService _instance =
      BackendWishlistService._internal();
  factory BackendWishlistService() => _instance;
  BackendWishlistService._internal();

  final BackendAuthService _authService = BackendAuthService();

  /// Get user's wishlist
  Future<List<WishlistItem>> getWishlist() async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.get(
        ApiConfig.wishlistEndpoint,
        headers: headers,
      );

      final List<dynamic> productsList = response['data'];

      return productsList
          .map((json) => WishlistItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting wishlist: $e');
      rethrow;
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.post(
        '${ApiConfig.wishlistEndpoint}/items',
        body: {'productId': productId},
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      rethrow;
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      await ApiService.delete(
        '${ApiConfig.wishlistEndpoint}/items/$productId',
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      rethrow;
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      final response = await ApiService.get(
        '${ApiConfig.wishlistEndpoint}/check/$productId',
        headers: headers,
      );

      final data = response['data'] as Map<String, dynamic>;
      return data['inWishlist'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking wishlist status: $e');
      return false;
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    try {
      final wishlist = await getWishlist();
      return wishlist.length;
    } catch (e) {
      debugPrint('Error getting wishlist count: $e');
      return 0;
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw ApiException('UNAUTHORIZED', 'User not authenticated');
      }

      // Get all items first
      final wishlist = await getWishlist();

      // Remove each item
      for (final item in wishlist) {
        await removeFromWishlist(item.id);
      }
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
      rethrow;
    }
  }

  /// Toggle wishlist status (add if not present, remove if present)
  Future<bool> toggleWishlist(String productId) async {
    try {
      final isInWishlist = await this.isInWishlist(productId);

      if (isInWishlist) {
        await removeFromWishlist(productId);
        return false;
      } else {
        await addToWishlist(productId);
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      rethrow;
    }
  }
}
