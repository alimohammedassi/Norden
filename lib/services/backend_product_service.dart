import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'backend_auth_service.dart';

/// Product service using the custom backend API
class BackendProductService {
  static final BackendProductService _instance =
      BackendProductService._internal();
  factory BackendProductService() => _instance;
  BackendProductService._internal();

  final BackendAuthService _authService = BackendAuthService();

  /// Get all products with optional filters
  Future<List<Product>> getProducts({
    String? category,
    bool? isFeatured,
    bool? isNew,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (isFeatured != null) queryParams['isFeatured'] = isFeatured.toString();
      if (isNew != null) queryParams['isNew'] = isNew.toString();

      final uri = Uri.parse(
        ApiConfig.productsEndpoint,
      ).replace(queryParameters: queryParams);

      final response = await ApiService.get(uri.toString());
      final data = response['data'] as Map<String, dynamic>;
      final productsList = data['products'] as List<dynamic>;

      return productsList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<Product> getProduct(String id) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.productsEndpoint}/$id',
      );
      final data = response['data'] as Map<String, dynamic>;

      return Product.fromJson(data);
    } catch (e) {
      debugPrint('Error getting product: $e');
      rethrow;
    }
  }

  /// Search products
  Future<List<Product>> searchProducts({
    required String query,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse(
        '${ApiConfig.productsEndpoint}/search',
      ).replace(queryParameters: queryParams);

      final response = await ApiService.get(uri.toString());
      final data = response['data'] as Map<String, dynamic>;
      final productsList = data['products'] as List<dynamic>;

      return productsList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      rethrow;
    }
  }

  /// Get products stream (for real-time updates)
  /// Note: This is a simplified version since REST APIs don't have real-time streams
  /// You might want to implement polling or WebSocket connection for real-time updates
  Stream<List<Product>> getProductsStream({
    String? category,
    bool? isFeatured,
    bool? isNew,
    int limit = 50,
  }) async* {
    while (true) {
      try {
        final products = await getProducts(
          category: category,
          isFeatured: isFeatured,
          isNew: isNew,
          limit: limit,
        );
        yield products;

        // Poll every 30 seconds
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        debugPrint('Error in products stream: $e');
        // Continue polling even if there's an error
        await Future.delayed(const Duration(seconds: 30));
      }
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    return getProducts(isFeatured: true, limit: limit);
  }

  /// Get new products
  Future<List<Product>> getNewProducts({int limit = 10}) async {
    return getProducts(isNew: true, limit: limit);
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(
    String category, {
    int limit = 50,
    int offset = 0,
  }) async {
    return getProducts(category: category, limit: limit, offset: offset);
  }

  /// Get available categories
  List<String> getCategories() {
    return ['Coats', 'Blazers', 'DressShirts', 'Trousers', 'Accessories'];
  }

  /// Get available colors
  List<String> getColors() {
    return ['Black', 'Navy', 'Gray', 'White', 'Brown', 'Beige', 'Blue', 'Red'];
  }

  /// Get available sizes
  List<String> getSizes() {
    return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  }
}
