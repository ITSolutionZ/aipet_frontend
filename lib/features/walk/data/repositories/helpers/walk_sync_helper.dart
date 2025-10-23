import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/services/sync_queue_service.dart';
import 'package:flutter/foundation.dart';

/// Walk 동기화 헬퍼
class WalkSyncHelper {
  /// 동기화 큐에 작업 추가
  static Future<void> addToSyncQueue(SyncOperation operation) async {
    try {
      final syncQueue = SyncQueueService.instance;
      await syncQueue.addToQueue(operation);
      LoggerService.debug('📥 동기화 큐에 추가: ${operation.type.name} - ${operation.id}');
    } catch (e) {
      LoggerService.debug('❌ 동기화 큐 추가 실패: $e');
    }
  }

  /// 동기화 작업 생성 (Create)
  static SyncOperation createSyncOperation(WalkRecordEntity walkRecord) {
    return SyncOperation(
      id: walkRecord.id,
      type: SyncOperationType.create,
      entityType: 'walk',
      data: walkRecord.toJson(),
      timestamp: DateTime.now(),
    );
  }

  /// 동기화 작업 생성 (Update)
  static SyncOperation updateSyncOperation(WalkRecordEntity walkRecord) {
    return SyncOperation(
      id: walkRecord.id,
      type: SyncOperationType.update,
      entityType: 'walk',
      data: walkRecord.toJson(),
      timestamp: DateTime.now(),
    );
  }

  /// 동기화 작업 생성 (Delete)
  static SyncOperation deleteSyncOperation(String id) {
    return SyncOperation(
      id: id,
      type: SyncOperationType.delete,
      entityType: 'walk',
      data: {'id': id},
      timestamp: DateTime.now(),
    );
  }

  /// 대기 중인 동기화 작업 처리
  static Future<void> processPendingSync({
    required WalkApiService apiService,
  }) async {
    final syncQueue = SyncQueueService.instance;

    await syncQueue.processPendingOperations(
      handler: (operation) async {
        try {
          if (operation.entityType != 'walk') {
            return true; // 다른 엔티티 타입은 건너뜀
          }

          switch (operation.type) {
            case SyncOperationType.create:
              final record = WalkRecordEntity.fromJson(operation.data);
              final result = await apiService.startWalk(record);
              return result.isSuccess;

            case SyncOperationType.update:
              final record = WalkRecordEntity.fromJson(operation.data);
              final result = await apiService.updateWalkRecord(record);
              return result.isSuccess;

            case SyncOperationType.delete:
              final result = await apiService.deleteWalkRecord(operation.id);
              return result.isSuccess;
          }
        } catch (e) {
          LoggerService.debug('❌ 동기화 처리 실패: ${operation.id} - $e');
          return false;
        }
      },
    );
  }
}
