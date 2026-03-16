import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'backend_auth_service.dart';

/// Service to handle orders specifically for the Norden Backend API
class BackendOrderService {
  static final BackendOrderService _instance = BackendOrderService._internal();
  factory BackendOrderService() => _instance;
  BackendOrderService._internal();

  final BackendAuthService _authService = BackendAuthService();

  /// Get list of orders for the current user
  Future<List<Map<String, dynamic>>> getOrders({int page = 1, int limit = 10}) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) throw ApiException('UNAUTHORIZED', 'No authentication token found');

      final url = '${ApiConfig.ordersEndpoint}?page=$page&limit=$limit';
      final response = await ApiService.get(url, headers: headers);
      
      final data = response['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['orders'] != null) {
        return List<Map<String, dynamic>>.from(data['orders']);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting orders: $e');
      rethrow;
    }
  }

  /// Create a new order
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) throw ApiException('UNAUTHORIZED', 'No authentication token found');

      final response = await ApiService.post(
        ApiConfig.ordersEndpoint,
        headers: headers,
        body: {
          'items': items,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          if (notes != null) 'notes': notes,
        },
      );

      return response['data'] ?? response;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Get order details by ID
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) throw ApiException('UNAUTHORIZED', 'No authentication token found');

      final response = await ApiService.get(
        '${ApiConfig.ordersEndpoint}/$orderId',
        headers: headers,
      );

      return response['data'] ?? response;
    } catch (e) {
      debugPrint('Error getting order details: $e');
      rethrow;
    }
  }
}
