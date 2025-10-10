import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/shared/services/local_walk_storage_service.dart';

/// 산책 리포지토리 Mockito 구현체
class WalkRepositoryMockitoImpl implements WalkRepository {
  final List<WalkRecordEntity> _walkRecords = [];

  WalkRepositoryMockitoImpl() {
    _initializeMockData();
  }

  void _initializeMockData() async {
    final localRecords = await LocalWalkStorageService.loadWalkRecords();
    _walkRecords.addAll(localRecords);
  }

  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_walkRecords);
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _walkRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _walkRecords.where((record) => record.petId == petId).toList();
  }

  @override
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 필터 적용
    final filtered = _walkRecords.where((r) {
      if (petId != null && r.petId != petId) return false;
      if (startDate != null && r.startTime.isBefore(startDate)) return false;
      if (endDate != null && r.startTime.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return WalkStatistics.empty();
    }

    // 통계 계산
    final totalWalks = filtered.length;
    final totalDistance = filtered.fold<double>(
      0.0,
      (sum, record) => sum + (record.distance ?? 0.0),
    );
    final totalDuration = filtered.fold<Duration>(
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
      lastWalkDate: filtered.isNotEmpty ? filtered.last.startTime : null,
    );
  }

  @override
  Future<WalkRecordEntity?> getCurrentWalk() async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _walkRecords.firstWhere(
        (record) => record.status == WalkStatus.inProgress,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<WalkRecordEntity> startWalk(WalkRecordEntity walkRecord) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _walkRecords.add(walkRecord);
    return walkRecord;
  }

  @override
  Future<WalkRecordEntity> endWalk(
    String walkId, {
    double? distance,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _walkRecords.indexWhere((record) => record.id == walkId);
    if (index != -1) {
      final record = _walkRecords[index];
      final updatedRecord = record.copyWith(
        endTime: DateTime.now(),
        distance: distance ?? record.distance,
        notes: notes ?? record.notes,
        status: WalkStatus.completed,
      );
      _walkRecords[index] = updatedRecord;
      return updatedRecord;
    }
    throw Exception('산책 기록을 찾을 수 없습니다: $walkId');
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecords() async {
    return getAllWalkRecords();
  }

  @override
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _walkRecords.add(walkRecord);
  }

  @override
  Future<void> updateWalkRecord(WalkRecordEntity walkRecord) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _walkRecords.indexWhere(
      (record) => record.id == walkRecord.id,
    );
    if (index != -1) {
      _walkRecords[index] = walkRecord;
    }
  }

  @override
  Future<void> deleteWalkRecord(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _walkRecords.removeWhere((record) => record.id == id);
  }
}
