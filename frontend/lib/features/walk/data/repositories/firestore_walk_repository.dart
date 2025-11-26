import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/shared/core/services/firestore_walk_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

/// Firestore를 사용하는 산책 리포지토리 구현체
class FirestoreWalkRepository implements WalkRepository {
  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    LoggerService.debug('📡 FirestoreWalkRepository.getAllWalkRecords() 호출');
    final result = await FirestoreWalkService.getAllWalkRecords();

    if (result.isSuccess) {
      LoggerService.debug('✅ getAllWalkRecords 성공: ${result.dataOrNull?.length}개');
      return result.dataOrNull ?? [];
    } else {
      LoggerService.debug('❌ getAllWalkRecords 실패: ${result.error}');
      return [];
    }
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String id) async {
    LoggerService.debug('📡 FirestoreWalkRepository.getWalkRecordById($id) 호출');
    final result = await FirestoreWalkService.getWalkRecordById(id);

    if (result.isSuccess) {
      LoggerService.debug('✅ getWalkRecordById 성공');
      return result.dataOrNull;
    } else {
      LoggerService.debug('❌ getWalkRecordById 실패: ${result.error}');
      return null;
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    LoggerService.debug('📡 FirestoreWalkRepository.getWalkRecordsByPetId($petId) 호출');
    final result = await FirestoreWalkService.getWalkRecordsByPetId(petId);

    if (result.isSuccess) {
      LoggerService.debug('✅ getWalkRecordsByPetId 성공: ${result.dataOrNull?.length}개');
      return result.dataOrNull ?? [];
    } else {
      LoggerService.debug('❌ getWalkRecordsByPetId 실패: ${result.error}');
      return [];
    }
  }

  @override
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    LoggerService.debug('📡 FirestoreWalkRepository.getWalkStatistics() 호출');

    // Firestore에서 기록 가져오기
    List<WalkRecordEntity> records;

    if (startDate != null && endDate != null) {
      final result = await FirestoreWalkService.getWalkRecordsByDateRange(
        startDate,
        endDate,
      );
      records = result.dataOrNull ?? [];
    } else if (petId != null) {
      final result = await FirestoreWalkService.getWalkRecordsByPetId(petId);
      records = result.dataOrNull ?? [];
    } else {
      final result = await FirestoreWalkService.getAllWalkRecords();
      records = result.dataOrNull ?? [];
    }

    // 펫 필터 적용 (날짜 범위 조회 후)
    if (petId != null) {
      records = records.where((r) => r.petId == petId).toList();
    }

    // 날짜 범위 필터 추가 적용 (필요시)
    records = records.where((r) {
      if (startDate != null && r.startTime.isBefore(startDate)) return false;
      if (endDate != null && r.startTime.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (records.isEmpty) {
      return WalkStatistics.empty();
    }

    // 통계 계산
    final totalWalks = records.length;
    final totalDistance = records.fold<double>(
      0.0,
      (sum, record) => sum + (record.distance ?? 0.0),
    );
    final totalDuration = records.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + (record.duration ?? Duration.zero),
    );

    LoggerService.debug('✅ getWalkStatistics 계산 완료: $totalWalks회');

    return WalkStatistics(
      totalWalks: totalWalks,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
      averageDistance: totalWalks > 0 ? totalDistance / totalWalks : 0.0,
      averageDuration: totalWalks > 0
          ? Duration(milliseconds: totalDuration.inMilliseconds ~/ totalWalks)
          : Duration.zero,
      lastWalkDate: records.isNotEmpty ? records.last.startTime : null,
    );
  }

  @override
  Future<WalkRecordEntity?> getCurrentWalk() async {
    LoggerService.debug('📡 FirestoreWalkRepository.getCurrentWalk() 호출');

    // 진행 중인 산책 찾기 (status == inProgress)
    final result = await FirestoreWalkService.getAllWalkRecords();

    if (result.isSuccess) {
      final records = result.dataOrNull ?? [];
      try {
        final currentWalk = records.firstWhere(
          (record) => record.status == WalkStatus.inProgress,
        );
        LoggerService.debug('✅ 진행 중인 산책 발견: ${currentWalk.id}');
        return currentWalk;
      } catch (e) {
        LoggerService.debug('ℹ️ 진행 중인 산책 없음');
        return null;
      }
    } else {
      LoggerService.debug('❌ getCurrentWalk 실패: ${result.error}');
      return null;
    }
  }

  @override
  Future<WalkRecordEntity> startWalk(WalkRecordEntity walkRecord) async {
    LoggerService.debug('📡 FirestoreWalkRepository.startWalk() 호출');
    LoggerService.debug('   펫: ${walkRecord.petName}');

    final result = await FirestoreWalkService.createWalkRecord(walkRecord);

    if (result.isSuccess && result.dataOrNull != null) {
      LoggerService.debug('✅ startWalk 성공: ${result.dataOrNull!.id}');
      return result.dataOrNull!;
    } else {
      LoggerService.debug('❌ startWalk 실패: ${result.error}');
      throw Exception('산책 시작에 실패했습니다: ${result.error}');
    }
  }

  @override
  Future<WalkRecordEntity> endWalk(
    String walkId, {
    double? distance,
    String? notes,
  }) async {
    LoggerService.debug('📡 FirestoreWalkRepository.endWalk($walkId) 호출');
    LoggerService.debug('   거리: ${distance ?? 0.0}km');

    // 현재 산책 기록 가져오기
    final getResult = await FirestoreWalkService.getWalkRecordById(walkId);

    if (!getResult.isSuccess || getResult.dataOrNull == null) {
      LoggerService.debug('❌ 산책 기록을 찾을 수 없음: $walkId');
      throw ArgumentError('산책 기록을 찾을 수 없습니다: $walkId');
    }

    final currentRecord = getResult.dataOrNull!;
    final endTime = DateTime.now();

    LoggerService.debug('🏁 산책 종료: ID=$walkId');
    LoggerService.debug('   현재 route 포인트: ${currentRecord.route.length}개');

    // 산책 기록 업데이트 (route 데이터 유지)
    final updatedRecord = currentRecord.copyWith(
      endTime: endTime,
      duration: endTime.difference(currentRecord.startTime),
      distance: distance ?? 0.0,
      status: WalkStatus.completed,
      notes: notes ?? currentRecord.notes,
      route: currentRecord.route,
    );

    LoggerService.debug('✅ 업데이트된 route 포인트: ${updatedRecord.route.length}개');

    // Firestore에 업데이트
    final updateResult = await FirestoreWalkService.updateWalkRecord(updatedRecord);

    if (updateResult.isSuccess && updateResult.dataOrNull != null) {
      LoggerService.debug('✅ endWalk 성공');
      return updateResult.dataOrNull!;
    } else {
      LoggerService.debug('❌ endWalk 실패: ${updateResult.error}');
      throw Exception('산책 종료에 실패했습니다: ${updateResult.error}');
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecords() async {
    return getAllWalkRecords();
  }

  @override
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
    LoggerService.debug('📡 FirestoreWalkRepository.saveWalkRecord() 호출');

    // ID가 있으면 업데이트, 없으면 생성
    if (walkRecord.id.isNotEmpty) {
      await FirestoreWalkService.updateWalkRecord(walkRecord);
    } else {
      await FirestoreWalkService.createWalkRecord(walkRecord);
    }
  }

  @override
  Future<void> deleteWalkRecord(String id) async {
    LoggerService.debug('📡 FirestoreWalkRepository.deleteWalkRecord($id) 호출');

    final result = await FirestoreWalkService.deleteWalkRecord(id);

    if (!result.isSuccess) {
      LoggerService.debug('❌ deleteWalkRecord 실패: ${result.error}');
      throw Exception('산책 기록 삭제에 실패했습니다: ${result.error}');
    }

    LoggerService.debug('✅ deleteWalkRecord 성공');
  }
}
