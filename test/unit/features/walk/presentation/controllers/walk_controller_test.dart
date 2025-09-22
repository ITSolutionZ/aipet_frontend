import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WalkController controller;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    controller = WalkController(container);
  });

  tearDown(() {
    container.dispose();
  });

  group('WalkController', () {
    final mockWalkRecord = WalkRecordEntity(
      id: 'walk-123',
      title: 'Morning Walk',
      petId: 'pet-123',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(minutes: 30)),
      route: [],
      distance: 2.5,
      duration: const Duration(minutes: 30),
      status: WalkStatus.completed,
    );

    group('startNewWalk', () {
      test('should return success when new walk is started successfully', () async {
        // Act
        final result = await controller.startNewWalk(
          title: 'Test Walk',
          petId: 'pet-123',
          petName: 'Buddy',
        );

        // Assert
        expect(result, isA<Result<WalkRecordEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.data?.title, equals('Test Walk'));
        expect(result.data?.petId, equals('pet-123'));
        expect(result.data?.status, equals(WalkStatus.inProgress));
      });

      test('should set current walk in provider when started', () async {
        // Act
        await controller.startNewWalk(
          title: 'Test Walk',
          petId: 'pet-123',
        );

        // Assert
        final currentWalk = controller.getCurrentWalk();
        expect(currentWalk, isNotNull);
        expect(currentWalk?.title, equals('Test Walk'));
        expect(currentWalk?.status, equals(WalkStatus.inProgress));
      });
    });

    group('endCurrentWalk', () {
      test('should return failure when no current walk exists', () async {
        // Act
        final result = await controller.endCurrentWalk();

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('진행중의 散歩がありません'));
      });

      test('should end current walk successfully when walk exists', () async {
        // Arrange - Start a walk first
        await controller.startNewWalk(
          title: 'Test Walk',
          petId: 'pet-123',
        );

        // Act
        final result = await controller.endCurrentWalk(
          distance: 2.5,
          notes: 'Great walk!',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('散歩が終了しました'));

        // Check that current walk is cleared
        final currentWalk = controller.getCurrentWalk();
        expect(currentWalk, isNull);
      });
    });

    group('pauseCurrentWalk', () {
      test('should pause current walk successfully', () {
        // Arrange - Start a walk first
        controller.startNewWalk(
          title: 'Test Walk',
          petId: 'pet-123',
        );

        // Act
        final result = controller.pauseCurrentWalk();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('散歩が一時停止されました'));
      });
    });

    group('resumeCurrentWalk', () {
      test('should resume current walk successfully', () {
        // Arrange - Start and pause a walk first
        controller.startNewWalk(
          title: 'Test Walk',
          petId: 'pet-123',
        );
        controller.pauseCurrentWalk();

        // Act
        final result = controller.resumeCurrentWalk();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('散歩が再開されました'));
      });
    });

    group('deleteWalkRecord', () {
      test('should delete walk record successfully', () async {
        // Act
        final result = await controller.deleteWalkRecord('walk-123');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('散歩記録が削除されました'));
      });
    });

    group('getWalkRecordsByPet', () {
      test('should get walk records by pet successfully', () async {
        // Act
        final result = await controller.getWalkRecordsByPet('pet-123');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('ペットの散歩記録を取得しました'));
      });
    });

    group('toggleMapExpanded', () {
      test('should toggle map expanded state successfully', () {
        // Act
        final result = controller.toggleMapExpanded();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('地図の拡大状態が変更されました'));
      });
    });

    group('calculateDistance', () {
      test('should return 0 for empty route', () {
        // Act
        final distance = controller.calculateDistance([]);

        // Assert
        expect(distance, equals(0.0));
      });

      test('should return 0 for single location route', () {
        // Arrange
        final route = [
          WalkLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
          ),
        ];

        // Act
        final distance = controller.calculateDistance(route);

        // Assert
        expect(distance, equals(0.0));
      });

      test('should calculate distance for multiple locations', () {
        // Arrange
        final route = [
          WalkLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
          ),
          WalkLocation(
            latitude: 37.7849,
            longitude: -122.4294,
            timestamp: DateTime.now(),
          ),
        ];

        // Act
        final distance = controller.calculateDistance(route);

        // Assert
        expect(distance, greaterThan(0.0));
      });
    });

    group('getRecentWalkRecords', () {
      test('should get recent walk records with default limit', () {
        // Act
        final records = controller.getRecentWalkRecords();

        // Assert
        expect(records, isA<List<WalkRecordEntity>>());
      });

      test('should get recent walk records with custom limit', () {
        // Act
        final records = controller.getRecentWalkRecords(limit: 5);

        // Assert
        expect(records, isA<List<WalkRecordEntity>>());
      });
    });

    group('loadWalkRecords', () {
      test('should load walk records successfully', () async {
        // Act
        final result = await controller.loadWalkRecords();

        // Assert
        expect(result, isA<Result<List<WalkRecordEntity>>>());
        expect(result.isSuccess, isTrue);
      });
    });
  });
}