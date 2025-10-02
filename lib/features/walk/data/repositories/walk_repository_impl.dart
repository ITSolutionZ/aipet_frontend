import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/shared/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/walk/walk_mock_service.dart';

/// 산책 리포지토리 구현체
class WalkRepositoryImpl implements WalkRepository {
  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final mockData = WalkMockService.getMockWalkRecords();
    return mockData.map((data) => WalkRecordEntity.fromJson(data)).toList();
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 먼저 로컬 저장소에서 찾기
    final localWalkRecords = await LocalWalkStorageService.loadWalkRecords();
    try {
      return localWalkRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      // 로컬에 없으면 Mock 데이터에서 찾기
      final mockData = WalkMockService.getMockWalkRecords();
      final data = mockData.firstWhere(
        (record) => record['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      return data.isNotEmpty ? WalkRecordEntity.fromJson(data) : null;
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final mockData = WalkMockService.getMockWalkRecords();
    final filteredData = mockData
        .where((record) => record['petId'] == petId)
        .toList();
    return filteredData.map((data) => WalkRecordEntity.fromJson(data)).toList();
  }

  @override
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final mockData = WalkMockService.getMockWeeklyWalkStats(petId: petId);
    return WalkStatistics.fromJson(mockData);
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

    // 산책 기록 업데이트
    final updatedRecord = currentRecord.copyWith(
      endTime: endTime,
      duration: endTime.difference(currentRecord.startTime),
      distance: distance ?? 0.0,
      status: WalkStatus.completed,
      notes: notes ?? currentRecord.notes,
    );

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
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock 구현 - 실제로는 데이터베이스에 저장
  }

  @override
  Future<void> updateWalkRecord(WalkRecordEntity walkRecord) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock 구현 - 실제로는 데이터베이스에 업데이트
  }

  @override
  Future<void> deleteWalkRecord(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock 구현 - 실제로는 데이터베이스에서 삭제
  }
}
