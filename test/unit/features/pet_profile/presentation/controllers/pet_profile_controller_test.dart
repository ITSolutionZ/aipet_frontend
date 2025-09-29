import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_controller.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
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

    test('should create state with provided values', () {
      // Arrange
      final tabController = TabController(length: 4, vsync: const TestVSync());
      final pet = PetProfileEntity(
        id: 'test-pet',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2021, 1, 1),
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'test.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final state = PetProfileState(
        tabController: tabController,
        selectedPet: pet,
        isLoading: true,
        errorMessage: 'Test error',
      );

      // Assert
      expect(state.tabController, equals(tabController));
      expect(state.selectedPet, equals(pet));
      expect(state.selectedPetName, equals('テストペット'));
      expect(state.isLoading, isTrue);
      expect(state.errorMessage, equals('Test error'));
    });

    test('should handle null selectedPet correctly', () {
      // Arrange
      final pet1 = PetProfileEntity(
        id: 'pet-1',
        name: 'ペット1',
        type: 'cat',
        breed: 'Persian',
        birthDate: DateTime(2020, 5, 15),
        age: 4,
        gender: 'female',
        weight: 4.2,
        imagePath: 'cat1.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pet2 = PetProfileEntity(
        id: 'pet-2',
        name: 'ペット2',
        type: 'dog',
        breed: 'Labrador',
        birthDate: DateTime(2019, 3, 10),
        age: 5,
        gender: 'male',
        weight: 25.0,
        imagePath: 'dog1.jpg',
        ownerId: 'owner-2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      final state1 = PetProfileState(selectedPet: pet1);
      expect(state1.selectedPetName, equals('ペット1'));

      final state2 = PetProfileState(selectedPet: pet2);
      expect(state2.selectedPetName, equals('ペット2'));

      const state3 = PetProfileState(selectedPet: null);
      expect(state3.selectedPetName, equals('Unknown Pet'));
    });
  });

  group('PetProfileNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      // Act
      final notifier = container.read(petProfileNotifierProvider.notifier);

      // Assert
      expect(notifier.state.tabController, isNull);
      expect(notifier.state.selectedPet, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('should load pet profile successfully', () async {
      // Arrange
      final notifier = container.read(petProfileNotifierProvider.notifier);
      const petId = '1';
      const requesterId = 'user1';

      // Act
      final result = await notifier.loadPetProfile(
        petId: petId,
        requesterId: requesterId,
      );

      // Assert
      if (result.isSuccess) {
        expect(notifier.state.selectedPet, isNotNull);
        expect(notifier.state.selectedPet!.id, equals(petId));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, isNull);
      } else {
        // If it fails, let's see what the error is
        print('Load pet profile failed: ${result.message}');
        expect(result.isSuccess, isTrue); // This will show the actual error
      }
    });

    test('should handle load pet profile error', () async {
      // Arrange
      final notifier = container.read(petProfileNotifierProvider.notifier);
      const petId = 'non-existent';
      const requesterId = 'user1';

      // Act
      final result = await notifier.loadPetProfile(
        petId: petId,
        requesterId: requesterId,
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(notifier.state.selectedPet, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNotNull);
    });

    test('should refresh profile successfully', () async {
      // Arrange
      final notifier = container.read(petProfileNotifierProvider.notifier);
      const petId = '1';
      const requesterId = 'user1';

      // First load a pet
      await notifier.loadPetProfile(petId: petId, requesterId: requesterId);

      // Act
      final result = await notifier.refreshProfile(requesterId);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(notifier.state.selectedPet, isNotNull);
    });

    test('should handle refresh when no pet selected', () async {
      // Arrange
      final notifier = container.read(petProfileNotifierProvider.notifier);

      // Act
      final result = await notifier.refreshProfile('owner-1');

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('No pet selected'));
    });

    test('should initialize tab controller', () {
      // Arrange
      final notifier = container.read(petProfileNotifierProvider.notifier);
      final tabController = TabController(length: 4, vsync: const TestVSync());

      // Act
      notifier.initializeTabController(tabController);

      // Assert
      expect(notifier.state.tabController, equals(tabController));
    });

    test('should clear error message', () {
      // Arrange
      final notifier = container.read(petProfileNotifierProvider.notifier);
      notifier.state = notifier.state.copyWith(errorMessage: 'Test error');

      // Act
      notifier.clearError();

      // Assert
      expect(notifier.state.errorMessage, isNull);
    });
  });
}
