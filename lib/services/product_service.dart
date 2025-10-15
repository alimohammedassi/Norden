import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// Product service for Firebase Firestore operations
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Get all products stream
  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get all products (one-time fetch)
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<Product?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return Product.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      rethrow;
    }
  }

  /// Add new product
  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(
            product
                .copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now())
                .toMap(),
          );

      debugPrint('Product added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  /// Update existing product
  Future<void> updateProduct(String id, Product product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(product.copyWith(updatedAt: DateTime.now()).toMap());

      debugPrint('Product updated: $id');
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      debugPrint('Product deleted: $id');
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      rethrow;
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting featured products: $e');
      rethrow;
    }
  }

  /// Get new products
  Future<List<Product>> getNewProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isNew', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting new products: $e');
      rethrow;
    }
  }
}
