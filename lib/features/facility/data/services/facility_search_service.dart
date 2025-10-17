import 'dart:math';

import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';

/// 🎯 Facility 검색/필터링 통합 서비스
///
/// 모든 Facility 관련 검색, 필터링, 정렬 로직을 중앙화하여
/// 일관성과 재사용성을 향상시킵니다.
class FacilitySearchService {
  /// 기본 검색 (이름, 설명, 주소)
  static List<Facility> search(List<Facility> facilities, String query) {
    if (query.isEmpty) return facilities;

    final lowerQuery = query.toLowerCase();
    return facilities
        .where(
          (facility) =>
              facility.name.toLowerCase().contains(lowerQuery) ||
              (facility.description?.toLowerCase() ?? '').contains(lowerQuery) ||
              facility.address.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// 고급 검색 (여러 필드 지원)
  static List<Facility> advancedSearch(
    List<Facility> facilities,
    String query, {
    List<String> searchFields = const ['name', 'description', 'address'],
  }) {
    if (query.isEmpty) return facilities;

    final lowerQuery = query.toLowerCase();
    return facilities.where((facility) {
      for (final field in searchFields) {
        switch (field) {
          case 'name':
            if (facility.name.toLowerCase().contains(lowerQuery)) return true;
            break;
          case 'description':
            if ((facility.description?.toLowerCase() ?? '').contains(lowerQuery)) {
              return true;
            }
            break;
          case 'address':
            if (facility.address.toLowerCase().contains(lowerQuery)) {
              return true;
            }
            break;
          case 'phone':
            if ((facility.phone?.toLowerCase() ?? '').contains(lowerQuery)) {
              return true;
            }
            break;
          case 'email':
            if ((facility.email?.toLowerCase() ?? '').contains(lowerQuery)) {
              return true;
            }
            break;
        }
      }
      return false;
    }).toList();
  }

  /// 타입별 필터링
  static List<Facility> filterByType(List<Facility> facilities, FacilityType? type) {
    if (type == null) return facilities;
    return facilities.where((facility) => facility.type == type).toList();
  }

  /// 즐겨찾기 필터링
  static List<Facility> filterFavorites(List<Facility> facilities) {
    return facilities.where((facility) => facility.isFavorite).toList();
  }

  /// 히스토리 필터링
  static List<Facility> filterWithHistory(List<Facility> facilities) {
    return facilities.where((facility) => facility.hasHistory).toList();
  }

  /// 영업 중인 시설만 필터링
  static List<Facility> filterOpen(List<Facility> facilities) {
    return facilities.where((facility) => facility.isOpen).toList();
  }

  /// 평점별 필터링
  static List<Facility> filterByRating(List<Facility> facilities, double minRating) {
    return facilities.where((facility) => facility.rating >= minRating).toList();
  }

  /// 거리별 정렬 (현재 위치 기준)
  static List<Facility> sortByDistance(
    List<Facility> facilities,
    double currentLatitude,
    double currentLongitude,
  ) {
    final sortedList = [...facilities];
    sortedList.sort((a, b) {
      final distanceA = _calculateDistance(
        currentLatitude,
        currentLongitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = _calculateDistance(
        currentLatitude,
        currentLongitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    return sortedList;
  }

  /// 평점별 정렬
  static List<Facility> sortByRating(List<Facility> facilities) {
    final sortedList = [...facilities];
    sortedList.sort((a, b) {
      final ratingComparison = b.rating.compareTo(a.rating);
      if (ratingComparison != 0) return ratingComparison;
      return b.reviewCount.compareTo(a.reviewCount);
    });
    return sortedList;
  }

  /// 이름별 정렬
  static List<Facility> sortByName(List<Facility> facilities) {
    final sortedList = [...facilities];
    sortedList.sort((a, b) => a.name.compareTo(b.name));
    return sortedList;
  }

  /// 리뷰 수별 정렬
  static List<Facility> sortByReviewCount(List<Facility> facilities) {
    final sortedList = [...facilities];
    sortedList.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sortedList;
  }

  /// 통합 필터링 및 정렬
  static List<Facility> filterAndSort(
    List<Facility> facilities, {
    String? searchQuery,
    FacilityType? type,
    bool? favoritesOnly,
    bool? historyOnly,
    bool? openOnly,
    double? minRating,
    String? sortBy,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    List<Facility> result = facilities;

    // 검색
    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = search(result, searchQuery);
    }

    // 타입 필터
    if (type != null) {
      result = filterByType(result, type);
    }

    // 즐겨찾기 필터
    if (favoritesOnly == true) {
      result = filterFavorites(result);
    }

    // 히스토리 필터
    if (historyOnly == true) {
      result = filterWithHistory(result);
    }

    // 영업 중 필터
    if (openOnly == true) {
      result = filterOpen(result);
    }

    // 평점 필터
    if (minRating != null) {
      result = filterByRating(result, minRating);
    }

    // 정렬
    if (sortBy != null) {
      switch (sortBy) {
        case 'distance':
          if (currentLatitude != null && currentLongitude != null) {
            result = sortByDistance(result, currentLatitude, currentLongitude);
          }
          break;
        case 'rating':
          result = sortByRating(result);
          break;
        case 'name':
          result = sortByName(result);
          break;
        case 'reviewCount':
          result = sortByReviewCount(result);
          break;
      }
    }

    return result;
  }

  /// 거리 계산 (Haversine 공식)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
