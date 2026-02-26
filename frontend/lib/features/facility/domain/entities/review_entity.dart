/// Google Places API 리뷰 엔티티
class Review {
  final String authorName;
  final String? authorPhotoUrl;
  final double rating;
  final String text;
  final String relativeTimeDescription;
  final int time; // Unix timestamp

  const Review({
    required this.authorName,
    this.authorPhotoUrl,
    required this.rating,
    required this.text,
    required this.relativeTimeDescription,
    required this.time,
  });

  /// JSON에서 Review 생성
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] as String? ?? '匿名',
      authorPhotoUrl: json['profile_photo_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      relativeTimeDescription:
          json['relative_time_description'] as String? ?? '',
      time: json['time'] as int? ?? 0,
    );
  }

  /// Review를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'author_name': authorName,
      'profile_photo_url': authorPhotoUrl,
      'rating': rating,
      'text': text,
      'relative_time_description': relativeTimeDescription,
      'time': time,
    };
  }

  /// 평점을 별 문자열로 변환
  String get ratingStars {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';
    stars += '☆' * (5 - fullStars - (hasHalfStar ? 1 : 0));

    return stars;
  }

  /// 평점 포맷팅
  String get formattedRating => rating.toStringAsFixed(1);

  /// 리뷰 텍스트 요약 (긴 경우)
  String getSummary({int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// 시설 리뷰 정보 (평점 + 리뷰 목록)
class FacilityReviews {
  final double averageRating;
  final int totalReviews;
  final List<Review> reviews;

  const FacilityReviews({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  /// 빈 리뷰 정보
  static const empty = FacilityReviews(
    averageRating: 0,
    totalReviews: 0,
    reviews: [],
  );

  /// JSON에서 FacilityReviews 생성
  factory FacilityReviews.fromPlaceDetails(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List<dynamic>?)
            ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    return FacilityReviews(
      averageRating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['user_ratings_total'] as int? ?? reviewsList.length,
      reviews: reviewsList,
    );
  }

  /// 평점별 리뷰 수 계산
  Map<int, int> get ratingDistribution {
    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      final roundedRating = review.rating.round().clamp(1, 5);
      distribution[roundedRating] = (distribution[roundedRating] ?? 0) + 1;
    }
    return distribution;
  }

  /// 평점 포맷팅
  String get formattedRating => averageRating.toStringAsFixed(1);
}
