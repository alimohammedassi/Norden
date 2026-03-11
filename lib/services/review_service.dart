import '../models/review.dart';

class ReviewService {
  // In-memory store — persists for the app session.
  // Seed with two sample reviews so the UI is never empty on first load.
  static final List<Review> _mockReviews = [
    Review(
      id: 'r_seed_1',
      productId: '1',
      userId: 'seed_user1',
      userName: 'Ahmed Ali',
      userImageUrl: '',
      rating: 5,
      title: 'Excellent quality!',
      comment:
          'This product exceeded my expectations. The quality is amazing and the delivery was fast.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isVerified: true,
      helpfulCount: 12,
    ),
    Review(
      id: 'r_seed_2',
      productId: '1',
      userId: 'seed_user2',
      userName: 'Sara Mohamed',
      userImageUrl: '',
      rating: 4,
      title: 'Good product',
      comment:
          'Nice quality, but could be better. Overall satisfied with the purchase.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isVerified: false,
      helpfulCount: 8,
    ),
  ];

  // Ratings cache — rebuilt automatically when reviews change.
  static final Map<String, ProductRating> _ratingsCache = {};

  ReviewService() {
    // Ensure the seed data is reflected in the ratings cache on first use.
    if (_ratingsCache.isEmpty) {
      _rebuildAllRatings();
    }
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Get all reviews for a product (optionally filtered / sorted).
  Future<List<Review>> getProductReviews(
    String productId, {
    int limit = 20,
    dynamic startAfter,
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final reviews =
        _mockReviews.where((r) => r.productId == productId).toList();

    if (descending) {
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return reviews.take(limit).toList();
  }

  /// Get the rating summary for a product.
  /// Returns an empty ProductRating (0 reviews) instead of null so the UI
  /// always has a valid object to work with.
  Future<ProductRating> getProductRating(String productId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _ratingsCache[productId] ??
        ProductRating(
          productId: productId,
          averageRating: 0,
          totalReviews: 0,
          ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        );
  }

  /// Add a new review. Returns true on success.
  Future<bool> addReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Prevent duplicate: one review per user per product.
    final existing = _mockReviews.where(
      (r) => r.userId == review.userId && r.productId == review.productId,
    );
    if (existing.isNotEmpty) {
      // Update existing instead of adding a duplicate.
      final idx = _mockReviews.indexWhere(
        (r) => r.userId == review.userId && r.productId == review.productId,
      );
      _mockReviews[idx] = review;
    } else {
      _mockReviews.add(review);
    }

    _updateProductRating(review.productId);
    return true;
  }

  /// Update an existing review.
  Future<bool> updateReview(String reviewId, Review updatedReview) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockReviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _mockReviews[index] = updatedReview;
      _updateProductRating(updatedReview.productId);
      return true;
    }
    return false;
  }

  /// Delete a review.
  Future<bool> deleteReview(String reviewId, String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    _mockReviews.removeWhere((r) => r.id == reviewId);
    _updateProductRating(productId);
    return true;
  }

  /// Toggle "helpful" on a review for the given user.
  Future<bool> markReviewHelpful(String reviewId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _mockReviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;

    final review = _mockReviews[index];
    final helpfulUsers = List<String>.from(review.helpfulUsers);

    if (helpfulUsers.contains(userId)) {
      helpfulUsers.remove(userId);
    } else {
      helpfulUsers.add(userId);
    }

    _mockReviews[index] = review.copyWith(
      helpfulUsers: helpfulUsers,
      helpfulCount: helpfulUsers.length,
    );
    return true;
  }

  /// Return the review the given user wrote for the given product, or null.
  Future<Review?> getUserReviewForProduct(
    String userId,
    String productId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _mockReviews
        .where((r) => r.userId == userId && r.productId == productId)
        .firstOrNull;
  }

  /// Return all reviews written by the given user.
  Future<List<Review>> getUserReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final reviews = _mockReviews.where((r) => r.userId == userId).toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  /// Return the IDs of the top-rated products.
  Future<List<String>> getTopRatedProducts({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final sorted = _ratingsCache.values.toList()
      ..sort((a, b) {
        if (a.averageRating != b.averageRating) {
          return b.averageRating.compareTo(a.averageRating);
        }
        return b.totalReviews.compareTo(a.totalReviews);
      });

    return sorted.take(limit).map((r) => r.productId).toList();
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  void _updateProductRating(String productId) {
    final reviews = _mockReviews.where((r) => r.productId == productId).toList();

    if (reviews.isEmpty) {
      _ratingsCache.remove(productId);
      return;
    }

    double total = 0;
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final r in reviews) {
      total += r.rating;
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }

    _ratingsCache[productId] = ProductRating(
      productId: productId,
      averageRating: total / reviews.length,
      totalReviews: reviews.length,
      ratingDistribution: dist,
      recentReviews: reviews.take(5).toList(),
    );
  }

  void _rebuildAllRatings() {
    final productIds = _mockReviews.map((r) => r.productId).toSet();
    for (final id in productIds) {
      _updateProductRating(id);
    }
  }
}
