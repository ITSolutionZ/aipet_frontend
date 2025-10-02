import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_statistics_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/shared/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/shared/services/sync_queue_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/walk/walk_mock_service.dart';
import 'package:flutter/foundation.dart';

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
  final SyncQueueService _syncQueue = SyncQueueService.instance;

  HybridWalkRepository({
    required WalkApiService apiService,
    bool useApi = false, // 기본값: API 비활성화 (추후 활성화)
  }) : _apiService = apiService,
       _useApi = useApi;

  /// API 사용 여부
  bool get isApiEnabled => _useApi;

  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    // 1차: API 시도 (활성화된 경우)
    if (_useApi) {
      try {
        debugPrint('🔄 HybridWalkRepository: API에서 산책 기록 조회 시도');
        final apiResult = await _apiService.getAllWalkRecords();

        if (apiResult.isSuccess && apiResult.data != null) {
          final records = apiResult.data!;
          // API 성공 시 로컬 캐시 동기화
          await LocalWalkStorageService.saveWalkRecords(records);
          debugPrint(
            '✅ HybridWalkRepository: API 데이터 ${records.length}개 로드 완료',
          );
          return records;
        }
      } catch (e) {
        debugPrint('⚠️ HybridWalkRepository: API 호출 실패, 로컬 데이터 사용 - $e');
      }
    }

    // 2차: 로컬 저장소
    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();
      if (localRecords.isNotEmpty) {
        debugPrint('✅ HybridWalkRepository: 로컬 데이터 ${localRecords.length}개 로드');
        return localRecords;
      }
    } catch (e) {
      debugPrint('⚠️ HybridWalkRepository: 로컬 데이터 로드 실패 - $e');
    }

    // 3차: Mock 데이터 (Fallback)
    debugPrint('ℹ️ HybridWalkRepository: Mock 데이터 사용');
    final mockData = WalkMockService.getMockWalkRecords();
    return mockData.map((data) => WalkRecordEntity.fromJson(data)).toList();
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecords() async {
    return getAllWalkRecords();
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String recordId) async {
    // 1차: API 시도
    if (_useApi) {
      try {
        debugPrint('🔄 HybridWalkRepository: API에서 산책 기록 조회 - ID: $recordId');
        final apiResult = await _apiService.getWalkRecordById(recordId);

        if (apiResult.isSuccess && apiResult.data != null) {
          final record = apiResult.data!;
          // API 성공 시 로컬 캐시 업데이트
          await LocalWalkStorageService.updateWalkRecord(record);
          debugPrint('✅ HybridWalkRepository: API 데이터 로드 완료 - ID: $recordId');
          return record;
        }
      } catch (e) {
        debugPrint(
          '⚠️ HybridWalkRepository: API 호출 실패 - ID: $recordId, Error: $e',
        );
      }
    }

    // 2차: 로컬 저장소
    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();
      final record = localRecords.where((r) => r.id == recordId).firstOrNull;

      if (record != null) {
        debugPrint('✅ HybridWalkRepository: 로컬 데이터 로드 - ID: $recordId');
        return record;
      }
    } catch (e) {
      debugPrint('⚠️ HybridWalkRepository: 로컬 데이터 조회 실패 - $e');
    }

    // 3차: Mock 데이터
    debugPrint('ℹ️ HybridWalkRepository: Mock 데이터 사용 - ID: $recordId');
    final mockData = WalkMockService.getMockWalkRecords();
    final mockRecord = mockData
        .where((data) => data['id'] == recordId)
        .firstOrNull;

    if (mockRecord != null) {
      return WalkRecordEntity.fromJson(mockRecord);
    }

    return null;
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    // 1차: API 시도
    if (_useApi) {
      try {
        debugPrint(
          '🔄 HybridWalkRepository: API에서 펫 산책 기록 조회 - Pet ID: $petId',
        );
        final apiResult = await _apiService.getWalkRecordsByPetId(petId);

        if (apiResult.isSuccess && apiResult.data != null) {
          final records = apiResult.data!;
          debugPrint('✅ HybridWalkRepository: API 펫 데이터 ${records.length}개 로드');
          return records;
        }
      } catch (e) {
        debugPrint(
          '⚠️ HybridWalkRepository: API 호출 실패 - Pet ID: $petId, Error: $e',
        );
      }
    }

    // 2차: 로컬 저장소
    try {
      final localRecords = await LocalWalkStorageService.loadWalkRecords();
      final petRecords = localRecords.where((r) => r.petId == petId).toList();

      if (petRecords.isNotEmpty) {
        debugPrint('✅ HybridWalkRepository: 로컬 펫 데이터 ${petRecords.length}개 로드');
        return petRecords;
      }
    } catch (e) {
      debugPrint('⚠️ HybridWalkRepository: 로컬 데이터 조회 실패 - $e');
    }

    // 3차: Mock 데이터
    debugPrint('ℹ️ HybridWalkRepository: Mock 펫 데이터 사용 - Pet ID: $petId');
    final mockData = WalkMockService.getMockWalkRecords();
    final filteredData = mockData.where((record) => record['petId'] == petId);
    return filteredData.map((data) => WalkRecordEntity.fromJson(data)).toList();
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
        await _addToSyncQueue(
          SyncOperation(
            id: walkRecord.id,
            type: SyncOperationType.create,
            entityType: 'walk',
            data: walkRecord.toJson(),
            timestamp: DateTime.now(),
          ),
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
        await _addToSyncQueue(
          SyncOperation(
            id: recordId,
            type: SyncOperationType.update,
            entityType: 'walk',
            data: updatedRecord.toJson(),
            timestamp: DateTime.now(),
          ),
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
        await _addToSyncQueue(
          SyncOperation(
            id: walkRecord.id,
            type: SyncOperationType.create,
            entityType: 'walk',
            data: walkRecord.toJson(),
            timestamp: DateTime.now(),
          ),
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
        await _addToSyncQueue(
          SyncOperation(
            id: walkRecord.id,
            type: SyncOperationType.update,
            entityType: 'walk',
            data: walkRecord.toJson(),
            timestamp: DateTime.now(),
          ),
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
        await _addToSyncQueue(
          SyncOperation(
            id: id,
            type: SyncOperationType.delete,
            entityType: 'walk',
            data: {'id': id},
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }

  /// 동기화 큐에 작업 추가
  Future<void> _addToSyncQueue(SyncOperation operation) async {
    try {
      await _syncQueue.addToQueue(operation);
      debugPrint('📥 동기화 큐에 추가: ${operation.type.name} - ${operation.id}');
    } catch (e) {
      debugPrint('❌ 동기화 큐 추가 실패: $e');
    }
  }

  /// 대기 중인 동기화 작업 처리
  Future<void> processPendingSync() async {
    if (!_useApi) {
      debugPrint('ℹ️ API 비활성화 상태, 동기화 건너뜀');
      return;
    }

    await _syncQueue.processPendingOperations(
      handler: (operation) async {
        try {
          if (operation.entityType != 'walk') {
            return true; // 다른 엔티티 타입은 건너뜀
          }

          switch (operation.type) {
            case SyncOperationType.create:
              final record = WalkRecordEntity.fromJson(operation.data);
              final result = await _apiService.startWalk(record);
              return result.isSuccess;

            case SyncOperationType.update:
              final record = WalkRecordEntity.fromJson(operation.data);
              final result = await _apiService.updateWalkRecord(record);
              return result.isSuccess;

            case SyncOperationType.delete:
              final result = await _apiService.deleteWalkRecord(operation.id);
              return result.isSuccess;
          }
        } catch (e) {
          debugPrint('❌ 동기화 처리 실패: ${operation.id} - $e');
          return false;
        }
      },
    );
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

    // 2차: Mock 데이터
    debugPrint('ℹ️ HybridWalkRepository: Mock 통계 데이터 사용');
    final mockData = WalkMockService.getMockWeeklyWalkStats(petId: petId);
    return WalkStatistics.fromJson(mockData);
  }
}
