import 'package:aipet_frontend/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/domain.dart';
import 'facility_repository_impl.dart';
import 'services/facility_local_storage_service.dart';

part 'facility_providers.g.dart';

@riverpod
class FacilityListNotifier extends _$FacilityListNotifier {
  @override
  Future<List<Facility>> build() async {
    try {
      // 로컬 저장소에서 시설 데이터 가져오기
      final facilitiesData = await FacilityLocalStorageService.getFacilities();
      final favorites = await FacilityLocalStorageService.getFavorites();
      final history = await FacilityLocalStorageService.getHistory();

      return facilitiesData.map((data) {
        final facilityId = data['id'] as String;
        return Facility(
          id: facilityId,
          name: data['name'] as String? ?? '',
          description: data['description'] as String? ?? '',
          address: data['address'] as String? ?? '',
          latitude: data['latitude'] as double? ?? 35.6762,
          longitude: data['longitude'] as double? ?? 139.6503,
          phone: data['phone'] as String?,
          email: data['email'] as String?,
          type: _convertStringToFacilityType(data['type'] as String?),
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: data['reviewCount'] as int? ?? 0,
          imagePath: data['imagePath'] as String?,
          isFavorite: favorites.contains(facilityId),
          hasHistory: history.contains(facilityId),
          lastVisit: data['lastVisit'] != null
              ? DateTime.parse(data['lastVisit'] as String)
              : null,
          isOpen: data['isOpen'] as bool? ?? true,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      // 에러 발생 시 빈 리스트 반환
      return [];
    }
  }

  /// 문자열을 FacilityType으로 변환
  FacilityType _convertStringToFacilityType(String? typeString) {
    switch (typeString) {
      case 'hospital':
        return FacilityType.hospital;
      case 'veterinary':
        return FacilityType.veterinary;
      case 'grooming':
        return FacilityType.grooming;
      case 'petShop':
        return FacilityType.petShop;
      case 'petStore':
        return FacilityType.petStore;
      case 'dogRun':
        return FacilityType.dogRun;
      case 'park':
        return FacilityType.park;
      case 'petPark':
        return FacilityType.petPark;
      case 'cafe':
        return FacilityType.cafe;
      case 'hotel':
        return FacilityType.hotel;
      case 'petFriendlyAccommodation':
        return FacilityType.petFriendlyAccommodation;
      case 'training':
        return FacilityType.training;
      default:
        return FacilityType.other;
    }
  }

  Future<void> toggleFavorite(String facilityId) async {
    // 로컬 저장소 업데이트
    await FacilityLocalStorageService.toggleFavorite(facilityId);

    // 상태 업데이트
    state.whenData((facilities) {
      state = AsyncValue.data(
        facilities.map((facility) {
          if (facility.id == facilityId) {
            return facility.copyWith(isFavorite: !facility.isFavorite);
          }
          return facility;
        }).toList(),
      );
    });
  }

  List<Facility> getFavorites() {
    return state.maybeWhen(
      data: (facilities) =>
          facilities.where((facility) => facility.isFavorite).toList(),
      orElse: () => [],
    );
  }

  List<Facility> getHistory() {
    return state.maybeWhen(
      data: (facilities) =>
          facilities.where((facility) => facility.hasHistory).toList(),
      orElse: () => [],
    );
  }

  List<Facility> getByType(FacilityType type) {
    return state.maybeWhen(
      data: (facilities) =>
          facilities.where((facility) => facility.type == type).toList(),
      orElse: () => [],
    );
  }

  List<Facility> search(String query) {
    return state.maybeWhen(
      data: (facilities) {
        if (query.isEmpty) return facilities;
        return facilities
            .where(
              (facility) =>
                  facility.name.toLowerCase().contains(query.toLowerCase()) ||
                  (facility.description?.toLowerCase() ?? '').contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      },
      orElse: () => [],
    );
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

/// 근처 시설 조회 Provider (Google Places API + 로컬 저장소)
@riverpod
Future<Result<List<Facility>>> nearbyFacilities(Ref ref) async {
  final repository = ref.watch(facilityRepositoryProvider);
  return repository.getNearbyFacilities();
}

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
@riverpod
Future<Result<List<Facility>>> facilitiesByType(
  Ref ref,
  FacilityType type,
) async {
  final repository = ref.watch(facilityRepositoryProvider);
  return repository.getFacilitiesByType(type);
}
