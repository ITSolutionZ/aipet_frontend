import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 시설 수정 UseCase
class UpdateFacilityUseCase {
  final FacilityRepository _repository;

  UpdateFacilityUseCase(this._repository);

  /// 시설 정보를 수정합니다
  Future<Result<Facility>> updateFacility({
    required String facilityId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    FacilityType? type,
    String? description,
    String? phoneNumber,
    String? website,
    List<String>? services,
    Map<String, dynamic>? operatingHours,
    double? rating,
    int? reviewCount,
    List<String>? images,
    Map<String, dynamic>? additionalInfo,
    bool? isActive,
  }) async {
    try {
      // 기존 시설 조회
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('시설을 찾을 수 없습니다: ${getResult.message}');
      }

      final existingFacility = getResult.data;

      // 입력 검증
      if (name != null && name.trim().isEmpty) {
        return Result.failure('시설명은 비어있을 수 없습니다');
      }

      if (latitude != null && (latitude < -90 || latitude > 90)) {
        return Result.failure('유효하지 않은 위도입니다');
      }

      if (longitude != null && (longitude < -180 || longitude > 180)) {
        return Result.failure('유효하지 않은 경도입니다');
      }

      // 시설 정보 업데이트
      final updatedFacility = existingFacility?.copyWith(
        name: name?.trim() ?? existingFacility.name,
        address: address?.trim() ?? existingFacility.address,
        latitude: latitude ?? existingFacility.latitude,
        longitude: longitude ?? existingFacility.longitude,
        type: type ?? existingFacility.type,
        description: description?.trim() ?? existingFacility.description,
        phoneNumber: phoneNumber?.trim() ?? existingFacility.phoneNumber,
        website: website?.trim() ?? existingFacility.website,
        services: services ?? existingFacility.services,
        operatingHours: operatingHours ?? existingFacility.operatingHours,
        rating: rating ?? existingFacility.rating,
        reviewCount: reviewCount ?? existingFacility.reviewCount,
        images: images ?? existingFacility.images,
        updatedAt: DateTime.now(),
      );

      // Mock 데이터 업데이트 (실제 구현에서는 Repository를 통해 저장)
      await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션

      return Result.success('시설이 성공적으로 수정되었습니다', updatedFacility);
    } catch (e) {
      return Result.failure('시설 수정 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설의 특정 필드만 수정합니다
  Future<Result<Facility>> updateFacilityField({
    required String facilityId,
    required String field,
    required dynamic value,
  }) async {
    try {
      // 기존 시설 조회
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('시설을 찾을 수 없습니다: ${getResult.message}');
      }

      final existingFacility = getResult.data;

      // 필드별 업데이트
      Facility updatedFacility;
      switch (field) {
        case 'name':
          if (value is! String || value.trim().isEmpty) {
            return Result.failure('유효하지 않은 시설명입니다');
          }
          updatedFacility =
              existingFacility?.copyWith(name: value.trim()) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'address':
          if (value is! String || value.trim().isEmpty) {
            return Result.failure('유효하지 않은 주소입니다');
          }
          updatedFacility =
              existingFacility?.copyWith(address: value.trim()) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'latitude':
          if (value is! double || value < -90 || value > 90) {
            return Result.failure('유효하지 않은 위도입니다');
          }
          updatedFacility =
              existingFacility?.copyWith(latitude: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'longitude':
          if (value is! double || value < -180 || value > 180) {
            return Result.failure('유효하지 않은 경도입니다');
          }
          updatedFacility =
              existingFacility?.copyWith(longitude: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'type':
          if (value is! FacilityType) {
            return Result.failure('유효하지 않은 시설 타입입니다');
          }
          updatedFacility =
              existingFacility?.copyWith(type: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'description':
          updatedFacility =
              existingFacility?.copyWith(description: value as String?) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'phoneNumber':
          updatedFacility =
              existingFacility?.copyWith(phoneNumber: value as String?) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'website':
          updatedFacility =
              existingFacility?.copyWith(website: value as String?) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'services':
          if (value is! List<String>) {
            return Result.failure('유효하지 않은 서비스 목록입니다');
          }
          updatedFacility =
              existingFacility?.copyWith(services: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'rating':
          if (value is! double || value < 0 || value > 5) {
            return Result.failure('유효하지 않은 평점입니다 (0-5)');
          }
          updatedFacility =
              existingFacility?.copyWith(rating: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        default:
          return Result.failure('지원하지 않는 필드입니다: $field');
      }

      updatedFacility = updatedFacility.copyWith(updatedAt: DateTime.now());

      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      return Result.success('시설이 성공적으로 수정되었습니다', updatedFacility);
    } catch (e) {
      return Result.failure('시설 필드 수정 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설을 일괄 수정합니다
  Future<Result<List<Facility>>> updateFacilities(List<Map<String, dynamic>> updates) async {
    try {
      final updatedFacilities = <Facility>[];

      for (final update in updates) {
        final facilityId = update['facilityId'] as String;
        final result = await updateFacility(
          facilityId: facilityId,
          name: update['name'] as String?,
          address: update['address'] as String?,
          latitude: update['latitude'] as double?,
          longitude: update['longitude'] as double?,
          type: update['type'] as FacilityType?,
          description: update['description'] as String?,
          phoneNumber: update['phoneNumber'] as String?,
          website: update['website'] as String?,
          services: update['services'] as List<String>?,
          operatingHours: update['operatingHours'] as Map<String, dynamic>?,
          rating: update['rating'] as double?,
          reviewCount: update['reviewCount'] as int?,
          images: update['images'] as List<String>?,
        );

        if (result.isSuccess) {
          updatedFacilities.add(result.dataOrThrow);
        } else {
          return Result.failure('시설 일괄 수정 중 오류가 발생했습니다: ${result.message}');
        }
      }

      return Result.success('시설들이 성공적으로 수정되었습니다', updatedFacilities);
    } catch (e) {
      return Result.failure('시설 일괄 수정 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설의 평점을 업데이트합니다
  Future<Result<Facility>> updateFacilityRating({
    required String facilityId,
    required double newRating,
    required int reviewCount,
  }) async {
    try {
      if (newRating < 0 || newRating > 5) {
        return Result.failure('평점은 0-5 사이여야 합니다');
      }

      if (reviewCount < 0) {
        return Result.failure('리뷰 수는 0 이상이어야 합니다');
      }

      return await updateFacilityField(facilityId: facilityId, field: 'rating', value: newRating);
    } catch (e) {
      return Result.failure('시설 평점 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설을 활성화/비활성화합니다
  Future<Result<Facility>> toggleFacilityStatus(String facilityId) async {
    try {
      // 기존 시설 조회
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('시설을 찾을 수 없습니다: ${getResult.message}');
      }

      final existingFacility = getResult.data;
      final newStatus = !(existingFacility?.isOpen ?? false);

      return await updateFacilityField(facilityId: facilityId, field: 'isOpen', value: newStatus);
    } catch (e) {
      return Result.failure('시설 상태 변경 중 오류가 발생했습니다: $e');
    }
  }
}
