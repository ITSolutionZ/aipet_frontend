import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 시설 생성 UseCase
class CreateFacilityUseCase {
  final FacilityRepository _repository;

  CreateFacilityUseCase(this._repository);

  /// 새로운 시설을 생성합니다
  Future<Result<Facility>> createFacility({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required FacilityType type,
    String? description,
    String? phoneNumber,
    String? website,
    List<String>? services,
    Map<String, dynamic>? operatingHours,
    double? rating,
    int? reviewCount,
    List<String>? images,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // 입력 검증
      if (name.trim().isEmpty) {
        return Result.failure('시설명은 필수입니다');
      }

      if (address.trim().isEmpty) {
        return Result.failure('주소는 필수입니다');
      }

      if (latitude < -90 || latitude > 90) {
        return Result.failure('유효하지 않은 위도입니다');
      }

      if (longitude < -180 || longitude > 180) {
        return Result.failure('유효하지 않은 경도입니다');
      }

      // 시설 엔티티 생성
      final facility = Facility(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        address: address.trim(),
        latitude: latitude,
        longitude: longitude,
        type: type,
        description: description?.trim(),
        phoneNumber: phoneNumber?.trim(),
        website: website?.trim(),
        services: services ?? [],
        operatingHours: operatingHours ?? {},
        rating: rating ?? 0.0,
        reviewCount: reviewCount ?? 0,
        images: images ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock 데이터에 추가 (실제 구현에서는 Repository를 통해 저장)
      await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션

      return Result.success('시설이 성공적으로 생성되었습니다', facility);
    } catch (e) {
      return Result.failure('시설 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설을 일괄 생성합니다
  Future<Result<List<Facility>>> createFacilities(
    List<Map<String, dynamic>> facilityDataList,
  ) async {
    try {
      final facilities = <Facility>[];

      for (final data in facilityDataList) {
        final result = await createFacility(
          name: data['name'] as String,
          address: data['address'] as String,
          latitude: data['latitude'] as double,
          longitude: data['longitude'] as double,
          type: data['type'] as FacilityType,
          description: data['description'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
          website: data['website'] as String?,
          services: data['services'] as List<String>?,
          operatingHours: data['operatingHours'] as Map<String, dynamic>?,
          rating: data['rating'] as double?,
          reviewCount: data['reviewCount'] as int?,
          images: data['images'] as List<String>?,
        );

        if (result.isSuccess && result.data != null) {
          facilities.add(result.data!);
        } else {
          return Result.failure('시설 일괄 생성 중 오류가 발생했습니다: ${result.message}');
        }
      }

      return Result.success('시설들이 성공적으로 생성되었습니다', facilities);
    } catch (e) {
      return Result.failure('시설 일괄 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설을 복사하여 새 시설을 생성합니다
  Future<Result<Facility>> duplicateFacility(
    String facilityId, {
    String? newName,
  }) async {
    try {
      // 기존 시설 조회
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('기존 시설을 찾을 수 없습니다: ${getResult.message}');
      }

      final originalFacility = getResult.data;

      // 새 시설 생성
      final newFacility = originalFacility?.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName ?? '${originalFacility.name} (복사본)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      return Result.success('시설이 성공적으로 복사되었습니다', newFacility);
    } catch (e) {
      return Result.failure('시설 복사 중 오류가 발생했습니다: $e');
    }
  }
}
