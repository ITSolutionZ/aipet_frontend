import 'package:aipet_frontend/features/pet_registor/data/repositories/pet_repository_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/temporary_pet_data_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PetRepositoryImpl repository;

  setUp(() {
    repository = PetRepositoryImpl();
  });

  group('PetRepositoryImpl', () {
    group('getAllPets', () {
      test('should return list of pets when getAllPets is called', () async {
        // Act
        final result = await repository.getAllPets();

        // Assert
        expect(result, isA<List<PetProfileEntity>>());
        expect(result, isNotEmpty);
        expect(result.length, equals(2));
        expect(result.first, isA<PetProfileEntity>());
      });

      test('should return pets with correct properties', () async {
        // Act
        final result = await repository.getAllPets();

        // Assert
        expect(result.first.id, equals('1'));
        expect(result.first.name, equals('멍멍이'));
        expect(result.first.type, equals('dog'));
        expect(result.first.breed, equals('골든 리트리버'));
        expect(result.first.ownerId, equals('user1'));

        expect(result.last.id, equals('2'));
        expect(result.last.name, equals('냥냥이'));
        expect(result.last.type, equals('cat'));
        expect(result.last.breed, equals('페르시안'));
        expect(result.last.ownerId, equals('user1'));
      });

      test('should have valid dates for pets', () async {
        // Act
        final result = await repository.getAllPets();

        // Assert
        for (final pet in result) {
          expect(pet.birthDate, isA<DateTime>());
          expect(pet.createdAt, isA<DateTime>());
          expect(pet.updatedAt, isA<DateTime>());
          expect(
            pet.createdAt.isBefore(pet.updatedAt) ||
                pet.createdAt.isAtSameMomentAs(pet.updatedAt),
            isTrue,
          );
        }
      });
    });

    group('getPetById', () {
      test(
        'should return pet when getPetById is called with valid id',
        () async {
          // Arrange
          const petId = '1';

          // Act
          final result = await repository.getPetById(petId);

          // Assert
          expect(result, isNotNull);
          expect(result!.id, equals(petId));
          expect(result.name, equals('멍멍이'));
          expect(result.type, equals('dog'));
          expect(result.breed, equals('골든 리트리버'));
        },
      );

      test(
        'should return pet when getPetById is called with second valid id',
        () async {
          // Arrange
          const petId = '2';

          // Act
          final result = await repository.getPetById(petId);

          // Assert
          expect(result, isNotNull);
          expect(result!.id, equals(petId));
          expect(result.name, equals('냥냥이'));
          expect(result.type, equals('cat'));
          expect(result.breed, equals('페르시안'));
        },
      );

      test(
        'should return null when getPetById is called with invalid id',
        () async {
          // Arrange
          const petId = 'invalid-id';

          // Act
          final result = await repository.getPetById(petId);

          // Assert
          expect(result, isNull);
        },
      );

      test(
        'should return null when getPetById is called with empty id',
        () async {
          // Arrange
          const petId = '';

          // Act
          final result = await repository.getPetById(petId);

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('createPet', () {
      test(
        'should create pet when createPet is called with valid data',
        () async {
          // Arrange
          final pet = PetProfileEntity(
            id: '',
            name: 'Test Pet',
            type: 'cat',
            breed: 'Test Breed',
            birthDate: DateTime(2022, 1, 1),
            imagePath: 'assets/images/test.jpg',
            ownerId: 'user1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Act
          final result = await repository.createPet(pet);

          // Assert
          expect(result, isA<PetProfileEntity>());
          expect(result.name, equals('Test Pet'));
          expect(result.type, equals('cat'));
          expect(result.breed, equals('Test Breed'));
          expect(result.id, isNotEmpty);
          expect(result.id, isNot(equals('')));
          expect(result.createdAt, isNotNull);
          expect(result.updatedAt, isNotNull);
        },
      );

      test('should generate unique id for created pet', () async {
        // Arrange
        final pet1 = PetProfileEntity(
          id: '',
          name: 'Pet 1',
          type: 'dog',
          birthDate: DateTime(2021, 1, 1),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final pet2 = PetProfileEntity(
          id: '',
          name: 'Pet 2',
          type: 'cat',
          birthDate: DateTime(2022, 1, 1),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result1 = await repository.createPet(pet1);
        final result2 = await repository.createPet(pet2);

        // Assert
        expect(result1.id, isNotEmpty);
        expect(result2.id, isNotEmpty);
        expect(result1.id, isNot(equals(result2.id)));
      });

      test('should preserve all pet properties except id and dates', () async {
        // Arrange
        final originalPet = PetProfileEntity(
          id: '',
          name: 'Original Pet',
          type: 'bird',
          breed: 'Parrot',
          birthDate: DateTime(2020, 5, 15),
          imagePath: 'assets/images/parrot.jpg',
          ownerId: 'user2',
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime(2020, 1, 1),
          isActive: false,
          additionalInfo: {'color': 'green', 'size': 'medium'},
        );

        // Act
        final result = await repository.createPet(originalPet);

        // Assert
        expect(result.name, equals(originalPet.name));
        expect(result.type, equals(originalPet.type));
        expect(result.breed, equals(originalPet.breed));
        expect(result.birthDate, equals(originalPet.birthDate));
        expect(result.imagePath, equals(originalPet.imagePath));
        expect(result.ownerId, equals(originalPet.ownerId));
        expect(result.isActive, equals(originalPet.isActive));
        expect(result.additionalInfo, equals(originalPet.additionalInfo));
      });
    });

    group('updatePet', () {
      test(
        'should update pet when updatePet is called with valid data',
        () async {
          // Arrange
          final pet = PetProfileEntity(
            id: '1',
            name: 'Updated Pet',
            type: 'dog',
            breed: 'Updated Breed',
            birthDate: DateTime(2020, 1, 1),
            imagePath: 'assets/images/updated.jpg',
            ownerId: 'user1',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now(),
          );

          // Act
          final result = await repository.updatePet(pet);

          // Assert
          expect(result, isA<PetProfileEntity>());
          expect(result.name, equals('Updated Pet'));
          expect(result.type, equals('dog'));
          expect(result.breed, equals('Updated Breed'));
          expect(result.updatedAt, isNotNull);
          expect(result.updatedAt.isAfter(pet.updatedAt), isTrue);
        },
      );

      test('should preserve original id and createdAt', () async {
        // Arrange
        final originalCreatedAt = DateTime.now().subtract(
          const Duration(days: 30),
        );
        final pet = PetProfileEntity(
          id: '1',
          name: 'Updated Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          ownerId: 'user1',
          createdAt: originalCreatedAt,
          updatedAt: DateTime.now(),
        );

        // Act
        final result = await repository.updatePet(pet);

        // Assert
        expect(result.id, equals('1'));
        expect(result.createdAt, equals(originalCreatedAt));
      });
    });

    group('deletePet', () {
      test('should delete pet when deletePet is called', () async {
        // Arrange
        const petId = '1';

        // Act & Assert
        expect(() => repository.deletePet(petId), returnsNormally);
      });

      test(
        'should not throw exception when deleting non-existent pet',
        () async {
          // Arrange
          const petId = 'non-existent-id';

          // Act & Assert
          expect(() => repository.deletePet(petId), returnsNormally);
        },
      );
    });

    group('Temporary Pet Data', () {
      test(
        'should save temporary pet data when saveTemporaryPetData is called',
        () async {
          // Arrange
          final tempData = TemporaryPetDataEntity(
            name: 'Temp Pet',
            type: 'dog',
            breed: 'Temp Breed',
            birthDate: DateTime(2021, 1, 1),
            imagePath: 'assets/images/temp.jpg',
          );

          // Act & Assert
          expect(
            () => repository.saveTemporaryPetData(tempData),
            returnsNormally,
          );
        },
      );

      test('should return null when getTemporaryPetData is called', () async {
        // Act
        final result = await repository.getTemporaryPetData();

        // Assert
        expect(result, isNull);
      });

      test(
        'should clear temporary pet data when clearTemporaryPetData is called',
        () async {
          // Act & Assert
          expect(() => repository.clearTemporaryPetData(), returnsNormally);
        },
      );
    });

    group('PetProfileEntity properties', () {
      test('should calculate age correctly', () {
        // Arrange
        final now = DateTime.now();
        final pet = PetProfileEntity(
          id: '1',
          name: 'Test Pet',
          type: 'dog',
          birthDate: DateTime(now.year - 3, now.month, now.day),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pet.age, equals(3));
      });

      test('should return correct type name for dog', () {
        // Arrange
        final pet = PetProfileEntity(
          id: '1',
          name: 'Test Dog',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pet.typeName, equals('강아지'));
      });

      test('should return correct type name for cat', () {
        // Arrange
        final pet = PetProfileEntity(
          id: '1',
          name: 'Test Cat',
          type: 'cat',
          birthDate: DateTime(2020, 1, 1),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(pet.typeName, equals('고양이'));
      });

      test('should return correct type icon', () {
        // Arrange
        final dog = PetProfileEntity(
          id: '1',
          name: 'Dog',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final cat = PetProfileEntity(
          id: '2',
          name: 'Cat',
          type: 'cat',
          birthDate: DateTime(2020, 1, 1),
          ownerId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(dog.typeIcon, equals(Icons.pets));
        expect(cat.typeIcon, equals(Icons.pets));
      });
    });
  });
}
