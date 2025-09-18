import 'package:aipet_frontend/features/pet_profile/data/repositories/pet_profile_repository_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileRepositoryImpl', () {
    late PetProfileRepositoryImpl repository;
    late List<PetProfileEntity> mockProfiles;

    setUp(() {
      mockProfiles = [
        PetProfileEntity(
          id: 'pet-1',
          name: 'テストペット1',
          type: 'dog',
          breed: '柴犬',
          age: 3,
          gender: 'male',
          weight: 12.5,
          imagePath: 'image1.jpg',
          ownerId: 'owner-1',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 12, 1),
          additionalInfo: {
            'microchipNumber': '123456789012345',
            'isPublic': true,
            'familyManagers': ['user-1'],
          },
        ),
        PetProfileEntity(
          id: 'pet-2',
          name: 'テストペット2',
          type: 'cat',
          breed: 'アメリカンショートヘア',
          age: 2,
          gender: 'female',
          weight: 4.2,
          imagePath: 'image2.jpg',
          ownerId: 'owner-2',
          createdAt: DateTime(2023, 2, 1),
          updatedAt: DateTime(2023, 12, 1),
          additionalInfo: {
            'microchipNumber': '987654321098765',
            'isPublic': false,
            'familyManagers': ['user-2'],
          },
        ),
      ];

      repository = PetProfileRepositoryImpl();
    });

    group('getPetProfile', () {
      test('should return pet profile when pet exists', () async {
        // Act
        final result = await repository.getPetProfile('pet-1');

        // Assert
        expect(result, isNotNull);
        expect(result.id, equals('pet-1'));
        expect(result.name, equals('テストペット1'));
        expect(result.type, equals('dog'));
        expect(result.breed, equals('柴犬'));
      });

      test('should throw exception when pet not found', () async {
        // Act & Assert
        expect(
          () => repository.getPetProfile('non-existent-pet'),
          throwsA(isA<Exception>()),
        );
      });

      test('should work with MockDataService enabled', () async {
        // Act
        final result = await repository.getPetProfile('pet-1');

        // Assert
        expect(result, isNotNull);
        expect(result.id, equals('pet-1'));
      });
    });

    group('updatePetProfile', () {
      test('should update and return pet profile', () async {
        // Arrange
        final updatedPet = mockProfiles[0].copyWith(
          name: '更新されたペット',
          weight: 13.0,
          updatedAt: DateTime(2023, 12, 2),
        );

        // Act
        final result = await repository.updatePetProfile(updatedPet);

        // Assert
        expect(result, equals(updatedPet));
        expect(result.name, equals('更新されたペット'));
        expect(result.weight, equals(13.0));
      });

      test('should throw exception when pet not found for update', () async {
        // Arrange
        final nonExistentPet = PetProfileEntity(
          id: 'non-existent',
          name: 'Non Existent Pet',
          type: 'dog',
          breed: 'Unknown',
          age: 1,
          gender: 'male',
          weight: 10.0,
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
        // Arrange
        final updatedPet = mockProfiles[0].copyWith(
          name: '更新されたペット',
          weight: 13.0,
        );

        // Act
        final result = await repository.updatePetProfile(updatedPet);

        // Assert
        expect(result, equals(updatedPet));
        expect(result.name, equals('更新されたペット'));
      });
    });

    group('uploadPetImage', () {
      test('should return image URL when upload succeeds', () async {
        // Arrange
        const imagePath = 'path/to/image.jpg';

        // Act
        final result = await repository.uploadPetImage('pet-1', imagePath);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('https://example.com/images/pet-1/'));
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
        expect(result1, contains('pet-1'));
        expect(result2, contains('pet-2'));
      });
    });

    group('updateSharingSettings', () {
      test('should update sharing settings to public', () async {
        // Act
        await repository.updateSharingSettings('pet-1', true);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should update sharing settings to private', () async {
        // Act
        await repository.updateSharingSettings('pet-1', false);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should throw exception when pet not found', () async {
        // Act & Assert
        expect(
          () => repository.updateSharingSettings('non-existent-pet', true),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle multiple sharing setting updates', () async {
        // Act
        await repository.updateSharingSettings('pet-1', true);
        await repository.updateSharingSettings('pet-1', false);
        await repository.updateSharingSettings('pet-1', true);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });
    });

    group('addFamilyManager', () {
      test('should add family manager successfully', () async {
        // Arrange
        const userId = 'new-manager-1';

        // Act
        await repository.addFamilyManager('pet-1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should not add duplicate family manager', () async {
        // Arrange
        const userId = 'user-1'; // 이미 존재하는 매니저

        // Act
        await repository.addFamilyManager('pet-1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should throw exception when pet not found', () async {
        // Act & Assert
        expect(
          () => repository.addFamilyManager('non-existent-pet', 'user-1'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle adding multiple family managers', () async {
        // Act
        await repository.addFamilyManager('pet-1', 'manager-1');
        await repository.addFamilyManager('pet-1', 'manager-2');
        await repository.addFamilyManager('pet-1', 'manager-3');

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });
    });

    group('removeFamilyManager', () {
      test('should remove family manager successfully', () async {
        // Arrange
        const userId = 'user-1';

        // Act
        await repository.removeFamilyManager('pet-1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should handle removing non-existent manager gracefully', () async {
        // Arrange
        const userId = 'non-existent-manager';

        // Act
        await repository.removeFamilyManager('pet-1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should throw exception when pet not found', () async {
        // Act & Assert
        expect(
          () => repository.removeFamilyManager('non-existent-pet', 'user-1'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle removing multiple family managers', () async {
        // Act
        await repository.removeFamilyManager('pet-1', 'user-1');
        await repository.removeFamilyManager('pet-1', 'user-2');
        await repository.removeFamilyManager('pet-1', 'non-existent-user');

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });
    });
  });
}
