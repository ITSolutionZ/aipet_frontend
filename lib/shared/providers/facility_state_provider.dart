import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Facility 통합 상태 관리
///
/// 모든 Facility 관련 상태를 중앙화하여
/// 일관성과 효율성을 향상시킵니다.
class FacilityState {
  final List<Facility> facilities;
  final List<Facility> filteredFacilities;
  final String searchQuery;
  final FacilityType? selectedType;
  final String currentFilter;
  final bool isLoading;
  final String? error;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentAddress;
  final String sortBy;
  final bool showFavoritesOnly;
  final bool showHistoryOnly;
  final bool showOpenOnly;
  final double minRating;

  const FacilityState({
    this.facilities = const [],
    this.filteredFacilities = const [],
    this.searchQuery = '',
    this.selectedType,
    this.currentFilter = 'All',
    this.isLoading = false,
    this.error,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAddress,
    this.sortBy = 'name',
    this.showFavoritesOnly = false,
    this.showHistoryOnly = false,
    this.showOpenOnly = false,
    this.minRating = 0.0,
  });

  FacilityState copyWith({
    List<Facility>? facilities,
    List<Facility>? filteredFacilities,
    String? searchQuery,
    FacilityType? selectedType,
    String? currentFilter,
    bool? isLoading,
    String? error,
    double? currentLatitude,
    double? currentLongitude,
    String? currentAddress,
    String? sortBy,
    bool? showFavoritesOnly,
    bool? showHistoryOnly,
    bool? showOpenOnly,
    double? minRating,
  }) {
    return FacilityState(
      facilities: facilities ?? this.facilities,
      filteredFacilities: filteredFacilities ?? this.filteredFacilities,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentAddress: currentAddress ?? this.currentAddress,
      sortBy: sortBy ?? this.sortBy,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      showHistoryOnly: showHistoryOnly ?? this.showHistoryOnly,
      showOpenOnly: showOpenOnly ?? this.showOpenOnly,
      minRating: minRating ?? this.minRating,
    );
  }

  /// 현재 위치가 설정되어 있는지 확인
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  /// 필터가 적용되어 있는지 확인
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedType != null ||
      showFavoritesOnly ||
      showHistoryOnly ||
      showOpenOnly ||
      minRating > 0.0;

  /// 데이터가 있는지 확인
  bool get hasData => facilities.isNotEmpty;

  /// 에러가 있는지 확인
  bool get hasError => error != null;

  /// 로딩 중인지 확인
  bool get isBusy => isLoading;

  /// 필터링된 결과가 있는지 확인
  bool get hasFilteredResults => filteredFacilities.isNotEmpty;
}

/// Facility 상태 프로바이더
final facilityStateProvider =
    StateNotifierProvider<FacilityStateNotifier, FacilityState>(
      (ref) => FacilityStateNotifier(),
    );

/// Facility 상태 관리자
class FacilityStateNotifier extends StateNotifier<FacilityState> {
  FacilityStateNotifier() : super(const FacilityState());

  /// 시설 리스트 설정
  void setFacilities(List<Facility> facilities) {
    state = state.copyWith(
      facilities: facilities,
      filteredFacilities: facilities,
      isLoading: false,
      error: null,
    );
  }

  /// 검색어 설정
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// 타입 필터 설정
  void setSelectedType(FacilityType? type) {
    state = state.copyWith(selectedType: type);
    _applyFilters();
  }

  /// 현재 필터 설정
  void setCurrentFilter(String filter) {
    state = state.copyWith(currentFilter: filter);
    _applyFilters();
  }

  /// 정렬 방식 설정
  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applyFilters();
  }

  /// 즐겨찾기 필터 토글
  void toggleFavoritesFilter() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
    _applyFilters();
  }

  /// 히스토리 필터 토글
  void toggleHistoryFilter() {
    state = state.copyWith(showHistoryOnly: !state.showHistoryOnly);
    _applyFilters();
  }

  /// 영업 중 필터 토글
  void toggleOpenFilter() {
    state = state.copyWith(showOpenOnly: !state.showOpenOnly);
    _applyFilters();
  }

  /// 최소 평점 설정
  void setMinRating(double rating) {
    state = state.copyWith(minRating: rating);
    _applyFilters();
  }

  /// 현재 위치 설정
  void setCurrentLocation(double latitude, double longitude, String address) {
    state = state.copyWith(
      currentLatitude: latitude,
      currentLongitude: longitude,
      currentAddress: address,
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 모든 필터 초기화
  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedType: null,
      currentFilter: 'All',
      showFavoritesOnly: false,
      showHistoryOnly: false,
      showOpenOnly: false,
      minRating: 0.0,
      sortBy: 'name',
    );
    _applyFilters();
  }

  /// 즐겨찾기 토글
  void toggleFavorite(String facilityId) {
    final updatedFacilities = state.facilities.map((facility) {
      if (facility.id == facilityId) {
        return facility.copyWith(isFavorite: !facility.isFavorite);
      }
      return facility;
    }).toList();

    state = state.copyWith(facilities: updatedFacilities);
    _applyFilters();
  }

  /// 필터 적용
  void _applyFilters() {
    // TODO: FacilitySearchService를 사용하여 필터링 로직 구현
    // 현재는 기본 구현
    state = state.copyWith(filteredFacilities: state.facilities);
  }

  /// 시설 추가
  void addFacility(Facility facility) {
    final updatedFacilities = [...state.facilities, facility];
    state = state.copyWith(facilities: updatedFacilities);
    _applyFilters();
  }

  /// 시설 업데이트
  void updateFacility(Facility updatedFacility) {
    final updatedFacilities = state.facilities.map((facility) {
      if (facility.id == updatedFacility.id) {
        return updatedFacility;
      }
      return facility;
    }).toList();

    state = state.copyWith(facilities: updatedFacilities);
    _applyFilters();
  }

  /// 시설 삭제
  void removeFacility(String facilityId) {
    final updatedFacilities = state.facilities
        .where((facility) => facility.id != facilityId)
        .toList();

    state = state.copyWith(facilities: updatedFacilities);
    _applyFilters();
  }
}
