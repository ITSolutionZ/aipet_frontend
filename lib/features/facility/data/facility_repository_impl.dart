import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/foundation/error_handler/app_error_handler.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/facility/facility_mock_service.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  @override
  Future<Result<List<Facility>>> getNearbyFacilities() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final facilitiesData = FacilityMockService.getMockFacilities();
      final facilities = _convertToFacilityList(facilitiesData);
      return Result.success('근처 시설을 성공적으로 조회했습니다', facilities);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<List<Facility>>> searchFacilities(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final facilitiesData = FacilityMockService.getMockFacilities();
      final facilities = _convertToFacilityList(facilitiesData);

      if (query.isEmpty) {
        return Result.success('모든 시설을 조회했습니다', facilities);
      }

      final lowerQuery = query.toLowerCase();
      final filteredFacilities = facilities.where((facility) {
        return facility.name.toLowerCase().contains(lowerQuery) ||
            (facility.description?.toLowerCase() ?? '').contains(lowerQuery) ||
            facility.address.toLowerCase().contains(lowerQuery);
      }).toList();

      return Result.success('검색 결과를 성공적으로 조회했습니다', filteredFacilities);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<List<Facility>>> getFacilitiesByType(FacilityType type) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final facilitiesData = FacilityMockService.getMockFacilities();
      final facilities = _convertToFacilityList(facilitiesData);
      final filteredFacilities = facilities.where((facility) => facility.type == type).toList();
      return Result.success('${type.name} 타입 시설을 성공적으로 조회했습니다', filteredFacilities);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<Facility>> getFacilityById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final facilitiesData = FacilityMockService.getMockFacilities();
      final facilities = _convertToFacilityList(facilitiesData);
      final facility = facilities.where((f) => f.id == id).firstOrNull;

      if (facility != null) {
        return Result.success('시설 정보를 성공적으로 조회했습니다', facility);
      } else {
        return Result.failure('시설을 찾을 수 없습니다');
      }
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<List<Facility>>> getFacilitiesInRadius(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // 간단한 구현: 모든 시설 반환
      final facilitiesData = FacilityMockService.getMockFacilities();
      final facilities = _convertToFacilityList(facilitiesData);
      return Result.success('반경 내 시설을 성공적으로 조회했습니다', facilities);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<void>> setCurrentLocation(double latitude, double longitude, String address) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success('현재 위치를 성공적으로 설정했습니다', null);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  /// Map 데이터를 Facility 객체 리스트로 변환
  List<Facility> _convertToFacilityList(List<Map<String, dynamic>> facilitiesData) {
    return facilitiesData
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
            type: data['type'] == 'grooming' ? FacilityType.grooming : FacilityType.hospital,
            rating: (data['rating'] as num).toDouble(),
            reviewCount: data['reviewCount'] as int,
            imagePath: data['imagePath'] as String,
            isFavorite: data['isFavorite'] as bool? ?? false,
            hasHistory: data['hasHistory'] as bool? ?? false,
            lastVisit: data['lastVisit'] as DateTime?,
          ),
        )
        .toList();
  }
}
