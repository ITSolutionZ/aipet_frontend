import 'dart:math';

import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 시설 삭제 UseCase
class DeleteFacilityUseCase {
  final FacilityRepository _repository;

  DeleteFacilityUseCase(this._repository);

  /// 시설을 삭제합니다
  Future<Result<void>> deleteFacility(String facilityId) async {
    try {
      // 시설 존재 확인
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('시설을 찾을 수 없습니다: ${getResult.message}');
      }

      // Mock 데이터에서 삭제 (실제 구현에서는 Repository를 통해 삭제)
      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      return Result.success('시설이 성공적으로 삭제되었습니다');
    } catch (e) {
      return Result.failure('시설 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 여러 시설을 일괄 삭제합니다
  Future<Result<Map<String, dynamic>>> deleteFacilities(List<String> facilityIds) async {
    try {
      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];

      for (final facilityId in facilityIds) {
        final result = await deleteFacility(facilityId);
        if (result.isSuccess) {
          successCount++;
        } else {
          failureCount++;
          errors.add('시설 $facilityId: ${result.message}');
        }
      }

      return Result.success('시설 일괄 삭제가 완료되었습니다', {
        'successCount': successCount,
        'failureCount': failureCount,
        'totalCount': facilityIds.length,
        'errors': errors,
      });
    } catch (e) {
      return Result.failure('시설 일괄 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설 타입별로 시설들을 삭제합니다
  Future<Result<Map<String, dynamic>>> deleteFacilitiesByType(String facilityType) async {
    try {
      // 해당 타입의 시설들을 조회
      final getResult = await _repository.getFacilitiesByType(
        FacilityType.values.firstWhere((e) => e.name == facilityType),
      );
      if (!getResult.isSuccess) {
        return Result.failure('시설 타입 조회 중 오류가 발생했습니다: ${getResult.message}');
      }

      final facilities = getResult.data ?? [];
      final facilityIds = facilities.map((f) => f.id).toList();

      if (facilityIds.isEmpty) {
        return Result.success('삭제할 시설이 없습니다', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 일괄 삭제 실행
      return await deleteFacilities(facilityIds);
    } catch (e) {
      return Result.failure('시설 타입별 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 위치 반경 내의 시설들을 삭제합니다
  Future<Result<Map<String, dynamic>>> deleteFacilitiesByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // 모든 시설을 조회
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('시설 조회 중 오류가 발생했습니다: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilitiesToDelete = <String>[];

      // 반경 내 시설들 찾기
      for (final facility in allFacilities ?? []) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          facility.latitude,
          facility.longitude,
        );

        if (distance <= radiusKm) {
          facilitiesToDelete.add(facility.id);
        }
      }

      if (facilitiesToDelete.isEmpty) {
        return Result.success('삭제할 시설이 없습니다', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 일괄 삭제 실행
      return await deleteFacilities(facilitiesToDelete);
    } catch (e) {
      return Result.failure('위치 기반 시설 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 평점이 낮은 시설들을 삭제합니다
  Future<Result<Map<String, dynamic>>> deleteLowRatedFacilities({
    required double minRating,
    int? minReviewCount,
  }) async {
    try {
      // 모든 시설을 조회
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('시설 조회 중 오류가 발생했습니다: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilitiesToDelete = <String>[];

      // 조건에 맞는 시설들 찾기
      for (final facility in allFacilities ?? []) {
        if (facility.rating < minRating) {
          if (minReviewCount == null || facility.reviewCount >= minReviewCount) {
            facilitiesToDelete.add(facility.id);
          }
        }
      }

      if (facilitiesToDelete.isEmpty) {
        return Result.success('삭제할 시설이 없습니다', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 일괄 삭제 실행
      return await deleteFacilities(facilitiesToDelete);
    } catch (e) {
      return Result.failure('낮은 평점 시설 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 오래된 시설들을 삭제합니다
  Future<Result<Map<String, dynamic>>> deleteOldFacilities({required int daysOld}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      // 모든 시설을 조회
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('시설 조회 중 오류가 발생했습니다: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilitiesToDelete = <String>[];

      // 오래된 시설들 찾기
      for (final facility in allFacilities ?? []) {
        if (facility.createdAt != null && facility.createdAt!.isBefore(cutoffDate)) {
          facilitiesToDelete.add(facility.id);
        }
      }

      if (facilitiesToDelete.isEmpty) {
        return Result.success('삭제할 시설이 없습니다', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 일괄 삭제 실행
      return await deleteFacilities(facilitiesToDelete);
    } catch (e) {
      return Result.failure('오래된 시설 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 시설을 소프트 삭제합니다 (비활성화)
  Future<Result<void>> softDeleteFacility(String facilityId) async {
    try {
      // 시설 존재 확인
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('시설을 찾을 수 없습니다: ${getResult.message}');
      }

      // 시설을 비활성화 (실제 구현에서는 Repository를 통해 업데이트)
      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      return Result.success('시설이 성공적으로 삭제되었습니다');
    } catch (e) {
      return Result.failure('시설 소프트 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 소프트 삭제된 시설을 복원합니다
  Future<Result<void>> restoreFacility(String facilityId) async {
    try {
      // 시설 존재 확인
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('시설을 찾을 수 없습니다: ${getResult.message}');
      }

      // 시설을 활성화 (실제 구현에서는 Repository를 통해 업데이트)
      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      return Result.success('시설이 성공적으로 삭제되었습니다');
    } catch (e) {
      return Result.failure('시설 복원 중 오류가 발생했습니다: $e');
    }
  }

  /// 모든 시설을 삭제합니다 (주의: 위험한 작업)
  Future<Result<Map<String, dynamic>>> deleteAllFacilities() async {
    try {
      // 모든 시설을 조회
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('시설 조회 중 오류가 발생했습니다: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilityIds = allFacilities?.map((f) => f.id).toList() ?? [];

      if (facilityIds.isEmpty) {
        return Result.success('삭제할 시설이 없습니다', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 일괄 삭제 실행
      return await deleteFacilities(facilityIds);
    } catch (e) {
      return Result.failure('모든 시설 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 두 지점 간의 거리를 계산합니다 (Haversine 공식)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반지름 (km)

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
