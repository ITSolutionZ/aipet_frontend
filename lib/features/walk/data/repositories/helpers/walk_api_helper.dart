import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/foundation.dart';

/// Walk API 호출 헬퍼
class WalkApiHelper {
  /// API 호출 시도 및 로컬 캐시 업데이트 (단일 레코드)
  static Future<WalkRecordEntity?> tryGetRecord({
    required WalkApiService apiService,
    required String recordId,
    required bool useApi,
  }) async {
    if (!useApi) return null;

    try {
      LoggerService.debug('🔄 HybridWalkRepository: API에서 산책 기록 조회 - ID: $recordId');
      final apiResult = await apiService.getWalkRecordById(recordId);

      if (apiResult.isSuccess && apiResult.data != null) {
        final record = apiResult.dataOrThrow;
        // API 성공 시 로컬 캐시 업데이트
        await LocalWalkStorageService.updateWalkRecord(record);
        LoggerService.debug('✅ HybridWalkRepository: API 데이터 로드 완료 - ID: $recordId');
        return record;
      }
    } catch (e) {
      LoggerService.debug(
        '⚠️ HybridWalkRepository: API 호출 실패 - ID: $recordId, Error: $e',
      );
    }

    return null;
  }

  /// API 호출 시도 및 로컬 캐시 업데이트 (전체 레코드)
  static Future<List<WalkRecordEntity>?> tryGetAllRecords({
    required WalkApiService apiService,
    required bool useApi,
  }) async {
    if (!useApi) return null;

    try {
      LoggerService.debug('🔄 HybridWalkRepository: API에서 산책 기록 조회 시도');
      final apiResult = await apiService.getAllWalkRecords();

      if (apiResult.isSuccess && apiResult.data != null) {
        final records = apiResult.dataOrThrow;
        // API 성공 시 로컬 캐시 동기화
        await LocalWalkStorageService.saveWalkRecords(records);
        LoggerService.debug('✅ HybridWalkRepository: API 데이터 ${records.length}개 로드 완료');
        return records;
      }
    } catch (e) {
      LoggerService.debug('⚠️ HybridWalkRepository: API 호출 실패, 로컬 데이터 사용 - $e');
    }

    return null;
  }

  /// API 호출 시도 및 로컬 캐시 업데이트 (펫별 레코드)
  static Future<List<WalkRecordEntity>?> tryGetRecordsByPet({
    required WalkApiService apiService,
    required String petId,
    required bool useApi,
  }) async {
    if (!useApi) return null;

    try {
      LoggerService.debug('🔄 HybridWalkRepository: API에서 펫 산책 기록 조회 - Pet ID: $petId');
      final apiResult = await apiService.getWalkRecordsByPetId(petId);

      if (apiResult.isSuccess && apiResult.data != null) {
        final records = apiResult.dataOrThrow;
        LoggerService.debug('✅ HybridWalkRepository: API 펫 데이터 ${records.length}개 로드');
        return records;
      }
    } catch (e) {
      LoggerService.debug(
        '⚠️ HybridWalkRepository: API 호출 실패 - Pet ID: $petId, Error: $e',
      );
    }

    return null;
  }
}
