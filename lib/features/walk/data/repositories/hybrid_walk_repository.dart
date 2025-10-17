import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:flutter/foundation.dart';

import 'helpers/helpers.dart';

/// Hybrid 산책 리포지토리
/// API, 로컬 저장소, Mock 데이터를 통합 관리하는 산책 리포지토리
///
/// 데이터 우선순위:
/// 1. API (온라인 시)
/// 2. 로컬 저장소 (오프라인 시 또는 API 실패 시)
/// 3. Mock 데이터 (개발/테스트 시)
class HybridWalkRepository implements WalkRepository {
  final WalkApiService _apiService;
  final bool _useApi;

  HybridWalkRepository({
    required WalkApiService apiService,
    bool useApi = false, // 기본값: API 비활성화 (추후 활성화)
  }) : _apiService = apiService,
       _useApi = useApi;

  /// API 사용 여부
  bool get isApiEnabled => _useApi;

  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    // 1차: API 시도
    final apiRecords = await WalkApiHelper.tryGetAllRecords(
      apiService: _apiService,
      useApi: _useApi,
    );
    if (apiRecords != null) return apiRecords;

    // 2차: 로컬 저장소
    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();
      debugPrint('✅ HybridWalkRepository: 로컬 데이터 ${localRecords.length}개 로드');
      return localRecords;
    } catch (e) {
      debugPrint('⚠️ HybridWalkRepository: 로컬 데이터 로드 실패 - $e');
      return [];
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecords() async {
    return getAllWalkRecords();
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String recordId) async {
    // 1차: API 시도
    final apiRecord = await WalkApiHelper.tryGetRecord(
      apiService: _apiService,
      recordId: recordId,
      useApi: _useApi,
    );
    if (apiRecord != null) return apiRecord;

    // 2차: 로컬 저장소
    return WalkLocalHelper.getRecordById(recordId);
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    // 1차: API 시도
    final apiRecords = await WalkApiHelper.tryGetRecordsByPet(
      apiService: _apiService,
      petId: petId,
      useApi: _useApi,
    );
    if (apiRecords != null) return apiRecords;

    // 2차: 로컬 저장소
    return WalkLocalHelper.getRecordsByPet(petId);
  }

  @override
  Future<WalkRecordEntity?> getCurrentWalk() async {
    // 1차: API 시도
    if (_useApi) {
      try {
        debugPrint('🔄 HybridWalkRepository: API에서 현재 산책 조회');
        final apiResult = await _apiService.getCurrentWalk();

        if (apiResult.isSuccess) {
          final record = apiResult.data;
          if (record != null) {
            await LocalWalkStorageService.saveCurrentWalk(record);
            debugPrint('✅ HybridWalkRepository: 현재 산책 로드 완료');
          }
          return record;
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 호출 실패 - $e');
      }
    }

    // 2차: 로컬 저장소
    try {
      final currentWalk = await LocalWalkStorageService.loadCurrentWalk();
      if (currentWalk != null) {
        debugPrint('✅ HybridWalkRepository: 로컬 현재 산책 로드');
        return currentWalk;
      }
    } catch (e) {
      debugPrint('⚠️ HybridWalkRepository: 로컬 현재 산책 조회 실패 - $e');
    }

    debugPrint('ℹ️ HybridWalkRepository: 진행 중인 산책 없음');
    return null;
  }

  @override
  Future<WalkRecordEntity> startWalk(WalkRecordEntity walkRecord) async {
    // 로컬 우선 저장 (빠른 UI 반영)
    await LocalWalkStorageService.addWalkRecord(walkRecord);
    await LocalWalkStorageService.saveCurrentWalk(walkRecord);
    debugPrint('✅ HybridWalkRepository: 로컬에 산책 시작 저장 - ID: ${walkRecord.id}');

    // API 동기화 (백그라운드)
    if (_useApi) {
      try {
        final apiResult = await _apiService.startWalk(walkRecord);
        if (apiResult.isSuccess && apiResult.data != null) {
          final syncedRecord = apiResult.data!;
          // API 응답으로 로컬 업데이트
          await LocalWalkStorageService.updateWalkRecord(syncedRecord);
          await LocalWalkStorageService.saveCurrentWalk(syncedRecord);
          debugPrint(
            '✅ HybridWalkRepository: API 동기화 완료 - ID: ${syncedRecord.id}',
          );
          return syncedRecord;
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 동기화 실패 (로컬 데이터 유지) - $e');
        // 동기화 큐에 추가
        await WalkSyncHelper.addToSyncQueue(
          WalkSyncHelper.createSyncOperation(walkRecord),
        );
      }
    }

    return walkRecord;
  }

  @override
  Future<WalkRecordEntity> endWalk(
    String recordId, {
    double? distance,
    String? notes,
  }) async {
    // 로컬에서 기록 가져오기
    final localRecords = await LocalWalkStorageService.loadWalkRecords();
    final recordIndex = localRecords.indexWhere((r) => r.id == recordId);

    if (recordIndex == -1) {
      throw ArgumentError('산책 기록을 찾을 수 없습니다: $recordId');
    }

    final currentRecord = localRecords[recordIndex];
    final endTime = DateTime.now();

    // 산책 기록 업데이트
    final updatedRecord = currentRecord.copyWith(
      endTime: endTime,
      duration: endTime.difference(currentRecord.startTime),
      distance: distance ?? currentRecord.distance ?? 0.0,
      status: WalkStatus.completed,
      notes: notes ?? currentRecord.notes,
    );

    // 로컬 우선 저장
    await LocalWalkStorageService.updateWalkRecord(updatedRecord);
    await LocalWalkStorageService.saveCurrentWalk(null); // 현재 산책 제거
    debugPrint('✅ HybridWalkRepository: 로컬에 산책 종료 저장 - ID: $recordId');

    // API 동기화
    if (_useApi) {
      try {
        final apiResult = await _apiService.endWalk(
          recordId,
          distance: distance,
          notes: notes,
        );
        if (apiResult.isSuccess && apiResult.data != null) {
          final syncedRecord = apiResult.data!;
          await LocalWalkStorageService.updateWalkRecord(syncedRecord);
          debugPrint('✅ HybridWalkRepository: API 동기화 완료 - ID: $recordId');
          return syncedRecord;
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 동기화 실패 (로컬 데이터 유지) - $e');
        // 동기화 큐에 추가
        await WalkSyncHelper.addToSyncQueue(
          WalkSyncHelper.updateSyncOperation(updatedRecord),
        );
      }
    }

    return updatedRecord;
  }

  @override
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
    // 로컬 저장
    await LocalWalkStorageService.addWalkRecord(walkRecord);
    debugPrint('✅ HybridWalkRepository: 로컬에 산책 기록 저장 - ID: ${walkRecord.id}');

    // API 동기화
    if (_useApi) {
      try {
        // startWalk API 사용
        final apiResult = await _apiService.startWalk(walkRecord);
        if (apiResult.isSuccess) {
          debugPrint(
            '✅ HybridWalkRepository: API 동기화 완료 - ID: ${walkRecord.id}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 동기화 실패 - $e');
        // 동기화 큐에 추가
        await WalkSyncHelper.addToSyncQueue(
          WalkSyncHelper.createSyncOperation(walkRecord),
        );
      }
    }
  }

  @override
  Future<void> updateWalkRecord(WalkRecordEntity walkRecord) async {
    // 로컬 업데이트
    await LocalWalkStorageService.updateWalkRecord(walkRecord);
    debugPrint('✅ HybridWalkRepository: 로컬 산책 기록 업데이트 - ID: ${walkRecord.id}');

    // API 동기화
    if (_useApi) {
      try {
        final apiResult = await _apiService.updateWalkRecord(walkRecord);
        if (apiResult.isSuccess) {
          debugPrint(
            '✅ HybridWalkRepository: API 동기화 완료 - ID: ${walkRecord.id}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 동기화 실패 (나중에 재시도 필요) - $e');
        // 동기화 큐에 추가
        await WalkSyncHelper.addToSyncQueue(
          WalkSyncHelper.updateSyncOperation(walkRecord),
        );
      }
    }
  }

  @override
  Future<void> deleteWalkRecord(String id) async {
    // 로컬 삭제
    await LocalWalkStorageService.deleteWalkRecord(id);
    debugPrint('✅ HybridWalkRepository: 로컬 산책 기록 삭제 - ID: $id');

    // API 동기화
    if (_useApi) {
      try {
        final apiResult = await _apiService.deleteWalkRecord(id);
        if (apiResult.isSuccess) {
          debugPrint('✅ HybridWalkRepository: API 동기화 완료 - ID: $id');
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 동기화 실패 (나중에 재시도 필요) - $e');
        // 동기화 큐에 추가
        await WalkSyncHelper.addToSyncQueue(
          WalkSyncHelper.deleteSyncOperation(id),
        );
      }
    }
  }

  /// 대기 중인 동기화 작업 처리
  Future<void> processPendingSync() async {
    if (!_useApi) {
      debugPrint('ℹ️ API 비활성화 상태, 동기화 건너뜀');
      return;
    }

    await WalkSyncHelper.processPendingSync(apiService: _apiService);
  }

  @override
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1차: API 시도
    if (_useApi) {
      try {
        debugPrint('🔄 HybridWalkRepository: API에서 산책 통계 조회');
        final apiResult = await _apiService.getWalkStatistics(
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        );

        if (apiResult.isSuccess && apiResult.data != null) {
          debugPrint('✅ HybridWalkRepository: API 통계 데이터 로드 완료');
          return apiResult.data!;
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 호출 실패 - $e');
      }
    }

    // 2차: 로컬 저장소에서 통계 계산
    return WalkLocalHelper.calculateStatistics(
      petId: petId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
