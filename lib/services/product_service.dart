import 'dart:async';
// ignore_for_file: unused_import
import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// Product service using local static data (no backend)
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<Product> _allProducts = Product.getSampleProducts();

  /// Get all products stream (periodic yield for UI compatibility)
  Stream<List<Product>> getProductsStream() async* {
    while (true) {
      yield _allProducts;
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  /// Admin: Add a new product locally
  Future<String> addProduct(Product product) async {
    final String newId = product.id.isNotEmpty
        ? product.id
        : DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    final newProduct = product.copyWith(
      id: newId,
      createdAt: product.createdAt,
      updatedAt: now,
    );
    _allProducts.add(newProduct);
    return newId;
  }

  /// Admin: Update an existing product locally
  Future<void> updateProduct(String id, Product product) async {
    final index = _allProducts.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _allProducts[index] = product.copyWith(id: id, updatedAt: DateTime.now());
    }
  }

  /// Admin: Delete a product locally
  Future<void> deleteProduct(String id) async {
    _allProducts.removeWhere((p) => p.id == id);
  }

  /// Get all products (one-time fetch)
  Future<List<Product>> getProducts() async {
    return _allProducts;
  }

  /// Get product by ID
  Future<Product?> getProduct(String id) async {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search products by name/description
  Future<List<Product>> searchProducts(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allProducts;
    return _allProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  /// Get new products
  Future<List<Product>> getNewProducts() async {
    return _allProducts.where((p) => p.isNew).toList();
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final c = category.trim().toLowerCase();
    return _allProducts.where((p) => p.category.toLowerCase() == c).toList();
  }

  /// Get available categories
  List<String> getCategories() {
    return _allProducts.map((p) => p.category).toSet().toList();
  }

  /// Get available colors (union of all)
  List<String> getColors() {
    return _allProducts.expand((p) => p.colors).toSet().toList();
  }

  /// Get available sizes (union of all)
  List<String> getSizes() {
    return _allProducts.expand((p) => p.sizes).toSet().toList();
  }
}
