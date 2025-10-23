import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/shared/core/api/api_client.dart';
import 'package:aipet_frontend/shared/core/api/api_constants.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';

/// 산책 API 서비스
/// API를 통한 산책 기록 CRUD 및 통계 조회
class WalkApiService {
  final ApiClient _apiClient;

  WalkApiService(this._apiClient);

  /// 모든 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getAllWalkRecords() async {
    try {
      LoggerService.debug('🌐 WalkAPI: 전체 산책 기록 조회 요청');

      final response = await _apiClient.get(ApiEndpoints.walks);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['walks'] ?? [];
        final records = data
            .map(
              (json) => WalkRecordEntity.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        LoggerService.debug('✅ WalkAPI: ${records.length}개 산책 기록 조회 성공');
        return Result.success('산책 기록을 가져왔습니다', records);
      }

      LoggerService.debug('⚠️ WalkAPI: 응답 데이터 없음');
      return Result.failure('산책 기록을 가져올 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 기록 조회 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// ID로 산책 기록 조회
  Future<Result<WalkRecordEntity>> getWalkRecordById(String id) async {
    try {
      LoggerService.debug('🌐 WalkAPI: 산책 기록 조회 - ID: $id');

      final response = await _apiClient.get(ApiEndpoints.walkById(id));

      if (response.statusCode == 200 && response.data != null) {
        final record = WalkRecordEntity.fromJson(
          response.data as Map<String, dynamic>,
        );

        LoggerService.debug('✅ WalkAPI: 산책 기록 조회 성공 - ID: $id');
        return Result.success('산책 기록을 가져왔습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPI: 산책 기록 없음 - ID: $id');
      return Result.failure('산책 기록을 찾을 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 기록 조회 실패 - ID: $id, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// 펫별 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getWalkRecordsByPetId(
    String petId,
  ) async {
    try {
      LoggerService.debug('🌐 WalkAPI: 펫별 산책 기록 조회 - Pet ID: $petId');

      final response = await _apiClient.get(
        ApiEndpoints.walks,
        queryParameters: {'petId': petId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['walks'] ?? [];
        final records = data
            .map(
              (json) => WalkRecordEntity.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        LoggerService.debug(
          '✅ WalkAPI: ${records.length}개 산책 기록 조회 성공 (Pet ID: $petId)',
        );
        return Result.success('펫 산책 기록을 가져왔습니다', records);
      }

      LoggerService.debug('⚠️ WalkAPI: 응답 데이터 없음 (Pet ID: $petId)');
      return Result.failure('펫 산책 기록을 가져올 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 펫 산책 기록 조회 실패 - Pet ID: $petId, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('펫 산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// 산책 시작
  Future<Result<WalkRecordEntity>> startWalk(
    WalkRecordEntity walkRecord,
  ) async {
    try {
      LoggerService.debug('🌐 WalkAPI: 산책 시작 요청 - Pet: ${walkRecord.petName}');

      final response = await _apiClient.post(
        ApiEndpoints.walks,
        data: walkRecord.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final record = WalkRecordEntity.fromJson(
          response.data as Map<String, dynamic>,
        );

        LoggerService.debug('✅ WalkAPI: 산책 시작 성공 - ID: ${record.id}');
        return Result.success('산책이 시작되었습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPI: 산책 시작 응답 오류');
      return Result.failure('산책을 시작할 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 시작 실패 - $e');
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
      LoggerService.debug('🌐 WalkAPI: 산책 종료 요청 - ID: $walkId');

      final response = await _apiClient.put(
        ApiEndpoints.walkById(walkId),
        data: {
          'status': 'completed',
          'distance': distance,
          'notes': notes,
          'endTime': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final record = WalkRecordEntity.fromJson(
          response.data as Map<String, dynamic>,
        );

        LoggerService.debug('✅ WalkAPI: 산책 종료 성공 - ID: $walkId');
        return Result.success('산책이 종료되었습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPI: 산책 종료 응답 오류');
      return Result.failure('산책을 종료할 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 종료 실패 - ID: $walkId, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 종료 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 업데이트
  Future<Result<WalkRecordEntity>> updateWalkRecord(
    WalkRecordEntity walkRecord,
  ) async {
    try {
      LoggerService.debug('🌐 WalkAPI: 산책 기록 업데이트 요청 - ID: ${walkRecord.id}');

      final response = await _apiClient.put(
        ApiEndpoints.walkById(walkRecord.id),
        data: walkRecord.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final record = WalkRecordEntity.fromJson(
          response.data as Map<String, dynamic>,
        );

        LoggerService.debug('✅ WalkAPI: 산책 기록 업데이트 성공 - ID: ${walkRecord.id}');
        return Result.success('산책 기록이 업데이트되었습니다', record);
      }

      LoggerService.debug('⚠️ WalkAPI: 산책 기록 업데이트 응답 오류');
      return Result.failure('산책 기록을 업데이트할 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 기록 업데이트 실패 - ID: ${walkRecord.id}, Error: $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 기록 업데이트 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 삭제
  Future<Result<void>> deleteWalkRecord(String id) async {
    try {
      LoggerService.debug('🌐 WalkAPI: 산책 기록 삭제 요청 - ID: $id');

      final response = await _apiClient.delete(ApiEndpoints.walkById(id));

      if (response.statusCode == 200 || response.statusCode == 204) {
        LoggerService.debug('✅ WalkAPI: 산책 기록 삭제 성공 - ID: $id');
        return Result.success('산책 기록이 삭제되었습니다');
      }

      LoggerService.debug('⚠️ WalkAPI: 산책 기록 삭제 응답 오류');
      return Result.failure('산책 기록을 삭제할 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 기록 삭제 실패 - ID: $id, Error: $e');
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
      LoggerService.debug('🌐 WalkAPI: 산책 통계 조회 요청');

      final queryParams = <String, dynamic>{};
      if (petId != null) queryParams['petId'] = petId;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '${ApiEndpoints.walks}/statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final stats = WalkStatistics.fromJson(
          response.data as Map<String, dynamic>,
        );

        LoggerService.debug('✅ WalkAPI: 산책 통계 조회 성공');
        return Result.success('산책 통계를 가져왔습니다', stats);
      }

      LoggerService.debug('⚠️ WalkAPI: 산책 통계 응답 오류');
      return Result.failure('산책 통계를 가져올 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 산책 통계 조회 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('산책 통계 조회 실패: ${e.toString()}');
    }
  }

  /// 현재 진행 중인 산책 조회
  Future<Result<WalkRecordEntity?>> getCurrentWalk() async {
    try {
      LoggerService.debug('🌐 WalkAPI: 현재 산책 조회 요청');

      final response = await _apiClient.get('${ApiEndpoints.walks}/current');

      if (response.statusCode == 200 && response.data != null) {
        final record = WalkRecordEntity.fromJson(
          response.data as Map<String, dynamic>,
        );

        LoggerService.debug('✅ WalkAPI: 현재 산책 조회 성공 - ID: ${record.id}');
        return Result.success('현재 산책을 가져왔습니다', record);
      }

      if (response.statusCode == 204) {
        LoggerService.debug('ℹ️ WalkAPI: 진행 중인 산책 없음');
        return Result.success('진행 중인 산책이 없습니다', null);
      }

      LoggerService.debug('⚠️ WalkAPI: 현재 산책 조회 응답 오류');
      return Result.failure('현재 산책을 확인할 수 없습니다');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkAPI: 현재 산책 조회 실패 - $e');
      LoggerService.debug('StackTrace: $stackTrace');
      return Result.failure('현재 산책 조회 실패: ${e.toString()}');
    }
  }
}
