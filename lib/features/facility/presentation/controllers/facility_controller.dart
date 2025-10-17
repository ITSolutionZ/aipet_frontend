import 'package:aipet_frontend/features/facility/data/facility_providers.dart';
import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/usecases/filter_facilities_by_type_usecase.dart';
import 'package:aipet_frontend/features/facility/domain/usecases/get_facility_by_id_usecase.dart';
import 'package:aipet_frontend/features/facility/domain/usecases/load_facilities_usecase.dart';
import 'package:aipet_frontend/features/facility/domain/usecases/search_facilities_usecase.dart';
import 'package:aipet_frontend/features/facility/domain/usecases/set_current_location_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'facility_controller.g.dart';

@riverpod
class FacilityController extends _$FacilityController {
  late final LoadFacilitiesUseCase _loadFacilitiesUseCase;
  late final SearchFacilitiesUseCase _searchFacilitiesUseCase;
  late final FilterFacilitiesByTypeUseCase _filterFacilitiesByTypeUseCase;
  late final GetFacilityByIdUseCase _getFacilityByIdUseCase;
  late final SetCurrentLocationUseCase _setCurrentLocationUseCase;

  @override
  FacilityState build() {
    final repository = ref.watch(facilityRepositoryProvider);
    _loadFacilitiesUseCase = LoadFacilitiesUseCase(repository);
    _searchFacilitiesUseCase = SearchFacilitiesUseCase(repository);
    _filterFacilitiesByTypeUseCase = FilterFacilitiesByTypeUseCase(repository);
    _getFacilityByIdUseCase = GetFacilityByIdUseCase(repository);
    _setCurrentLocationUseCase = SetCurrentLocationUseCase(repository);

    return FacilityState.initial();
  }

  Future<void> loadFacilities() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loadFacilitiesUseCase();
    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        facilities: result.dataOrNull ?? [],
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  Future<void> searchFacilities(String query) async {
    if (query.isEmpty) {
      await loadFacilities();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _searchFacilitiesUseCase(query);
    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        facilities: result.dataOrNull ?? [],
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  Future<void> filterFacilitiesByType(FacilityType? type) async {
    state = state.copyWith(isLoading: true, error: null);

    if (type == null) {
      final result = await _loadFacilitiesUseCase();
      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          facilities: result.dataOrNull ?? [],
          selectedType: type,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: result.message);
      }
    } else {
      final result = await _filterFacilitiesByTypeUseCase(type);
      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          facilities: result.dataOrNull ?? [],
          selectedType: type,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: result.message);
      }
    }
  }

  Future<Facility?> getFacilityById(String id) async {
    final result = await _getFacilityByIdUseCase(id);
    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      state = state.copyWith(error: result.message);
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
