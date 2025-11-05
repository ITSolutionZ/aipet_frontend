import '../../../../shared/shared.dart';

import '../../../../../features/walk/data/services/backend_walk_api_service.dart';
import '../../../../../features/walk/domain/entities/walk_record_entity.dart';
import '../../../../../features/walk/domain/entities/walk_statistics_entity.dart';

/// 백엔드 API를 사용하는 산책 API 서비스
///
/// BackendWalkApiService를 래핑하여 기존 WalkApiService 인터페이스와 호환되도록 구현
class WalkApiServiceBackend {
  /// 모든 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getAllWalkRecords() async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 전체 산책 기록 조회 요청');

      final result = await BackendWalkApiService.getUserWalks();

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
  Future<Result<WalkRecordEntity>> getWalkRecordById(String id) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 기록 조회 - ID: $id');

      final result = await BackendWalkApiService.getWalkById(id);

      if (result.isSuccess && result.data != null) {
        final record = _mapToWalkRecord(result.data!);

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

      final result = await BackendWalkApiService.getPetWalks(petId);

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
      LoggerService.debug('🌐 WalkAPIBackend: 산책 시작 요청 - Pet: ${walkRecord.petName}');

      final result = await BackendWalkApiService.createWalk(
        petId: walkRecord.petId,
        startTime: walkRecord.startTime.toIso8601String(),
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
    double? distance,
    String? notes,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 종료 요청 - ID: $walkId');

      // 종료 시간과 상태 계산
      final endTime = DateTime.now();

      final result = await BackendWalkApiService.updateWalk(
        walkId,
        endTime: endTime.toIso8601String(),
        distance: distance,
        status: 'completed',
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
      LoggerService.debug('❌ WalkAPIBackend: 산책 종료 실패 - ID: $walkId, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 종료 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 업데이트
  Future<Result<WalkRecordEntity>> updateWalkRecord(
    WalkRecordEntity walkRecord,
  ) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 기록 업데이트 요청 - ID: ${walkRecord.id}');

      final result = await BackendWalkApiService.updateWalk(
        walkRecord.id,
        endTime: walkRecord.endTime?.toIso8601String(),
        duration: walkRecord.duration?.inSeconds,
        distance: walkRecord.distance,
        status: walkRecord.status.name,
        notes: walkRecord.notes,
      );

      if (result.isSuccess && result.data != null) {
        final record = _mapToWalkRecord(result.data!);

        LoggerService.debug('✅ WalkAPIBackend: 산책 기록 업데이트 성공 - ID: ${walkRecord.id}');
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
  Future<Result<void>> deleteWalkRecord(String id) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 기록 삭제 요청 - ID: $id');

      final result = await BackendWalkApiService.deleteWalk(id);

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
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 산책 통계 조회 요청');

      late final Result<Map<String, dynamic>> result;

      if (petId != null) {
        // 펫별 통계
        result = await BackendWalkApiService.getPetWalkStatistics(petId);
      } else {
        // 사용자 전체 통계
        result = await BackendWalkApiService.getUserWalkStatistics();
      }

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

  /// 현재 진행 중인 산책 조회 (구현 필요 시)
  Future<Result<WalkRecordEntity?>> getCurrentWalk() async {
    try {
      LoggerService.debug('🌐 WalkAPIBackend: 현재 산책 조회 요청');

      // 현재는 전체 산책 목록에서 in_progress 상태 찾기
      final result = await getAllWalkRecords();

      if (result.isSuccess) {
        final currentWalk = result.data?.cast<WalkRecordEntity?>().firstWhere(
          (record) => record?.status == WalkStatus.inProgress,
          orElse: () => null,
        );

        if (currentWalk != null && currentWalk.id.isNotEmpty) {
          LoggerService.debug('✅ WalkAPIBackend: 현재 산책 찾음 - ID: ${currentWalk.id}');
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
    return WalkRecordEntity(
      id: json['id']?.toString() ?? '',
      petId: json['pet_id']?.toString() ?? '',
      petName: json['pet_name']?.toString() ?? '',
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      duration: json['duration'] != null ? Duration(seconds: json['duration'] as int) : null,
      distance: (json['distance'] as num?)?.toDouble(),
      status: _parseWalkStatus(json['status']),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  /// 백엔드 응답을 WalkStatistics로 변환
  WalkStatistics _mapToWalkStatistics(Map<String, dynamic> json) {
    return WalkStatistics(
      totalWalks: (json['total_walks'] as num?)?.toInt() ?? 0,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      totalDuration: Duration(seconds: (json['total_duration'] as num?)?.toInt() ?? 0),
      averageDistance: (json['average_distance'] as num?)?.toDouble() ?? 0.0,
      averageDuration: Duration(seconds: (json['average_duration'] as num?)?.toInt() ?? 0),
    );
  }

  /// 산책 상태 파싱
  WalkStatus _parseWalkStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'in_progress':
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
