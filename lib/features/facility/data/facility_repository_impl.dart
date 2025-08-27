import '../../../shared/mock_data/mock_data_service.dart';
import '../domain/facility.dart';
import '../domain/repositories/facility_repository.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  @override
  Future<List<Facility>> getNearbyFacilities() async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataService.getMockFacilities();
    }
    throw UnimplementedError('実際のAPI連携は別途実装予定です');
  }

  @override
  Future<List<Facility>> searchFacilities(String query) async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      final facilities = MockDataService.getMockFacilities();
      if (query.isEmpty) return facilities;

      final lowerQuery = query.toLowerCase();
      return facilities.where((facility) {
        return facility.name.toLowerCase().contains(lowerQuery) ||
            facility.description.toLowerCase().contains(lowerQuery) ||
            facility.address.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    throw UnimplementedError('実際のAPI連携は別途実装予定です');
  }

  @override
  Future<List<Facility>> getFacilitiesByType(FacilityType type) async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      final facilities = MockDataService.getMockFacilities();
      return facilities.where((facility) => facility.type == type).toList();
    }
    throw UnimplementedError('実際のAPI連携は別途実装予定です');
  }

  @override
  Future<Facility?> getFacilityById(String id) async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 200));
      final facilities = MockDataService.getMockFacilities();
      return facilities.where((f) => f.id == id).firstOrNull;
    }
    throw UnimplementedError('実際のAPI連携は別途実装予定です');
  }

  @override
  Future<List<Facility>> getFacilitiesInRadius(
    double latitude,
    double longitude,
    double radius,
  ) async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      // 간단한 구현: 모든 시설 반환
      return MockDataService.getMockFacilities();
    }
    throw UnimplementedError('実際のAPI連携は別途実装予定です');
  }

  @override
  Future<void> setCurrentLocation(
    double latitude,
    double longitude,
    String address,
  ) async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    }
    throw UnimplementedError('実際のAPI連携は別途実装予定です');
  }
}
