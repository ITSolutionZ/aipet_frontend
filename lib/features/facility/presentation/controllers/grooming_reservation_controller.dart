import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 그루밍 예약 화면의 상태 데이터
class GroomingReservationState {
  final List<Facility> facilities;
  final List<Facility> filteredFacilities;
  final String currentFilter;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const GroomingReservationState({
    this.facilities = const [],
    this.filteredFacilities = const [],
    this.currentFilter = 'All',
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  GroomingReservationState copyWith({
    List<Facility>? facilities,
    List<Facility>? filteredFacilities,
    String? currentFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return GroomingReservationState(
      facilities: facilities ?? this.facilities,
      filteredFacilities: filteredFacilities ?? this.filteredFacilities,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 그루밍 예약 화면의 비즈니스 로직을 관리하는 컨트롤러
class GroomingReservationController {
  final WidgetRef ref;
  final BuildContext context;

  GroomingReservationController(this.ref, this.context);

  /// 그루밍 시설 데이터 로드
  Future<void> loadGroomingFacilities() async {
    try {
      _updateState(isLoading: true, error: null);

      final facilitiesData = FacilityMockService.getMockGroomingFacilities();
      final facilities = facilitiesData
          .map(
            (data) => Facility(
              id: data['id'] as String,
              name: data['name'] as String,
              description: data['description'] as String,
              address: data['address'] as String,
              latitude: data['latitude'] as double? ?? 35.6762,
              longitude: data['longitude'] as double? ?? 139.6503,
              phone: data['phone'] as String,
              email: data['email'] as String,
              type: data['type'] == 'grooming'
                  ? FacilityType.grooming
                  : FacilityType.hospital,
              rating: (data['rating'] as num).toDouble(),
              reviewCount: data['reviewCount'] as int,
              imagePath: data['imagePath'] as String,
              isFavorite: data['isFavorite'] as bool? ?? false,
              hasHistory: data['hasHistory'] as bool? ?? false,
              lastVisit: data['lastVisit'] as DateTime?,
            ),
          )
          .toList();

      final filteredFacilities = _applyFilters(facilities, '', 'All');

      _updateState(
        facilities: facilities,
        filteredFacilities: filteredFacilities,
        isLoading: false,
      );
    } catch (error) {
      _updateState(isLoading: false, error: '그루밍 시설 데이터를 불러오는데 실패했습니다: $error');
      _showErrorMessage('그루밍 시설 데이터를 불러오는데 실패했습니다');
    }
  }

  /// 검색어 업데이트
  void updateSearchQuery(String query) {
    final currentState = ref.read(groomingReservationControllerProvider);
    final filteredFacilities = _applyFilters(
      currentState.facilities,
      query,
      currentState.currentFilter,
    );

    _updateState(searchQuery: query, filteredFacilities: filteredFacilities);
  }

  /// 필터 업데이트
  void updateFilter(String filter) {
    final currentState = ref.read(groomingReservationControllerProvider);
    final filteredFacilities = _applyFilters(
      currentState.facilities,
      currentState.searchQuery,
      filter,
    );

    _updateState(currentFilter: filter, filteredFacilities: filteredFacilities);
  }

  /// 즐겨찾기 토글
  void toggleFavorite(String facilityId) {
    final currentState = ref.read(groomingReservationControllerProvider);
    final updatedFacilities = currentState.facilities.map((facility) {
      if (facility.id == facilityId) {
        return facility.copyWith(isFavorite: !facility.isFavorite);
      }
      return facility;
    }).toList();

    final filteredFacilities = _applyFilters(
      updatedFacilities,
      currentState.searchQuery,
      currentState.currentFilter,
    );

    _updateState(
      facilities: updatedFacilities,
      filteredFacilities: filteredFacilities,
    );
  }

  /// 필터 적용 로직
  List<Facility> _applyFilters(
    List<Facility> facilities,
    String searchQuery,
    String currentFilter,
  ) {
    List<Facility> filtered = facilities;

    // 검색 필터
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (facility) =>
                facility.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (facility.description?.toLowerCase() ?? '').contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // 카테고리 필터
    switch (currentFilter) {
      case 'Favorites':
        filtered = filtered.where((facility) => facility.isFavorite).toList();
        break;
      case 'History':
        filtered = filtered.where((facility) => facility.hasHistory).toList();
        break;
      case 'All':
      default:
        break;
    }

    return filtered;
  }

  /// 상태 업데이트
  void _updateState({
    List<Facility>? facilities,
    List<Facility>? filteredFacilities,
    String? currentFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    final currentState = ref.read(groomingReservationControllerProvider);
    final newState = currentState.copyWith(
      facilities: facilities,
      filteredFacilities: filteredFacilities,
      currentFilter: currentFilter,
      searchQuery: searchQuery,
      isLoading: isLoading,
      error: error,
    );

    ref
        .read(groomingReservationControllerProvider.notifier)
        .updateState(newState);
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointPink),
    );
  }
}

/// 그루밍 예약 컨트롤러 프로바이더
final groomingReservationControllerProvider =
    StateNotifierProvider<
      GroomingReservationStateNotifier,
      GroomingReservationState
    >((ref) => GroomingReservationStateNotifier());

class GroomingReservationStateNotifier
    extends StateNotifier<GroomingReservationState> {
  GroomingReservationStateNotifier() : super(const GroomingReservationState());

  void updateState(GroomingReservationState newState) {
    state = newState;
  }
}
