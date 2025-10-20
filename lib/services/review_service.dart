import '../models/review.dart';

class ReviewService {
  // TODO: Replace with Firebase Firestore when backend is ready
  final String _reviewsCollection = 'reviews';
  final String _ratingsCollection = 'product_ratings';

  // Mock data for now - will be replaced with Firebase calls
  static final List<Review> _mockReviews = [
    Review(
      id: '1',
      productId: '1',
      userId: 'user1',
      userName: 'Ahmed Ali',
      userImageUrl: '',
      rating: 5,
      title: 'Excellent quality!',
      comment: 'This product exceeded my expectations. The quality is amazing and the delivery was fast.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isVerified: true,
      helpfulCount: 12,
    ),
    Review(
      id: '2',
      productId: '1',
      userId: 'user2',
      userName: 'Sara Mohamed',
      userImageUrl: '',
      rating: 4,
      title: 'Good product',
      comment: 'Nice quality, but could be better. Overall satisfied with the purchase.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isVerified: false,
      helpfulCount: 8,
    ),
  ];

  static final Map<String, ProductRating> _mockRatings = {
    '1': ProductRating(
      productId: '1',
      averageRating: 4.5,
      totalReviews: 2,
      ratingDistribution: {5: 1, 4: 1, 3: 0, 2: 0, 1: 0},
    ),
  };

  /// Get all reviews for a product
  Future<List<Review>> getProductReviews(String productId, {
    int limit = 10,
    dynamic startAfter,
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final reviews = _mockReviews
          .where((review) => review.productId == productId)
          .toList();
      
      if (descending) {
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
      
      return reviews.take(limit).toList();
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  /// Get product rating summary
  Future<ProductRating?> getProductRating(String productId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _mockRatings[productId];
    } catch (e) {
      print('Error getting product rating: $e');
      return null;
    }
  }

  /// Add a new review
  Future<bool> addReview(Review review) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      _mockReviews.add(review);
      await _updateProductRating(review.productId);
      
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  /// Update an existing review
  Future<bool> updateReview(String reviewId, Review updatedReview) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      final index = _mockReviews.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        _mockReviews[index] = updatedReview;
        await _updateProductRating(updatedReview.productId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId, String productId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      _mockReviews.removeWhere((review) => review.id == reviewId);
      await _updateProductRating(productId);
      
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  /// Mark review as helpful
  Future<bool> markReviewHelpful(String reviewId, String userId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final reviewIndex = _mockReviews.indexWhere((review) => review.id == reviewId);
      if (reviewIndex != -1) {
        final review = _mockReviews[reviewIndex];
        final helpfulUsers = List<String>.from(review.helpfulUsers);
        
        if (helpfulUsers.contains(userId)) {
          helpfulUsers.remove(userId);
        } else {
          helpfulUsers.add(userId);
        }
        
        _mockReviews[reviewIndex] = review.copyWith(
          helpfulUsers: helpfulUsers,
          helpfulCount: helpfulUsers.length,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking review helpful: $e');
      return false;
    }
  }

  /// Check if user has reviewed a product
  Future<Review?> getUserReviewForProduct(String userId, String productId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final review = _mockReviews
          .where((review) => review.userId == userId && review.productId == productId)
          .firstOrNull;
      
      return review;
    } catch (e) {
      print('Error checking user review: $e');
      return null;
    }
  }

  /// Get user's reviews
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final reviews = _mockReviews
          .where((review) => review.userId == userId)
          .toList();
      
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      print('Error getting user reviews: $e');
      return [];
    }
  }

  /// Update product rating summary (internal method)
  Future<void> _updateProductRating(String productId) async {
    try {
      final reviews = _mockReviews
          .where((review) => review.productId == productId)
          .toList();

      if (reviews.isEmpty) {
        _mockRatings.remove(productId);
        return;
      }

      double totalRating = 0;
      Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final review in reviews) {
        totalRating += review.rating;
        ratingDistribution[review.rating] = (ratingDistribution[review.rating] ?? 0) + 1;
      }

      final averageRating = totalRating / reviews.length;
      final totalReviews = reviews.length;

      _mockRatings[productId] = ProductRating(
        productId: productId,
        averageRating: averageRating,
        totalReviews: totalReviews,
        ratingDistribution: ratingDistribution,
        recentReviews: reviews.take(5).toList(),
      );
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }

  /// Get top rated products
  Future<List<String>> getTopRatedProducts({int limit = 10}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final sortedRatings = _mockRatings.values.toList()
        ..sort((a, b) {
          if (a.averageRating != b.averageRating) {
            return b.averageRating.compareTo(a.averageRating);
          }
          return b.totalReviews.compareTo(a.totalReviews);
        });
      
      return sortedRatings
          .take(limit)
          .map((rating) => rating.productId)
          .toList();
    } catch (e) {
      print('Error getting top rated products: $e');
      return [];
    }
  }
}