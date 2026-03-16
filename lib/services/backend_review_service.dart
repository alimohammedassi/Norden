import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/review.dart';
import 'api_service.dart';
import 'backend_auth_service.dart';

/// Review service specifically for the Norden Backend API
class BackendReviewService {
  static final BackendReviewService _instance = BackendReviewService._internal();
  factory BackendReviewService() => _instance;
  BackendReviewService._internal();

  final BackendAuthService _authService = BackendAuthService();

  /// Get reviews for a product
  Future<List<Review>> getProductReviews(String productId, {int page = 1, int limit = 10}) async {
    try {
      final url = '${ApiConfig.reviewsEndpoint}/products/$productId?page=$page&limit=$limit';
      final response = await ApiService.get(url);
      
      final data = response['data'];
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['reviews'] != null) {
        list = data['reviews'];
      }

      return list.map((json) => Review.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error getting product reviews: $e');
      return []; // Return empty list on error for better UI stability
    }
  }

  /// Create a review for a product
  Future<Review> createReview({
    required String productId,
    required int rating,
    required String title,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) throw ApiException('UNAUTHORIZED', 'No authentication token found');

      final response = await ApiService.post(
        '${ApiConfig.reviewsEndpoint}/products/$productId',
        headers: headers,
        body: {
          'rating': rating,
          'title': title,
          'comment': comment,
          'images': images,
        },
      );

      return Review.fromMap(response['data'] ?? response);
    } catch (e) {
      debugPrint('Error creating review: $e');
      rethrow;
    }
  }
}
