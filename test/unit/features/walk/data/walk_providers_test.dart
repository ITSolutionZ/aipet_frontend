import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aipet_frontend/features/walk/data/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';

void main() {
  group('Walk Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('WalkRecordsNotifier Tests', () {
      test('should initialize with empty list', () {
        final state = container.read(walkRecordsNotifierProvider);

        expect(state, isEmpty);
      });

      test('should set walk records correctly', () {
        final notifier = container.read(walkRecordsNotifierProvider.notifier);
        final mockRecords = [
          _createMockWalkRecord('1', 'Morning Walk'),
          _createMockWalkRecord('2', 'Evening Walk'),
        ];

        notifier.setWalkRecords(mockRecords);
        final state = container.read(walkRecordsNotifierProvider);

        expect(state, hasLength(2));
        expect(state[0].id, equals('1'));
        expect(state[1].id, equals('2'));
      });

      test('should add walk record to beginning of list', () {
        final notifier = container.read(walkRecordsNotifierProvider.notifier);
        final existingRecord = _createMockWalkRecord('1', 'Existing Walk');
        final newRecord = _createMockWalkRecord('2', 'New Walk');

        notifier.setWalkRecords([existingRecord]);
        notifier.addWalkRecord(newRecord);

        final state = container.read(walkRecordsNotifierProvider);

        expect(state, hasLength(2));
        expect(state[0].id, equals('2')); // New record should be first
        expect(state[1].id, equals('1'));
      });

      test('should update walk record correctly', () {
        final notifier = container.read(walkRecordsNotifierProvider.notifier);
        final originalRecord = _createMockWalkRecord('1', 'Original Title');
        final updatedRecord = originalRecord.copyWith(title: 'Updated Title');

        notifier.setWalkRecords([originalRecord]);
        notifier.updateWalkRecord(updatedRecord);

        final state = container.read(walkRecordsNotifierProvider);

        expect(state, hasLength(1));
        expect(state[0].title, equals('Updated Title'));
      });

      test('should remove walk record correctly', () {
        final notifier = container.read(walkRecordsNotifierProvider.notifier);
        final records = [
          _createMockWalkRecord('1', 'Walk 1'),
          _createMockWalkRecord('2', 'Walk 2'),
          _createMockWalkRecord('3', 'Walk 3'),
        ];

        notifier.setWalkRecords(records);
        notifier.removeWalkRecord('2');

        final state = container.read(walkRecordsNotifierProvider);

        expect(state, hasLength(2));
        expect(state.any((record) => record.id == '2'), isFalse);
        expect(state.any((record) => record.id == '1'), isTrue);
        expect(state.any((record) => record.id == '3'), isTrue);
      });

      test('should get walk records by pet correctly', () {
        final notifier = container.read(walkRecordsNotifierProvider.notifier);
        final records = [
          _createMockWalkRecord('1', 'Walk 1', petId: 'pet1'),
          _createMockWalkRecord('2', 'Walk 2', petId: 'pet2'),
          _createMockWalkRecord('3', 'Walk 3', petId: 'pet1'),
        ];

        notifier.setWalkRecords(records);
        final pet1Records = notifier.getWalkRecordsByPet('pet1');

        expect(pet1Records, hasLength(2));
        expect(pet1Records[0].petId, equals('pet1'));
        expect(pet1Records[1].petId, equals('pet1'));
      });

      test('should get recent walk records with limit', () {
        final notifier = container.read(walkRecordsNotifierProvider.notifier);
        final records = List.generate(15, (index) =>
          _createMockWalkRecord('$index', 'Walk $index'));

        notifier.setWalkRecords(records);
        final recentRecords = notifier.getRecentWalkRecords(limit: 5);

        expect(recentRecords, hasLength(5));
      });
    });

    group('CurrentWalkNotifier Tests', () {
      test('should initialize with null', () {
        final state = container.read(currentWalkNotifierProvider);
        expect(state, isNull);
      });

      test('should start walk correctly', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Current Walk',
          status: WalkStatus.inProgress);

        notifier.startWalk(walkRecord);
        final state = container.read(currentWalkNotifierProvider);

        expect(state, isNotNull);
        expect(state!.id, equals('1'));
        expect(state.status, equals(WalkStatus.inProgress));
      });

      test('should update current walk correctly', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);
        final originalWalk = _createMockWalkRecord('1', 'Original Walk');
        final updatedWalk = originalWalk.copyWith(title: 'Updated Walk');

        notifier.startWalk(originalWalk);
        notifier.updateCurrentWalk(updatedWalk);

        final state = container.read(currentWalkNotifierProvider);

        expect(state!.title, equals('Updated Walk'));
      });

      test('should end walk correctly', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Ending Walk');

        notifier.startWalk(walkRecord);
        notifier.endWalk();

        final state = container.read(currentWalkNotifierProvider);
        expect(state, isNull);
      });

      test('should pause walk correctly', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Pausing Walk',
          status: WalkStatus.inProgress);

        notifier.startWalk(walkRecord);
        notifier.pauseWalk();

        final state = container.read(currentWalkNotifierProvider);
        expect(state!.status, equals(WalkStatus.paused));
      });

      test('should resume walk correctly', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Resuming Walk',
          status: WalkStatus.paused);

        notifier.startWalk(walkRecord);
        notifier.resumeWalk();

        final state = container.read(currentWalkNotifierProvider);
        expect(state!.status, equals(WalkStatus.inProgress));
      });

      test('should add location to current walk', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Location Walk', route: []);
        final location = WalkLocation(
          latitude: 35.6762,
          longitude: 139.6503,
          timestamp: DateTime.now(),
        );

        notifier.startWalk(walkRecord);
        notifier.addLocationToCurrentWalk(location);

        final state = container.read(currentWalkNotifierProvider);
        expect(state!.route, hasLength(1));
        expect(state.route[0].latitude, equals(35.6762));
      });

      test('should not pause when no current walk', () {
        final notifier = container.read(currentWalkNotifierProvider.notifier);

        // Should not throw error when no current walk
        expect(() => notifier.pauseWalk(), returnsNormally);

        final state = container.read(currentWalkNotifierProvider);
        expect(state, isNull);
      });
    });

    group('SelectedPetNotifier Tests', () {
      test('should initialize with null', () {
        final state = container.read(selectedPetNotifierProvider);
        expect(state, isNull);
      });

      test('should set selected pet correctly', () {
        final notifier = container.read(selectedPetNotifierProvider.notifier);
        const pet = PetInfo(id: 'pet1', name: 'Buddy', imagePath: 'path/to/buddy.jpg');

        notifier.setSelectedPet(pet);
        final state = container.read(selectedPetNotifierProvider);

        expect(state, isNotNull);
        expect(state!.id, equals('pet1'));
        expect(state.name, equals('Buddy'));
      });

      test('should clear selected pet', () {
        final notifier = container.read(selectedPetNotifierProvider.notifier);
        const pet = PetInfo(id: 'pet1', name: 'Buddy', imagePath: 'path/to/buddy.jpg');

        notifier.setSelectedPet(pet);
        notifier.setSelectedPet(null);

        final state = container.read(selectedPetNotifierProvider);
        expect(state, isNull);
      });
    });

    group('MapExpandedNotifier Tests', () {
      test('should initialize with false', () {
        final state = container.read(mapExpandedNotifierProvider);
        expect(state, isFalse);
      });

      test('should toggle expanded state', () {
        final notifier = container.read(mapExpandedNotifierProvider.notifier);

        notifier.toggleExpanded();
        final state1 = container.read(mapExpandedNotifierProvider);
        expect(state1, isTrue);

        notifier.toggleExpanded();
        final state2 = container.read(mapExpandedNotifierProvider);
        expect(state2, isFalse);
      });

      test('should set expanded state directly', () {
        final notifier = container.read(mapExpandedNotifierProvider.notifier);

        notifier.setExpanded(true);
        final state1 = container.read(mapExpandedNotifierProvider);
        expect(state1, isTrue);

        notifier.setExpanded(false);
        final state2 = container.read(mapExpandedNotifierProvider);
        expect(state2, isFalse);
      });
    });

    group('WalkStatsNotifier Tests', () {
      test('should initialize with default stats', () {
        final state = container.read(walkStatsNotifierProvider);
        expect(state.distance, equals(0.0));
        expect(state.duration, equals(Duration.zero));
        expect(state.speed, equals(0.0));
        expect(state.steps, equals(0));
      });

      test('should calculate stats correctly for walk with route', () {
        final notifier = container.read(walkStatsNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Stats Walk', route: [
          WalkLocation(latitude: 35.6762, longitude: 139.6503, timestamp: DateTime.now()),
          WalkLocation(latitude: 35.6763, longitude: 139.6504, timestamp: DateTime.now()),
        ]);

        notifier.updateStats(walkRecord);
        final state = container.read(walkStatsNotifierProvider);

        expect(state.distance, greaterThan(0.0));
        expect(state.steps, equals(2));
      });

      test('should not calculate stats for walk with insufficient route points', () {
        final notifier = container.read(walkStatsNotifierProvider.notifier);
        final walkRecord = _createMockWalkRecord('1', 'Single Point Walk', route: [
          WalkLocation(latitude: 35.6762, longitude: 139.6503, timestamp: DateTime.now()),
        ]);

        notifier.updateStats(walkRecord);
        final state = container.read(walkStatsNotifierProvider);

        // Should remain at initial state
        expect(state.distance, equals(0.0));
        expect(state.steps, equals(0));
      });
    });
  });
}

// Helper function to create mock walk records
WalkRecordEntity _createMockWalkRecord(
  String id,
  String title, {
  String? petId,
  WalkStatus status = WalkStatus.completed,
  List<WalkLocation>? route,
}) {
  return WalkRecordEntity(
    id: id,
    title: title,
    startTime: DateTime.now().subtract(const Duration(hours: 1)),
    endTime: DateTime.now(),
    distance: 2.5,
    duration: const Duration(minutes: 30),
    route: route ?? [
      WalkLocation(latitude: 35.6762, longitude: 139.6503, timestamp: DateTime.now()),
      WalkLocation(latitude: 35.6763, longitude: 139.6504, timestamp: DateTime.now()),
    ],
    petId: petId ?? 'default_pet',
    petName: 'Test Pet',
    petImage: 'assets/images/test_pet.jpg',
    ownerId: 'owner1',
    ownerName: 'Test Owner',
    ownerAvatar: 'assets/images/test_avatar.jpg',
    status: status,
    createdAt: DateTime.now(),
  );
}