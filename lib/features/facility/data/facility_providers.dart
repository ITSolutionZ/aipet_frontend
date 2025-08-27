import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/mock_data/mock_data_service.dart';
import '../domain/facility.dart';
import '../domain/repositories/facility_repository.dart';
import 'facility_repository_impl.dart';

part 'facility_providers.g.dart';

@riverpod
class FacilityListNotifier extends _$FacilityListNotifier {
  @override
  List<Facility> build() => MockDataService.getMockFacilities();

  void toggleFavorite(String facilityId) {
    state = state.map((facility) {
      if (facility.id == facilityId) {
        return facility.copyWith(isFavorite: !facility.isFavorite);
      }
      return facility;
    }).toList();
  }

  List<Facility> getFavorites() {
    return state.where((facility) => facility.isFavorite).toList();
  }

  List<Facility> getHistory() {
    return state.where((facility) => facility.hasHistory).toList();
  }

  List<Facility> getByType(FacilityType type) {
    return state.where((facility) => facility.type == type).toList();
  }

  List<Facility> search(String query) {
    if (query.isEmpty) return state;
    return state
        .where(
          (facility) =>
              facility.name.toLowerCase().contains(query.toLowerCase()) ||
              facility.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

@riverpod
class FacilityFilterNotifier extends _$FacilityFilterNotifier {
  @override
  String build() => 'All';

  void setFilter(String filter) {
    state = filter;
  }
}

@riverpod
class SearchQueryNotifier extends _$SearchQueryNotifier {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
class SearchResultsNotifier extends _$SearchResultsNotifier {
  @override
  List<Facility> build() => [];

  void setSearchResults(List<Facility> results) {
    state = results;
  }

  void clearSearchResults() {
    state = [];
  }

  void sortByDistance() {
    final sortedList = [...state];
    sortedList.sort((a, b) {
      // 거리 정보가 없으므로 주소 기준으로 정렬
      // 실제 구현에서는 현재 위치 기준 거리 계산 필요
      final distanceA = _calculateDistanceFromAddress(a.address);
      final distanceB = _calculateDistanceFromAddress(b.address);

      return distanceA.compareTo(distanceB);
    });
    state = sortedList;
  }

  /// 주소 기반 가상 거리 계산 (실제 구현에서는 GPS 좌표 기반 계산 필요)
  double _calculateDistanceFromAddress(String address) {
    // 임시로 주소 길이를 기준으로 가상 거리 생성
    // 실제로는 Geolocator 패키지를 사용해서 현재 위치와의 거리 계산
    return address.length.toDouble() * 0.1; // 0.1km ~ 수 km 범위
  }

  void sortByRating() {
    final sortedList = [...state];
    sortedList.sort((a, b) {
      // 평점이 높은 순으로 정렬 (내림차순)
      final ratingComparison = b.rating.compareTo(a.rating);
      if (ratingComparison != 0) return ratingComparison;

      // 평점이 같으면 리뷰 수가 많은 순으로 정렬
      return b.reviewCount.compareTo(a.reviewCount);
    });
    state = sortedList;
  }

  void sortByName() {
    final sortedList = [...state];
    sortedList.sort((a, b) {
      // 일본어와 영어 이름 정렬 지원
      return _compareNames(a.name, b.name);
    });
    state = sortedList;
  }

  /// 일본어와 영어 이름 비교 함수
  int _compareNames(String nameA, String nameB) {
    // 대소문자 무시하고 비교
    final normalizedA = nameA.toLowerCase();
    final normalizedB = nameB.toLowerCase();

    // 기본적으로 문자 순서로 정렬 (UTF-8 순서)
    // 일본어 히라가나, 카타카나, 한자도 올바르게 정렬됨
    return normalizedA.compareTo(normalizedB);
  }
}

@riverpod
class SelectedFacilityTypeNotifier extends _$SelectedFacilityTypeNotifier {
  @override
  FacilityType? build() => null;

  void setType(FacilityType? type) {
    state = type;
  }
}

@riverpod
class FacilityRepositoryNotifier extends _$FacilityRepositoryNotifier {
  @override
  FacilityRepository build() => FacilityRepositoryImpl();
}
