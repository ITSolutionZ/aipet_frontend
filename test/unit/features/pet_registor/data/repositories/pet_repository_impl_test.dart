import 'package:aipet_frontend/features/pet_registor/data/repositories/pet_repository_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/temporary_pet_data_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetRepositoryImpl', () {
    late PetRepositoryImpl repository;

    setUp(() {
      repository = PetRepositoryImpl();
    });

    group('getAllPets', () {
      test('should return list of pets from mock data', () async {
        // Arrange
        final mockPet = PetProfileEntity(
          id: 'test-id',
          name: 'Test Pet',
          type: 'dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
        PetMockData.addPet(mockPet);

        // Act
        final result = await repository.getAllPets();

        // Assert
        expect(result, isA<Result<List<PetProfileEntity>>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.isNotEmpty, isTrue);
        expect(result.data!.any((pet) => pet.id == 'test-id'), isTrue);
      });

      test('should return list from mock data', () async {
        // Act
        final result = await repository.getAllPets();

        // Assert
        expect(result, isA<Result<List<PetProfileEntity>>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        // Mock data has default pets, so list should not be empty
        expect(result.data!.isNotEmpty, isTrue);
      });

      test('should simulate delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await repository.getAllPets();

        // Assert
        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          greaterThanOrEqualTo(400),
        ); // Allow some margin
      });
    });

    group('getPetById', () {
      test('should return pet when pet exists', () async {
        // Arrange
        final mockPet = PetProfileEntity(
          id: 'existing-id',
          name: 'Existing Pet',
          type: 'cat',
          breed: 'Persian',
          birthDate: DateTime(2021, 1, 1),
          gender: 'female',
          weight: 4.5,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
        PetMockData.addPet(mockPet);

        // Act
        final result = await repository.getPetById('existing-id');

        // Assert
        expect(result, isA<Result<PetProfileEntity?>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.id, equals('existing-id'));
        expect(result.data!.name, equals('Existing Pet'));
        expect(result.data!.type, equals('cat'));
      });

      test('should return null when pet does not exist', () async {
        // Act
        final result = await repository.getPetById('non-existent-id');

        // Assert
        expect(result, isA<Result<PetProfileEntity?>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should return null when pets list is empty', () async {
        // Act
        final result = await repository.getPetById('any-id');

        // Assert
        expect(result, isA<Result<PetProfileEntity?>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });
    });

    group('createPet', () {
      test('should create and return pet with updated timestamps', () async {
        // Arrange
        final petToCreate = PetProfileEntity(
          id: 'new-id',
          name: 'New Pet',
          type: 'dog',
          breed: 'Labrador',
          birthDate: DateTime(2022, 1, 1),
          gender: 'male',
          weight: 30.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2022, 1, 1), // Old timestamp
          updatedAt: DateTime(2022, 1, 1), // Old timestamp
        );

        final beforeCreation = DateTime.now();

        // Act
        final result = await repository.createPet(petToCreate);

        // Assert
        expect(result, isA<Result<PetProfileEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.id, equals('new-id'));
        expect(result.data!.name, equals('New Pet'));
        expect(result.data!.type, equals('dog'));
        expect(result.data!.breed, equals('Labrador'));
        expect(result.data!.birthDate, equals(DateTime(2022, 1, 1)));
        expect(result.data!.ownerId, equals('owner-123'));

        // Check that timestamps were updated
        expect(result.data!.createdAt.isAfter(beforeCreation), isTrue);
        expect(result.data!.updatedAt.isAfter(beforeCreation), isTrue);
      });

      test('should add pet to mock data', () async {
        // Arrange
        final petToCreate = PetProfileEntity(
          id: 'added-pet',
          name: 'Added Pet',
          type: 'bird',
          birthDate: DateTime(2022, 1, 1),
          gender: 'female',
          weight: 0.5,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Act
        await repository.createPet(petToCreate);

        // Assert
        final allPetsResult = await repository.getAllPets();
        expect(allPetsResult.isSuccess, isTrue);
        expect(allPetsResult.data, isNotNull);
        expect(allPetsResult.data!.any((pet) => pet.id == 'added-pet'), isTrue);
      });

      test('should simulate delay', () async {
        // Arrange
        final petToCreate = PetProfileEntity(
          id: 'delay-test',
          name: 'Delay Test Pet',
          type: 'hamster',
          birthDate: DateTime(2022, 1, 1),
          gender: 'male',
          weight: 0.1,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
        final stopwatch = Stopwatch()..start();

        // Act
        await repository.createPet(petToCreate);

        // Assert
        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          greaterThanOrEqualTo(250),
        ); // Allow some margin
      });
    });

    group('updatePet', () {
      test('should update existing pet with new timestamp', () async {
        // Arrange
        final originalPet = PetProfileEntity(
          id: 'update-id',
          name: 'Original Name',
          type: 'dog',
          breed: 'Original Breed',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
        PetMockData.addPet(originalPet);

        final updatedPet = originalPet.copyWith(
          name: 'Updated Name',
          breed: 'Updated Breed',
        );

        final beforeUpdate = DateTime.now();

        // Act
        final result = await repository.updatePet(updatedPet);

        // Assert
        expect(result, isA<Result<PetProfileEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.id, equals('update-id'));
        expect(result.data!.name, equals('Updated Name'));
        expect(result.data!.breed, equals('Updated Breed'));
        expect(result.data!.updatedAt.isAfter(beforeUpdate), isTrue);
        expect(
          result.data!.createdAt,
          equals(DateTime(2023, 1, 1)),
        ); // Should remain same
      });

      test('should throw exception when pet does not exist', () async {
        // Arrange
        final nonExistentPet = PetProfileEntity(
          id: 'non-existent',
          name: 'Non Existent',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Act & Assert
        final result = await repository.updatePet(nonExistentPet);
        expect(result, isA<Result<PetProfileEntity>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('펫을 찾을 수 없습니다'));
      });
    });

    group('deletePet', () {
      test('should delete existing pet successfully', () async {
        // Arrange
        final petToDelete = PetProfileEntity(
          id: 'delete-me',
          name: 'Pet To Delete',
          type: 'cat',
          birthDate: DateTime(2020, 1, 1),
          gender: 'female',
          weight: 4.5,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );
        PetMockData.addPet(petToDelete);

        // Verify pet exists before deletion
        final beforeDeletion = await repository.getPetById('delete-me');
        expect(beforeDeletion.isSuccess, isTrue);
        expect(beforeDeletion.data, isNotNull);

        // Act
        final deleteResult = await repository.deletePet('delete-me');
        expect(deleteResult.isSuccess, isTrue);

        // Assert
        final afterDeletion = await repository.getPetById('delete-me');
        expect(afterDeletion.isSuccess, isTrue);
        expect(afterDeletion.data, isNull);
      });

      test('should throw exception when pet does not exist', () async {
        // Act & Assert
        final result = await repository.deletePet('non-existent-id');
        expect(result, isA<Result<void>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('펫을 찾을 수 없습니다'));
      });
    });

    group('temporary pet data operations', () {
      test('saveTemporaryPetData should complete without error', () async {
        // Arrange
        const tempData = TemporaryPetDataEntity(
          type: 'dog',
          breed: 'Golden Retriever',
          name: 'Temp Pet',
          birthDate: null,
          currentStep: PetRegistrationStep.breedSelection,
        );

        // Act & Assert
        expect(
          () => repository.saveTemporaryPetData(tempData),
          returnsNormally,
        );
        await repository.saveTemporaryPetData(tempData);
      });

      test(
        'getTemporaryPetData should return null (mock implementation)',
        () async {
          // Act
          final result = await repository.getTemporaryPetData();

          // Assert
          expect(result, isNull);
        },
      );

      test('clearTemporaryPetData should complete without error', () async {
        // Act & Assert
        expect(() => repository.clearTemporaryPetData(), returnsNormally);
        await repository.clearTemporaryPetData();
      });

      test('temporary data operations should simulate delays', () async {
        final stopwatch = Stopwatch()..start();

        const tempData = TemporaryPetDataEntity(
          type: 'dog',
          currentStep: PetRegistrationStep.typeSelection,
        );

        // Test all three operations
        await repository.saveTemporaryPetData(tempData);
        await repository.getTemporaryPetData();
        await repository.clearTemporaryPetData();

        stopwatch.stop();
        // Each operation has 100ms delay, so total should be around 300ms
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
      });
    });
  });
}
