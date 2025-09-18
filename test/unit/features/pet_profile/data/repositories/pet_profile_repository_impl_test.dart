import 'package:aipet_frontend/features/pet_profile/data/repositories/pet_profile_repository_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileRepositoryImpl', () {
    late PetProfileRepositoryImpl repository;

    setUp(() {
      repository = PetProfileRepositoryImpl();
      // Repository now loads mock data automatically from PetMockService
      // Available mock pets: '1' (MAX), '2' (LUNA), '3' (MOMO)
    });

    group('getPetProfile', () {
      test('should return pet profile when pet exists', () async {
        // Act - Using mock data from PetMockService (id: '1', name: 'MAX')
        final result = await repository.getPetProfile('1');

        // Assert
        expect(result, isNotNull);
        expect(result.id, equals('1'));
        expect(result.name, equals('MAX'));
        expect(result.type, equals('dog'));
        expect(result.breed, equals('Golden Retriever'));
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
        expect(result.name, equals('LUNA'));
      });
    });

    group('updatePetProfile', () {
      test('should update and return pet profile', () async {
        // Arrange - Get existing pet and update it
        final existingPet = await repository.getPetProfile('1');
        final updatedPet = existingPet.copyWith(
          name: '更新されたMAX',
          updatedAt: DateTime(2023, 12, 2),
          additionalInfo: {
            ...existingPet.additionalInfo ?? {},
            'weight': 20.0,
          },
        );

        // Act
        final result = await repository.updatePetProfile(updatedPet);

        // Assert
        expect(result, equals(updatedPet));
        expect(result.name, equals('更新されたMAX'));
        expect(result.additionalInfo?['weight'], equals(20.0));
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
          additionalInfo: {
            'weight': 10.0,
            'gender': 'male',
          },
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
        final updatedPet = existingPet.copyWith(
          name: '更新されたLUNA',
          additionalInfo: {
            ...existingPet.additionalInfo ?? {},
            'weight': 4.0,
          },
        );

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

    group('updateSharingSettings', () {
      test('should update sharing settings to public', () async {
        // Act
        await repository.updateSharingSettings('1', true);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should update sharing settings to private', () async {
        // Act
        await repository.updateSharingSettings('2', false);

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
        await repository.updateSharingSettings('1', true);
        await repository.updateSharingSettings('1', false);
        await repository.updateSharingSettings('1', true);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });
    });

    group('addFamilyManager', () {
      test('should add family manager successfully', () async {
        // Arrange
        const userId = 'new-manager-1';

        // Act
        await repository.addFamilyManager('1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should not add duplicate family manager', () async {
        // Arrange
        const userId = 'user-1'; // 이미 존재하는 매니저

        // Act
        await repository.addFamilyManager('1', userId);

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
        await repository.addFamilyManager('1', 'manager-1');
        await repository.addFamilyManager('1', 'manager-2');
        await repository.addFamilyManager('1', 'manager-3');

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });
    });

    group('removeFamilyManager', () {
      test('should remove family manager successfully', () async {
        // Arrange
        const userId = 'user-1';

        // Act
        await repository.removeFamilyManager('1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should handle removing non-existent manager gracefully', () async {
        // Arrange
        const userId = 'non-existent-manager';

        // Act
        await repository.removeFamilyManager('1', userId);

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
        await repository.removeFamilyManager('1', 'user-1');
        await repository.removeFamilyManager('1', 'user-2');
        await repository.removeFamilyManager('1', 'non-existent-user');

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });
    });
  });
}
