import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../lib/features/pet_profile/presentation/controllers/pet_profile_controller.dart';
import '../../../../../lib/features/pet_registor/domain/entities/pet_profile_entity.dart';

void main() {
  group('PetProfileState', () {
    test('should create state with default values', () {
      // Act
      const state = PetProfileState();

      // Assert
      expect(state.tabController, isNull);
      expect(state.selectedPet, isNull);
      expect(state.selectedPetName, equals('Unknown Pet'));
    });

    test('should create state with provided values', () {
      // Arrange
      final tabController = TabController(length: 4, vsync: const TestVSync());
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final state = PetProfileState(
        tabController: tabController,
        selectedPet: pet,
      );

      // Assert
      expect(state.tabController, equals(tabController));
      expect(state.selectedPet, equals(pet));
      expect(state.selectedPetName, equals('テストペット'));
    });

    test('copyWith should update only provided fields', () {
      // Arrange
      final tabController1 = TabController(length: 4, vsync: const TestVSync());
      final tabController2 = TabController(length: 4, vsync: const TestVSync());
      final pet1 = PetProfileEntity(
        id: 'pet-1',
        name: 'ペット1',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'image1.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final pet2 = PetProfileEntity(
        id: 'pet-2',
        name: 'ペット2',
        type: 'cat',
        breed: 'アメリカンショートヘア',
        age: 2,
        gender: 'female',
        weight: 4.2,
        imagePath: 'image2.jpg',
        ownerId: 'owner-2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = PetProfileState(
        tabController: tabController1,
        selectedPet: pet1,
      );

      // Act
      final updatedState = state.copyWith(
        tabController: tabController2,
        selectedPet: pet2,
      );

      // Assert
      expect(updatedState.tabController, equals(tabController2));
      expect(updatedState.selectedPet, equals(pet2));
      expect(updatedState.selectedPetName, equals('ペット2'));
    });

    test('copyWith should keep existing values when null provided', () {
      // Arrange
      final tabController = TabController(length: 4, vsync: const TestVSync());
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = PetProfileState(
        tabController: tabController,
        selectedPet: pet,
      );

      // Act
      final updatedState = state.copyWith();

      // Assert
      expect(updatedState.tabController, equals(tabController));
      expect(updatedState.selectedPet, equals(pet));
    });

    test('selectedPetName should return pet name when pet is selected', () {
      // Arrange
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const state = PetProfileState(selectedPet: pet);

      // Act
      const petName = state.selectedPetName;

      // Assert
      expect(petName, equals('テストペット'));
    });

    test('selectedPetName should return Unknown Pet when no pet selected', () {
      // Arrange
      const state = PetProfileState();

      // Act
      const petName = state.selectedPetName;

      // Assert
      expect(petName, equals('Unknown Pet'));
    });
  });

  group('PetProfileNotifier', () {
    testWidgets('should initialize with default state', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('TabController: ${state.tabController != null}');
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('TabController: false'), findsOneWidget);
    });

    testWidgets('should initialize tab controller', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final notifier = ref.read(
                    petProfileNotifierProvider.notifier,
                  );
                  notifier.initializeTabController(tester);
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('TabController: ${state.tabController != null}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('TabController: true'), findsOneWidget);
    });

    testWidgets('should select pet', (tester) async {
      // Arrange
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final notifier = ref.read(
                    petProfileNotifierProvider.notifier,
                  );
                  notifier.selectPet(pet);
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('Pet: ${state.selectedPet?.name ?? 'None'}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Pet: テストペット'), findsOneWidget);
    });

    testWidgets('should handle tab change when no tab controller', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final notifier = ref.read(
                    petProfileNotifierProvider.notifier,
                  );
                  notifier.changeTab(1); // TabController가 없어도 예외가 발생하지 않아야 함
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('TabController: ${state.tabController != null}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('TabController: false'), findsOneWidget);
    });

    testWidgets('should dispose tab controller', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final notifier = ref.read(
                    petProfileNotifierProvider.notifier,
                  );
                  notifier.initializeTabController(tester);
                  notifier.disposeTabController();
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('TabController: ${state.tabController != null}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('TabController: true'), findsOneWidget);
    });

    testWidgets('should update pet and maintain tab controller', (
      tester,
    ) async {
      // Arrange
      final pet1 = PetProfileEntity(
        id: 'pet-1',
        name: 'ペット1',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'image1.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final pet2 = PetProfileEntity(
        id: 'pet-2',
        name: 'ペット2',
        type: 'cat',
        breed: 'アメリカンショートヘア',
        age: 2,
        gender: 'female',
        weight: 4.2,
        imagePath: 'image2.jpg',
        ownerId: 'owner-2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final notifier = ref.read(
                    petProfileNotifierProvider.notifier,
                  );
                  notifier.initializeTabController(tester);
                  notifier.selectPet(pet1);
                  notifier.selectPet(pet2);
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('Pet: ${state.selectedPet?.name ?? 'None'}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Pet: ペット2'), findsOneWidget);
    });
  });
}
