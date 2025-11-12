import '../../../../shared/shared.dart';

import '../../../../../features/walk/data/services/backend_walk_api_service.dart';
import '../../../../../features/walk/domain/entities/walk_record_entity.dart';
import '../../../../../features/walk/domain/entities/walk_statistics_entity.dart';

/// 백엔드 API를 사용하는 산책 API 서비스
///
/// BackendWalkApiService를 래핑하여 기존 WalkApiService 인터페이스와 호환되도록 구현
class WalkApiServiceBackend {
  /// 모든 산책 기록 조회 (기본 petId 필요)
  Future<Result<List<WalkRecordEntity>>> getAllWalkRecords({
    String? petId,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 전체 산책 기록 조회 요청');

      if (petId == null || petId.isEmpty) {
        LoggerService.debug('⚠️ WalkAPIBackend: petId가 없어 빈 목록 반환');
        return Result.success('산책 기록을 가져왔습니다', []);
      }

      final result = await BackendWalkApiService.getWalks(petId: petId);

      if (result.isSuccess && result.data != null) {
        // 백엔드 응답을 WalkRecordEntity로 변환
        final records = result.data!
            .map((json) => _mapToWalkRecord(json))
            .toList();

        LoggerService.debug('✅ WalkAPIBackend: ${records.length}개 산책 기록 조회 성공');
        return Result.success('산책 기록을 가져왔습니다', records);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 응답 데이터 없음');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPIBackend: 산책 기록 조회 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// ID로 산책 기록 조회
  Future<Result<WalkRecordEntity>> getWalkRecordById(
    String id, {
    String? petId,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 기록 조회 - ID: $id');

      if (petId == null || petId.isEmpty) {
        return Result.failure('petId가 필요합니다');
      }

      // 전체 목록에서 ID로 찾기 (개별 조회 API가 없으므로)
      final result = await BackendWalkApiService.getWalks(petId: petId);

      if (result.isSuccess && result.data != null) {
        final records = result.data!
            .map((json) => _mapToWalkRecord(json))
            .toList();
        final record = records.firstWhere(
          (r) => r.id == id,
          orElse: () => throw Exception('산책 기록을 찾을 수 없습니다'),
        );

        LoggerService.debug('✅ WalkAPIBackend: 산책 기록 조회 성공 - ID: $id');
        return Result.success('산책 기록을 가져왔습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 산책 기록 없음 - ID: $id');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPIBackend: 산책 기록 조회 실패 - ID: $id, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// 펫별 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getWalkRecordsByPetId(
    String petId,
  ) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 펫별 산책 기록 조회 - Pet ID: $petId');

      final result = await BackendWalkApiService.getWalks(petId: petId);

      if (result.isSuccess && result.data != null) {
        final records = result.data!
            .map((json) => _mapToWalkRecord(json))
            .toList();

        LoggerService.debug(
          '✅ WalkAPIBackend: ${records.length}개 산책 기록 조회 성공 (Pet ID: $petId)',
        );
        return Result.success('펫 산책 기록을 가져왔습니다', records);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 응답 데이터 없음 (Pet ID: $petId)');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug(
        '❌ WalkAPIBackend: 펫 산책 기록 조회 실패 - Pet ID: $petId, Error: $e',
      );
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('펫 산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// 산책 시작
  Future<Result<WalkRecordEntity>> startWalk(
    WalkRecordEntity walkRecord,
  ) async {
    try {
      LoggerService.debug(
        '🌐 WalkAPIBackend: 산책 시작 요청 - Pet: ${walkRecord.petName}',
      );

      final result = await BackendWalkApiService.createWalk(
        petId: walkRecord.petId,
        startTime: walkRecord.startTime,
        notes: walkRecord.notes,
      );

      if (result.isSuccess && result.data != null) {
        final record = _mapToWalkRecord(result.data!);

        LoggerService.debug('✅ WalkAPIBackend: 산책 시작 성공 - ID: ${record.id}');
        return Result.success('산책이 시작되었습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 산책 시작 응답 오류');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPIBackend: 산책 시작 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 시작 실패: ${e.toString()}');
    }
  }

  /// 산책 종료
  Future<Result<WalkRecordEntity>> endWalk(
    String walkId, {
    required String petId,
    double? distance,
    String? notes,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 종료 요청 - ID: $walkId');

      // 종료 시간 계산
      final endTime = DateTime.now();

      final result = await BackendWalkApiService.updateWalk(
        petId: petId,
        walkId: walkId,
        endTime: endTime,
        distanceMeters: distance != null ? (distance * 1000).toInt() : null,
        notes: notes,
      );

      if (result.isSuccess && result.data != null) {
        final record = _mapToWalkRecord(result.data!);

        LoggerService.debug('✅ WalkAPIBackend: 산책 종료 성공 - ID: $walkId');
        return Result.success('산책이 종료되었습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 산책 종료 응답 오류');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug(
        '❌ WalkAPIBackend: 산책 종료 실패 - ID: $walkId, Error: $e',
      );
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 종료 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 업데이트
  Future<Result<WalkRecordEntity>> updateWalkRecord(
    WalkRecordEntity walkRecord,
  ) async {
    try {
      LoggerService.debug(
        '🌐 WalkAPIBackend: 산책 기록 업데이트 요청 - ID: ${walkRecord.id}',
      );

      final result = await BackendWalkApiService.updateWalk(
        petId: walkRecord.petId,
        walkId: walkRecord.id,
        startTime: walkRecord.startTime,
        endTime: walkRecord.endTime,
        durationMinutes: walkRecord.duration?.inMinutes,
        distanceMeters: walkRecord.distance != null
            ? (walkRecord.distance! * 1000).toInt()
            : null,
        notes: walkRecord.notes,
      );

      if (result.isSuccess && result.data != null) {
        final record = _mapToWalkRecord(result.data!);

        LoggerService.debug(
          '✅ WalkAPIBackend: 산책 기록 업데이트 성공 - ID: ${walkRecord.id}',
        );
        return Result.success('산책 기록이 업데이트되었습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 산책 기록 업데이트 응답 오류');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug(
        '❌ WalkAPIBackend: 산책 기록 업데이트 실패 - ID: ${walkRecord.id}, Error: $e',
      );
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 업데이트 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 삭제
  Future<Result<void>> deleteWalkRecord(
    String id, {
    required String petId,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 기록 삭제 요청 - ID: $id');

      final result = await BackendWalkApiService.deleteWalk(
        petId: petId,
        walkId: id,
      );

      if (result.isSuccess) {
        LoggerService.debug('✅ WalkAPIBackend: 산책 기록 삭제 성공 - ID: $id');
        return Result.success(result.message);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 산책 기록 삭제 응답 오류');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPIBackend: 산책 기록 삭제 실패 - ID: $id, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 삭제 실패: ${e.toString()}');
    }
  }

  /// 산책 통계 조회
  Future<Result<WalkStatistics>> getWalkStatistics({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 통계 조회 요청');

      final result = await BackendWalkApiService.getWalkStats(petId: petId);

      if (result.isSuccess && result.data != null) {
        final stats = _mapToWalkStatistics(result.data!);

        LoggerService.debug('✅ WalkAPIBackend: 산책 통계 조회 성공');
        return Result.success('산책 통계를 가져왔습니다', stats);
      }

      LoggerService.debug('⚠️ WalkAPIBackend: 통계 데이터 없음');
      return Result.failure(result.message);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPIBackend: 산책 통계 조회 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 통계 조회 실패: ${e.toString()}');
    }
  }

  /// 현재 진행 중인 산책 조회
  Future<Result<WalkRecordEntity?>> getCurrentWalk({String? petId}) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 현재 산책 조회 요청');

      if (petId == null || petId.isEmpty) {
        return Result.success('petId가 필요합니다', null);
      }

      // 전체 산책 목록에서 in_progress 상태 찾기
      final result = await getAllWalkRecords(petId: petId);

      if (result.isSuccess) {
        final currentWalk = result.data?.cast<WalkRecordEntity?>().firstWhere(
          (record) => record?.status == WalkStatus.inProgress,
          orElse: () => null,
        );

        if (currentWalk != null && currentWalk.id.isNotEmpty) {
          LoggerService.debug(
            '✅ WalkAPIBackend: 현재 산책 찾음 - ID: ${currentWalk.id}',
          );
          return Result.success('현재 산책을 가져왔습니다', currentWalk);
        }
      }

      LoggerService.debug('ℹ️ WalkAPIBackend: 진행 중인 산책 없음');
      return Result.success('진행 중인 산책이 없습니다', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPIBackend: 현재 산책 조회 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('현재 산책 조회 실패: ${e.toString()}');
    }
  }

  /// 백엔드 응답을 WalkRecordEntity로 변환
  WalkRecordEntity _mapToWalkRecord(Map<String, dynamic> json) {
    // duration 계산 (durationMinutes가 있으면 사용, 없으면 startTime과 endTime에서 계산)
    Duration? duration;
    if (json['durationMinutes'] != null) {
      duration = Duration(minutes: json['durationMinutes'] as int);
    } else if (json['duration_minutes'] != null) {
      duration = Duration(minutes: json['duration_minutes'] as int);
    } else if (json['start_time'] != null && json['end_time'] != null) {
      final start = DateTime.parse(json['start_time']);
      final end = DateTime.parse(json['end_time']);
      duration = end.difference(start);
    }

    // distance 변환 (meters → km)
    double? distance;
    if (json['distanceMeters'] != null) {
      distance = (json['distanceMeters'] as num).toDouble() / 1000.0;
    } else if (json['distance_meters'] != null) {
      distance = (json['distance_meters'] as num).toDouble() / 1000.0;
    } else if (json['distance'] != null) {
      distance = (json['distance'] as num).toDouble();
    }

    return WalkRecordEntity(
      id: json['id']?.toString() ?? '',
      petId: json['pet_id']?.toString() ?? json['petId']?.toString() ?? '',
      petName:
          json['pet_name']?.toString() ?? json['petName']?.toString() ?? '',
      startTime: DateTime.parse(
        json['start_time'] ??
            json['startTime'] ??
            DateTime.now().toIso8601String(),
      ),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : (json['endTime'] != null ? DateTime.parse(json['endTime']) : null),
      duration: duration,
      distance: distance,
      status: _parseWalkStatus(json['status']?.toString()),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'])
                : DateTime.now()),
    );
  }

  /// 백엔드 응답을 WalkStatistics로 변환
  WalkStatistics _mapToWalkStatistics(Map<String, dynamic> json) {
    return WalkStatistics(
      totalWalks:
          (json['total_walks'] ?? json['totalWalks'] as num?)?.toInt() ?? 0,
      totalDistance:
          (json['total_distance'] ?? json['totalDistance'] as num?)
              ?.toDouble() ??
          0.0,
      totalDuration: Duration(
        seconds:
            (json['total_duration'] ?? json['totalDuration'] as num?)
                ?.toInt() ??
            0,
      ),
      averageDistance:
          (json['average_distance'] ?? json['averageDistance'] as num?)
              ?.toDouble() ??
          0.0,
      averageDuration: Duration(
        seconds:
            (json['average_duration'] ?? json['averageDuration'] as num?)
                ?.toInt() ??
            0,
      ),
    );
  }

  /// 산책 상태 파싱
  WalkStatus _parseWalkStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return WalkStatus.inProgress;
      case 'completed':
        return WalkStatus.completed;
      case 'cancelled':
        return WalkStatus.cancelled;
      default:
        return WalkStatus.completed;
    }
  }
}
