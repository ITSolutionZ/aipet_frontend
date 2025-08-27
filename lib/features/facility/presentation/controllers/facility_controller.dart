import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/facility.dart';
import '../../domain/usecases/filter_facilities_by_type_usecase.dart';
import '../../domain/usecases/get_facility_by_id_usecase.dart';
import '../../domain/usecases/load_facilities_usecase.dart';
import '../../domain/usecases/search_facilities_usecase.dart';
import '../../domain/usecases/set_current_location_usecase.dart';

class FacilityController extends StateNotifier<FacilityState> {
  FacilityController(
    this._loadFacilitiesUseCase,
    this._searchFacilitiesUseCase,
    this._filterFacilitiesByTypeUseCase,
    this._getFacilityByIdUseCase,
    this._setCurrentLocationUseCase,
  ) : super(FacilityState.initial());

  final LoadFacilitiesUseCase _loadFacilitiesUseCase;
  final SearchFacilitiesUseCase _searchFacilitiesUseCase;
  final FilterFacilitiesByTypeUseCase _filterFacilitiesByTypeUseCase;
  final GetFacilityByIdUseCase _getFacilityByIdUseCase;
  final SetCurrentLocationUseCase _setCurrentLocationUseCase;

  Future<void> loadFacilities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final facilities = await _loadFacilitiesUseCase();
      state = state.copyWith(
        isLoading: false,
        facilities: facilities,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '施設の読み込みに失敗しました: ${e.toString()}',
      );
    }
  }

  Future<void> searchFacilities(String query) async {
    if (query.isEmpty) {
      await loadFacilities();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final facilities = await _searchFacilitiesUseCase(query);
      state = state.copyWith(
        isLoading: false,
        facilities: facilities,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'シセツの検索に失敗しました: ${e.toString()}',
      );
    }
  }

  Future<void> filterFacilitiesByType(FacilityType? type) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final List<Facility> facilities;
      if (type == null) {
        facilities = await _loadFacilitiesUseCase();
      } else {
        facilities = await _filterFacilitiesByTypeUseCase(type);
      }

      state = state.copyWith(
        isLoading: false,
        facilities: facilities,
        selectedType: type,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'シセツのフィルタリングに失敗しました: ${e.toString()}',
      );
    }
  }

  Future<Facility?> getFacilityById(String id) async {
    try {
      return await _getFacilityByIdUseCase(id);
    } catch (e) {
      state = state.copyWith(error: 'シセツ詳細の取得に失敗しました: ${e.toString()}');
      return null;
    }
  }

  Future<void> setCurrentLocation(
    double latitude,
    double longitude,
    String address,
  ) async {
    try {
      await _setCurrentLocationUseCase(latitude, longitude, address);

      state = state.copyWith(
        currentLatitude: latitude,
        currentLongitude: longitude,
        currentAddress: address,
      );

      await loadFacilities();
    } catch (e) {
      state = state.copyWith(error: '現在地の設定に失敗しました: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetFilters() {
    state = state.copyWith(selectedType: null);
    loadFacilities();
  }
}

class FacilityState {
  final bool isLoading;
  final String? error;
  final List<Facility> facilities;
  final FacilityType? selectedType;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentAddress;

  const FacilityState({
    required this.isLoading,
    this.error,
    required this.facilities,
    this.selectedType,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAddress,
  });

  factory FacilityState.initial() =>
      const FacilityState(isLoading: false, facilities: []);

  FacilityState copyWith({
    bool? isLoading,
    String? error,
    List<Facility>? facilities,
    FacilityType? selectedType,
    double? currentLatitude,
    double? currentLongitude,
    String? currentAddress,
  }) {
    return FacilityState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      facilities: facilities ?? this.facilities,
      selectedType: selectedType ?? this.selectedType,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentAddress: currentAddress ?? this.currentAddress,
    );
  }

  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  bool get hasSelectedType => selectedType != null;

  bool get hasData => facilities.isNotEmpty;

  bool get hasError => error != null;
}
