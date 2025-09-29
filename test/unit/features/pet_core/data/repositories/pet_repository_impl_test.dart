import 'package:aipet_frontend/features/pet_registor/data/repositories/pet_repository_impl.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/temporary_pet_data_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PetRepositoryImpl repository;

  setUp(() {
    repository = PetRepositoryImpl();
  });

  group('PetRepositoryImpl', () {
    test('should return list of pets when getAllPets is called', () async {
      // Act
      final result = await repository.getAllPets();

      // Assert
      expect(result, isA<Result<List<PetProfileEntity>>>());
      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(2));
      expect(result.data!.first, isA<PetProfileEntity>());
    });

    test('should return pet when getPetById is called with valid id', () async {
      // Arrange
      const petId = '1';

      // Act
      final result = await repository.getPetById(petId);

      // Assert
      expect(result, isA<Result<PetProfileEntity?>>());
      expect(result.isSuccess, isTrue);
      expect(result.data!.id, equals(petId));
      expect(result.data!.name, equals('멍멍이'));
      expect(result.data!.type, equals('dog'));
    });

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

    test('should create pet when createPet is called', () async {
      // Arrange
      final pet = PetProfileEntity(
        id: '',
        name: 'Test Pet',
        type: 'cat',
        breed: 'Test Breed',
        age: 2,
        gender: 'female',
        weight: 5.0,
        birthDate: DateTime(2022, 1, 1),
        imagePath: 'assets/images/test.jpg',
        ownerId: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.createPet(pet);

      // Assert
      expect(result, isA<Result<PetProfileEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data!.name, equals('Test Pet'));
      expect(result.data!.id, isNotEmpty);
      expect(result.data!.createdAt, isNotNull);
    });

    test('should update pet when updatePet is called', () async {
      // Arrange
      final pet = PetProfileEntity(
        id: '1',
        name: 'Updated Pet',
        type: 'dog',
        breed: 'Updated Breed',
        age: 4,
        gender: 'male',
        weight: 15.0,
        birthDate: DateTime(2020, 1, 1),
        imagePath: 'assets/images/updated.jpg',
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await repository.updatePet(pet);

      // Assert
      expect(result, isA<Result<PetProfileEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data!.name, equals('Updated Pet'));
      expect(result.data!.updatedAt, isNotNull);
    });

    test('should delete pet when deletePet is called', () async {
      // Arrange
      const petId = '1';

      // Act & Assert
      expect(() => repository.deletePet(petId), returnsNormally);
    });

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
      expect(result, isA<Result<PetProfileEntity?>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });

    test(
      'should clear temporary pet data when clearTemporaryPetData is called',
      () async {
        // Act & Assert
        expect(() => repository.clearTemporaryPetData(), returnsNormally);
      },
    );
  });
}
