import 'package:aipet_frontend/shared/services/sync_queue_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SyncQueueService syncQueueService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    syncQueueService = SyncQueueService.instance;
  });

  tearDown(() async {
    await syncQueueService.clearQueue();
  });

  group('SyncQueueService - 기본 기능', () {
    test('큐에 작업 추가', () async {
      // Arrange
      final operation = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.create,
        entityType: 'walk',
        data: {'id': 'walk-1', 'petId': 'pet-1'},
        timestamp: DateTime.now(),
      );

      // Act
      await syncQueueService.addToQueue(operation);
      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending.length, 1);
      expect(pending.first.id, 'walk-1');
      expect(pending.first.type, SyncOperationType.create);
    });

    test('중복 작업은 최신 것으로 교체', () async {
      // Arrange
      final operation1 = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.update,
        entityType: 'walk',
        data: {'distance': 3.0},
        timestamp: DateTime.now(),
      );

      final operation2 = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.update,
        entityType: 'walk',
        data: {'distance': 5.0},
        timestamp: DateTime.now(),
      );

      // Act
      await syncQueueService.addToQueue(operation1);
      await syncQueueService.addToQueue(operation2);
      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending.length, 1); // 중복 제거
      expect(pending.first.data['distance'], 5.0); // 최신 데이터
    });

    test('빈 큐 조회', () async {
      // Act
      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending, isEmpty);
    });
  });

  group('SyncQueueService - 처리', () {
    test('성공한 작업은 큐에서 제거', () async {
      // Arrange
      final operation = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.create,
        entityType: 'walk',
        data: {'id': 'walk-1'},
        timestamp: DateTime.now(),
      );

      await syncQueueService.addToQueue(operation);

      // Act
      await syncQueueService.processPendingOperations(
        handler: (op) async => true, // 항상 성공
      );

      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending, isEmpty);
    });

    test('실패한 작업은 재시도 횟수 증가', () async {
      // Arrange
      final operation = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.create,
        entityType: 'walk',
        data: {'id': 'walk-1'},
        timestamp: DateTime.now(),
      );

      await syncQueueService.addToQueue(operation);

      // Act
      await syncQueueService.processPendingOperations(
        handler: (op) async => false, // 항상 실패
      );

      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending.length, 1);
      expect(pending.first.retryCount, 1); // 재시도 횟수 증가
    });

    test('최대 재시도 횟수 초과 시 큐에서 제거', () async {
      // Arrange
      final operation = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.create,
        entityType: 'walk',
        data: {'id': 'walk-1'},
        timestamp: DateTime.now(),
        retryCount: 3, // 이미 최대 재시도
      );

      await syncQueueService.addToQueue(operation);

      // Act
      await syncQueueService.processPendingOperations(
        handler: (op) async => false, // 실패
      );

      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending, isEmpty); // 최대 재시도 초과로 제거
    });
  });

  group('SyncQueueService - 관리', () {
    test('특정 작업 제거', () async {
      // Arrange
      final operation1 = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.create,
        entityType: 'walk',
        data: {'id': 'walk-1'},
        timestamp: DateTime.now(),
      );

      final operation2 = SyncOperation(
        id: 'walk-2',
        type: SyncOperationType.update,
        entityType: 'walk',
        data: {'id': 'walk-2'},
        timestamp: DateTime.now(),
      );

      await syncQueueService.addToQueue(operation1);
      await syncQueueService.addToQueue(operation2);

      // Act
      await syncQueueService.removeOperation(
        'walk-1',
        SyncOperationType.create,
      );
      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending.length, 1);
      expect(pending.first.id, 'walk-2');
    });

    test('큐 초기화', () async {
      // Arrange
      final operation = SyncOperation(
        id: 'walk-1',
        type: SyncOperationType.create,
        entityType: 'walk',
        data: {'id': 'walk-1'},
        timestamp: DateTime.now(),
      );

      await syncQueueService.addToQueue(operation);

      // Act
      await syncQueueService.clearQueue();
      final pending = await syncQueueService.getPendingOperations();

      // Assert
      expect(pending, isEmpty);
    });

    test('큐 통계 조회', () async {
      // Arrange
      await syncQueueService.addToQueue(
        SyncOperation(
          id: 'walk-1',
          type: SyncOperationType.create,
          entityType: 'walk',
          data: {},
          timestamp: DateTime.now(),
        ),
      );

      await syncQueueService.addToQueue(
        SyncOperation(
          id: 'walk-2',
          type: SyncOperationType.update,
          entityType: 'walk',
          data: {},
          timestamp: DateTime.now(),
        ),
      );

      await syncQueueService.addToQueue(
        SyncOperation(
          id: 'pet-1',
          type: SyncOperationType.create,
          entityType: 'pet',
          data: {},
          timestamp: DateTime.now(),
        ),
      );

      // Act
      final stats = await syncQueueService.getQueueStats();

      // Assert
      expect(stats['total'], 3);
      expect(stats['byType']['create'], 2);
      expect(stats['byType']['update'], 1);
      expect(stats['byEntityType']['walk'], 2);
      expect(stats['byEntityType']['pet'], 1);
    });
  });
}
