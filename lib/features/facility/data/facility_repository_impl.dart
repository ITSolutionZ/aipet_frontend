import '../../../shared/testing/mock_data/features/facility/facility_mock_service.dart';
import '../domain/facility.dart';
import '../domain/repositories/facility_repository.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  @override
  Future<List<Facility>> getNearbyFacilities() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final facilitiesData = FacilityMockService.getMockFacilities();
    return _convertToFacilityList(facilitiesData);
  }

  @override
  Future<List<Facility>> searchFacilities(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final facilitiesData = FacilityMockService.getMockFacilities();
    final facilities = _convertToFacilityList(facilitiesData);
    
    if (query.isEmpty) return facilities;

    final lowerQuery = query.toLowerCase();
    return facilities.where((facility) {
      return facility.name.toLowerCase().contains(lowerQuery) ||
          facility.description.toLowerCase().contains(lowerQuery) ||
          facility.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Facility>> getFacilitiesByType(FacilityType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final facilitiesData = FacilityMockService.getMockFacilities();
    final facilities = _convertToFacilityList(facilitiesData);
    return facilities.where((facility) => facility.type == type).toList();
  }

  @override
  Future<Facility?> getFacilityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final facilitiesData = FacilityMockService.getMockFacilities();
    final facilities = _convertToFacilityList(facilitiesData);
    return facilities.where((f) => f.id == id).firstOrNull;
  }

  @override
  Future<List<Facility>> getFacilitiesInRadius(
    double latitude,
    double longitude,
    double radius,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // 간단한 구현: 모든 시설 반환
    final facilitiesData = FacilityMockService.getMockFacilities();
    return _convertToFacilityList(facilitiesData);
  }

  @override
  Future<void> setCurrentLocation(
    double latitude,
    double longitude,
    String address,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return;
  }

  /// Map 데이터를 Facility 객체 리스트로 변환
  List<Facility> _convertToFacilityList(List<Map<String, dynamic>> facilitiesData) {
    return facilitiesData.map((data) => Facility(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      address: data['address'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String,
      type: data['type'] == 'grooming' ? FacilityType.grooming : FacilityType.hospital,
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'] as int,
      imagePath: data['imagePath'] as String,
      isFavorite: data['isFavorite'] as bool? ?? false,
      hasHistory: data['hasHistory'] as bool? ?? false,
      lastVisit: data['lastVisit'] as DateTime?,
    )).toList();
  }
}