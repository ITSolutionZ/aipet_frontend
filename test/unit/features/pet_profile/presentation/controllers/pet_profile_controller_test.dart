import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_controller.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('should create state with provided pet', () {
      // Arrange
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final state = PetProfileState(selectedPet: pet);

      // Assert
      expect(state.selectedPet, equals(pet));
      expect(state.selectedPetName, equals('テストペット'));
    });

    test('copyWith should update selected pet', () {
      // Arrange
      final pet1 = PetProfileEntity(
        id: 'pet-1',
        name: 'ペット1',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 1, 1),
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
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'image2.jpg',
        ownerId: 'owner-2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = PetProfileState(selectedPet: pet1);

      // Act
      final updatedState = state.copyWith(selectedPet: pet2);

      // Assert
      expect(updatedState.selectedPet, equals(pet2));
      expect(updatedState.selectedPetName, equals('ペット2'));
    });

    test('copyWith should keep existing values when null provided', () {
      // Arrange
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = PetProfileState(selectedPet: pet);

      // Act
      final updatedState = state.copyWith();

      // Assert
      expect(updatedState.selectedPet, equals(pet));
    });

    test('selectedPetName should return pet name when pet is selected', () {
      // Arrange
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = PetProfileState(selectedPet: pet);

      // Act
      final petName = state.selectedPetName;

      // Assert
      expect(petName, equals('テストペット'));
    });

    test('selectedPetName should return Unknown Pet when no pet selected', () {
      // Arrange
      const state = PetProfileState();

      // Act
      final petName = state.selectedPetName;

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

    testWidgets('should select pet', (tester) async {
      // Arrange
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      late PetProfileNotifier notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  notifier = ref.read(petProfileNotifierProvider.notifier);
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('Pet: ${state.selectedPet?.name ?? 'None'}');
                },
              ),
            ),
          ),
        ),
      );

      // Act - select pet after initial build
      notifier.selectPet(pet);
      await tester.pump();

      // Assert
      expect(find.text('Pet: テストペット'), findsOneWidget);
    });

    testWidgets('should handle tab change when no tab controller gracefully', (
      tester,
    ) async {
      // Arrange
      late PetProfileNotifier notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  notifier = ref.read(petProfileNotifierProvider.notifier);
                  final state = ref.watch(petProfileNotifierProvider);
                  return Text('TabController: ${state.tabController != null}');
                },
              ),
            ),
          ),
        ),
      );

      // Act - This should not throw an exception even when tabController is null
      notifier.changeTab(1);
      await tester.pump();

      // Assert
      expect(find.text('TabController: false'), findsOneWidget);
    });
  });
}