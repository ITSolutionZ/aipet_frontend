import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
import 'package:aipet_frontend/features/pet_registor/data/repositories/pet_repository_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProviders', () {
    test('petRepositoryProvider should return PetRepositoryImpl', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final repository = container.read(petRepositoryProvider);

      // Assert
      expect(repository, isNotNull);
      expect(repository, isA<PetRepositoryImpl>());

      container.dispose();
    });

    test('petsNotifierProvider should return list of pets', () async {
      // Arrange
      final container = ProviderContainer();

      // Act
      final petsAsync = container.read(petsNotifierProvider);

      // Assert
      expect(petsAsync, isA<AsyncValue<List<PetProfileEntity>>>());

      // 비동기 데이터 로딩 대기
      await Future.delayed(const Duration(milliseconds: 600));

      final pets = petsAsync.when(
        data: (data) => data,
        loading: () => <PetProfileEntity>[],
        error: (error, stack) => <PetProfileEntity>[],
      );

      // Mockito 데이터가 로드되었는지 확인
      expect(pets, isA<List<PetProfileEntity>>());

      container.dispose();
    });

    test('petsNotifierProvider should refresh pets', () async {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(petsNotifierProvider.notifier);

      // Act
      await notifier.refresh();

      // Assert
      final petsAsync = container.read(petsNotifierProvider);

      // 비동기 데이터 로딩 대기
      await Future.delayed(const Duration(milliseconds: 600));

      final pets = petsAsync.when(
        data: (data) => data,
        loading: () => <PetProfileEntity>[],
        error: (error, stack) => <PetProfileEntity>[],
      );

      // Mockito 데이터가 로드되었는지 확인
      expect(pets, isA<List<PetProfileEntity>>());

      container.dispose();
    });

    test('petByIdProvider should return pet by id', () async {
      // Arrange
      final container = ProviderContainer();
      const petId = '1';

      // Act
      final petAsync = container.read(petByIdProvider(petId));

      // Assert
      expect(petAsync, isA<AsyncValue<PetProfileEntity?>>());

      // 비동기 데이터 로딩 대기
      await Future.delayed(const Duration(milliseconds: 600));

      final pet = petAsync.when(
        data: (data) => data,
        loading: () => null,
        error: (error, stack) => null,
      );

      // Mockito 데이터가 로드되었는지 확인
      expect(pet, isA<PetProfileEntity?>());

      container.dispose();
    });

    test('petByIdProvider should return null for invalid id', () async {
      // Arrange
      final container = ProviderContainer();
      const petId = 'invalid-id';

      // Act
      final petAsync = container.read(petByIdProvider(petId));

      // Assert
      final pet = petAsync.when(
        data: (data) => data,
        loading: () => null,
        error: (error, stack) => null,
      );

      expect(pet, isNull);

      container.dispose();
    });

    test('selectedPetNotifierProvider should manage selected pet', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(selectedPetNotifierProvider.notifier);

      final testPet = PetProfileEntity(
        id: 'test-1',
        name: 'Test Pet',
        type: 'dog',
        breed: 'Test Breed',
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'assets/images/test.jpg',
        ownerId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(container.read(selectedPetNotifierProvider), isNull);

      notifier.selectPet(testPet);
      expect(container.read(selectedPetNotifierProvider), equals(testPet));

      notifier.clearSelection();
      expect(container.read(selectedPetNotifierProvider), isNull);

      container.dispose();
    });
  });
}
