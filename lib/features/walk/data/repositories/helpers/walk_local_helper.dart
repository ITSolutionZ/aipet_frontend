import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:flutter/foundation.dart';

/// Walk 로컬 저장소 헬퍼
class WalkLocalHelper {
  /// 로컬에서 레코드 조회 (단일)
  static Future<WalkRecordEntity?> getRecordById(String recordId) async {
    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();
      final record = localRecords.where((r) => r.id == recordId).firstOrNull;

      if (record != null) {
        LoggerService.debug('✅ HybridWalkRepository: 로컬 데이터 로드 - ID: $recordId');
        return record;
      }
    } catch (e) {
      LoggerService.debug('⚠️ HybridWalkRepository: 로컬 데이터 조회 실패 - $e');
    }

    LoggerService.debug('ℹ️ HybridWalkRepository: 산책 기록을 찾을 수 없음 - ID: $recordId');
    return null;
  }

  /// 로컬에서 펫별 레코드 조회
  static Future<List<WalkRecordEntity>> getRecordsByPet(String petId) async {
    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();
      final petRecords = localRecords.where((r) => r.petId == petId).toList();
      LoggerService.debug('✅ HybridWalkRepository: 로컬 펫 데이터 ${petRecords.length}개 로드');
      return petRecords;
    } catch (e) {
      LoggerService.debug('⚠️ HybridWalkRepository: 로컬 데이터 조회 실패 - $e');
      return [];
    }
  }

  /// 로컬에서 통계 계산
  static Future<WalkStatistics> calculateStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    LoggerService.debug('ℹ️ HybridWalkRepository: 로컬 데이터로 통계 계산');

    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();

      // 펫 필터 적용
      final filteredRecords = petId != null
          ? localRecords.where((r) => r.petId == petId).toList()
          : localRecords;

      // 날짜 범위 필터 적용
      final dateFilteredRecords = filteredRecords.where((r) {
        if (startDate != null && r.startTime.isBefore(startDate)) return false;
        if (endDate != null && r.startTime.isAfter(endDate)) return false;
        return true;
      }).toList();

      if (dateFilteredRecords.isEmpty) {
        return WalkStatistics.empty();
      }

      // 통계 계산
      final totalWalks = dateFilteredRecords.length;
      final totalDistance = dateFilteredRecords.fold<double>(
        0.0,
        (sum, record) => sum + (record.distance ?? 0.0),
      );
      final totalDuration = dateFilteredRecords.fold<Duration>(
        Duration.zero,
        (sum, record) => sum + (record.duration ?? Duration.zero),
      );

      return WalkStatistics(
        totalWalks: totalWalks,
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        averageDistance: totalWalks > 0 ? totalDistance / totalWalks : 0.0,
        averageDuration: totalWalks > 0
            ? Duration(milliseconds: totalDuration.inMilliseconds ~/ totalWalks)
            : Duration.zero,
        lastWalkDate: dateFilteredRecords.isNotEmpty
            ? dateFilteredRecords.last.startTime
            : null,
      );
    } catch (e) {
      LoggerService.debug('⚠️ HybridWalkRepository: 로컬 통계 계산 실패 - $e');
      return WalkStatistics.empty();
    }
  }
}
