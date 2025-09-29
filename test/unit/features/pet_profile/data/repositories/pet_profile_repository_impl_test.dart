import 'package:aipet_frontend/features/pet_profile/data/repositories/pet_profile_repository_impl.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileRepositoryImpl', () {
    late PetProfileRepositoryImpl repository;

    setUp(() {
      repository = PetProfileRepositoryImpl();
    });

    group('getPetProfile', () {
      test('should return pet profile when pet exists', () async {
        // Act - Using mock data from PetMockService (id: '1', name: 'MAX')
        final result = await repository.getPetProfile('1');

        // Assert
        expect(result, isNotNull);
        expect(result.id, equals('1'));
        expect(result.name, equals('マックス'));
        expect(result.type, equals('dog'));
        expect(result.breed, equals('ゴールデンレトリバー'));
      });

      test('should throw exception when pet not found', () async {
        // Act & Assert
        expect(
          () => repository.getPetProfile('non-existent-pet'),
          throwsA(isA<Exception>()),
        );
      });

      test('should work with MockDataService enabled', () async {
        // Act - Test another mock pet (id: '2', name: 'LUNA')
        final result = await repository.getPetProfile('2');

        // Assert
        expect(result, isNotNull);
        expect(result.id, equals('2'));
        expect(result.name, equals('ルナ'));
      });
    });

    group('updatePetProfile', () {
      test('should update and return pet profile', () async {
        // Arrange - Get existing pet and update it
        final existingPet = await repository.getPetProfile('1');
        final updatedPet = existingPet.copyWith(
          name: '更新されたMAX',
          updatedAt: DateTime(2023, 12, 2),
        );

        // Act
        final result = await repository.updatePetProfile(updatedPet);

        // Assert
        expect(result, equals(updatedPet));
        expect(result.name, equals('更新されたMAX'));
      });

      test('should throw exception when pet not found for update', () async {
        // Arrange
        final nonExistentPet = PetProfileEntity(
          id: 'non-existent',
          name: 'Non Existent Pet',
          type: 'dog',
          breed: 'Unknown',
          birthDate: DateTime(2022, 1, 1),
          imagePath: 'image.jpg',
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.updatePetProfile(nonExistentPet),
          throwsA(isA<Exception>()),
        );
      });

      test('should update pet profile successfully', () async {
        // Arrange - Get existing pet and update name
        final existingPet = await repository.getPetProfile('2');
        final updatedPet = existingPet.copyWith(name: '更新されたLUNA');

        // Act
        final result = await repository.updatePetProfile(updatedPet);

        // Assert
        expect(result, equals(updatedPet));
        expect(result.name, equals('更新されたLUNA'));
      });
    });

    group('uploadPetImage', () {
      test('should return image URL when upload succeeds', () async {
        // Arrange
        const imagePath = 'path/to/image.jpg';

        // Act
        final result = await repository.uploadPetImage('1', imagePath);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('https://example.com/images/1/'));
        expect(result, contains('.jpg'));
      });

      test('should return different URLs for different pets', () async {
        // Act
        final result1 = await repository.uploadPetImage(
          'pet-1',
          'path/to/image1.jpg',
        );
        final result2 = await repository.uploadPetImage(
          'pet-2',
          'path/to/image2.jpg',
        );

        // Assert
        expect(result1, isNot(equals(result2)));
        expect(result1, contains('1'));
        expect(result2, contains('2'));
      });
    });

    group('addFamilyManager', () {
      test('should add family manager successfully', () async {
        // Arrange
        const petId = '1';
        const managerId = 'manager-123';

        // Act
        await repository.addFamilyManager(petId, managerId);

        // Assert - No exception should be thrown
        expect(true, isTrue);
      });
    });

    group('removeFamilyManager', () {
      test('should remove family manager successfully', () async {
        // Arrange
        const petId = '1';
        const managerId = 'manager-123';

        // Act
        await repository.removeFamilyManager(petId, managerId);

        // Assert - No exception should be thrown
        expect(true, isTrue);
      });
    });
  });
}
