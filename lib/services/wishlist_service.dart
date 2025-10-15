import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage user wishlist
class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<String> _wishlistProductIds = {};
  Set<String> get wishlistProductIds => _wishlistProductIds;

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  /// Load wishlist for current user
  Future<void> loadWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('wishlists').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['productIds'] != null) {
          _wishlistProductIds = Set<String>.from(data['productIds'] as List);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _wishlistProductIds.add(productId);
      notifyListeners();

      await _firestore.collection('wishlists').doc(user.uid).set({
        'productIds': _wishlistProductIds.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      _wishlistProductIds.remove(productId);
      notifyListeners();
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _wishlistProductIds.remove(productId);
      notifyListeners();

      await _firestore.collection('wishlists').doc(user.uid).set({
        'productIds': _wishlistProductIds.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      _wishlistProductIds.add(productId);
      notifyListeners();
    }
  }

  /// Toggle product in wishlist
  Future<void> toggleWishlist(String productId) async {
    if (isInWishlist(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  /// Get wishlist products stream
  Stream<List<Map<String, dynamic>>> getWishlistProductsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Wishlist: No user logged in');
      return Stream.value([]);
    }

    debugPrint('Wishlist: Fetching for user ${user.uid}');
    return _firestore
        .collection('wishlists')
        .doc(user.uid)
        .snapshots()
        .asyncMap((wishlistDoc) async {
          debugPrint('Wishlist: Document exists: ${wishlistDoc.exists}');
          if (!wishlistDoc.exists) {
            _wishlistProductIds.clear();
            notifyListeners();
            return [];
          }

          final data = wishlistDoc.data();
          debugPrint('Wishlist: Document data: $data');
          if (data == null || data['productIds'] == null) {
            _wishlistProductIds.clear();
            notifyListeners();
            return [];
          }

          final productIds = List<String>.from(data['productIds'] as List);
          debugPrint('Wishlist: Product IDs: $productIds');
          // Sync local state with Firestore
          _wishlistProductIds = Set<String>.from(productIds);
          notifyListeners();

          if (productIds.isEmpty) return [];

          // Fetch products
          final products = <Map<String, dynamic>>[];
          for (final productId in productIds) {
            try {
              debugPrint('Wishlist: Fetching product $productId');
              final productDoc = await _firestore
                  .collection('products')
                  .doc(productId)
                  .get();
              debugPrint('Wishlist: Product exists: ${productDoc.exists}');
              if (productDoc.exists) {
                final productData = productDoc.data();
                debugPrint('Wishlist: Product data: $productData');
                if (productData != null) {
                  products.add({...productData, 'id': productDoc.id});
                }
              } else {
                debugPrint(
                  'Wishlist: Product $productId not found in Firestore',
                );
              }
            } catch (e) {
              debugPrint('Error fetching product $productId: $e');
            }
          }

          debugPrint('Wishlist: Total products fetched: ${products.length}');
          return products;
        });
  }

  /// Clear wishlist
  Future<void> clearWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _wishlistProductIds.clear();
      notifyListeners();

      await _firestore.collection('wishlists').doc(user.uid).delete();
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
    }
  }

  /// Clear local state (for sign out)
  void clearLocalState() {
    _wishlistProductIds.clear();
    notifyListeners();
  }
}
