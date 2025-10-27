import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

/// 산책 리포지토리 구현체
class WalkRepositoryImpl implements WalkRepository {
  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final localRecords = await LocalWalkStorageService.loadWalkRecords();
    return localRecords;
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 로컬 저장소에서 찾기
    final localWalkRecords = await LocalWalkStorageService.loadWalkRecords();
    try {
      return localWalkRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final localRecords = await LocalWalkStorageService.loadWalkRecords();
    return localRecords.where((record) => record.petId == petId).toList();
  }

  @override
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 로컬 저장소에서 통계 계산
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
  }

  @override
  Future<WalkRecordEntity?> getCurrentWalk() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 현재 진행 중인 산책이 있다고 가정
    return null;
  }

  @override
  Future<WalkRecordEntity> startWalk(WalkRecordEntity walkRecord) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return walkRecord;
  }

  @override
  Future<WalkRecordEntity> endWalk(
    String walkId, {
    double? distance,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 현재 산책 기록을 로컬에서 가져와서 업데이트
    final walkRecords = await LocalWalkStorageService.loadWalkRecords();
    final currentRecordIndex = walkRecords.indexWhere(
      (record) => record.id == walkId,
    );

    if (currentRecordIndex == -1) {
      throw ArgumentError('산책 기록을 찾을 수 없습니다: $walkId');
    }

    final currentRecord = walkRecords[currentRecordIndex];
    final endTime = DateTime.now();

    LoggerService.debug('🏁 산책 종료: ID=${walkId}');
    LoggerService.debug('   - 현재 route 포인트: ${currentRecord.route.length}개');
    LoggerService.debug('   - 거리: ${distance ?? 0.0}km');

    // 산책 기록 업데이트 (route 데이터 유지)
    final updatedRecord = currentRecord.copyWith(
      endTime: endTime,
      duration: endTime.difference(currentRecord.startTime),
      distance: distance ?? 0.0,
      status: WalkStatus.completed,
      notes: notes ?? currentRecord.notes,
      route: currentRecord.route, // ✅ route 데이터 명시적으로 유지
    );

    LoggerService.debug('✅ 업데이트된 route 포인트: ${updatedRecord.route.length}개');

    // 업데이트된 기록을 리스트에 반영
    walkRecords[currentRecordIndex] = updatedRecord;

    // 로컬 저장소에 저장
    await LocalWalkStorageService.saveWalkRecords(walkRecords);

    return updatedRecord;
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecords() async {
    return getAllWalkRecords();
  }

  @override
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
    // 로컬 저장소에 기록 추가
    await LocalWalkStorageService.addWalkRecord(walkRecord);
  }

  @override
  Future<void> updateWalkRecord(WalkRecordEntity walkRecord) async {
    // 로컬 저장소에 기록 업데이트
    await LocalWalkStorageService.updateWalkRecord(walkRecord);
  }

  @override
  Future<void> deleteWalkRecord(String id) async {
    // 로컬 저장소에서 기록 삭제
    await LocalWalkStorageService.deleteWalkRecord(id);
  }
}
