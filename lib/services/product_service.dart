import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'backend_product_service.dart';

/// Product service wrapper for backward compatibility
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final BackendProductService _backendProduct = BackendProductService();

  /// Get all products stream
  Stream<List<Product>> getProductsStream() {
    return _backendProduct.getProductsStream();
  }

  /// Get all products (one-time fetch)
  Future<List<Product>> getProducts() async {
    try {
      return await _backendProduct.getProducts();
    } catch (e) {
      debugPrint('Error getting products: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<Product?> getProduct(String id) async {
    try {
      return await _backendProduct.getProduct(id);
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  /// Add new product (Admin only)
  Future<String> addProduct(Product product) async {
    // Note: This would need to be implemented in the backend API
    // For now, throw an exception
    throw UnimplementedError(
      'Product creation not yet implemented in backend API',
    );
  }

  /// Update product (Admin only)
  Future<void> updateProduct(String id, Product product) async {
    // Note: This would need to be implemented in the backend API
    // For now, throw an exception
    throw UnimplementedError(
      'Product update not yet implemented in backend API',
    );
  }

  /// Delete product (Admin only)
  Future<void> deleteProduct(String id) async {
    // Note: This would need to be implemented in the backend API
    // For now, throw an exception
    throw UnimplementedError(
      'Product deletion not yet implemented in backend API',
    );
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _backendProduct.searchProducts(query: query);
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      return await _backendProduct.getFeaturedProducts();
    } catch (e) {
      debugPrint('Error getting featured products: $e');
      return [];
    }
  }

  /// Get new products
  Future<List<Product>> getNewProducts() async {
    try {
      return await _backendProduct.getNewProducts();
    } catch (e) {
      debugPrint('Error getting new products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await _backendProduct.getProductsByCategory(category);
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  /// Get available categories
  List<String> getCategories() {
    return _backendProduct.getCategories();
  }

  /// Get available colors
  List<String> getColors() {
    return _backendProduct.getColors();
  }

  /// Get available sizes
  List<String> getSizes() {
    return _backendProduct.getSizes();
  }
}
