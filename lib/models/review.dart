class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userImageUrl;
  final int rating;
  final String title;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final int helpfulCount;
  final List<String> helpfulUsers;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.rating,
    required this.title,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.helpfulCount = 0,
    this.helpfulUsers = const [],
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      rating: map['rating'] ?? 0,
      title: map['title'] ?? '',
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isVerified: map['isVerified'] ?? false,
      helpfulCount: map['helpfulCount'] ?? 0,
      helpfulUsers: List<String>.from(map['helpfulUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'helpfulCount': helpfulCount,
      'helpfulUsers': helpfulUsers,
    };
  }

  Review copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userImageUrl,
    int? rating,
    String? title,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    int? helpfulCount,
    List<String>? helpfulUsers,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
    );
  }
}

class ProductRating {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count
  final List<Review> recentReviews;

  ProductRating({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    this.recentReviews = const [],
  });

  factory ProductRating.fromMap(Map<String, dynamic> map) {
    return ProductRating(
      productId: map['productId'] ?? '',
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(map['ratingDistribution'] ?? {}),
      recentReviews:
          (map['recentReviews'] as List<dynamic>?)
              ?.map((review) => Review.fromMap(review))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'recentReviews': recentReviews.map((review) => review.toMap()).toList(),
    };
  }
}
