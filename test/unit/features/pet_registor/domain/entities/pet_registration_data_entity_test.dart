import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetRegistrationDataEntity', () {
    late PetRegistrationDataEntity testEntity;

    setUp(() {
      testEntity = const PetRegistrationDataEntity(
        selectedPetType: 'dog',
        selectedDogBreed: '柴犬',
        petName: 'テストペット',
        petGender: 'male',
        petBirthday: null,
        petSize: 'medium',
        petWeight: 25.5,
        petImagePath: 'path/to/image.jpg',
        microchipNumber: '123456789',
        isNeutered: false,
        petArrivalDate: null,
      );
    });

    group('constructor', () {
      test('should create instance with all parameters', () {
        // Act
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'cat',
          selectedCatBreed: 'ペルシャ',
          petName: 'テスト猫',
          petGender: 'female',
          petBirthday: null,
          petSize: 'small',
          petWeight: 3.5,
          petImagePath: 'path/to/cat.jpg',
          microchipNumber: '987654321',
          isNeutered: true,
          petArrivalDate: null,
        );

        // Assert
        expect(entity.selectedPetType, equals('cat'));
        expect(entity.selectedCatBreed, equals('ペルシャ'));
        expect(entity.petName, equals('テスト猫'));
        expect(entity.petGender, equals('female'));
        expect(entity.petSize, equals('small'));
        expect(entity.petWeight, equals(3.5));
        expect(entity.petImagePath, equals('path/to/cat.jpg'));
        expect(entity.microchipNumber, equals('987654321'));
        expect(entity.isNeutered, equals(true));
      });

      test('should create instance with null parameters', () {
        // Act
        const entity = PetRegistrationDataEntity();

        // Assert
        expect(entity.selectedPetType, isNull);
        expect(entity.selectedDogBreed, isNull);
        expect(entity.selectedCatBreed, isNull);
        expect(entity.customBreed, isNull);
        expect(entity.petName, isNull);
        expect(entity.petSize, isNull);
        expect(entity.petWeight, isNull);
        expect(entity.petAnniversary, isNull);
        expect(entity.petBirthday, isNull);
        expect(entity.petArrivalDate, isNull);
        expect(entity.petGender, isNull);
        expect(entity.isNeutered, isNull);
        expect(entity.petImagePath, isNull);
        expect(entity.customDefaultImagePath, isNull);
        expect(entity.microchipNumber, isNull);
      });
    });

    group('copyWith', () {
      test('should return new instance with updated values', () {
        // Act
        final updatedEntity = testEntity.copyWith(
          petName: '新しい名前',
          petWeight: 30.0,
          isNeutered: true,
        );

        // Assert
        expect(updatedEntity.petName, equals('新しい名前'));
        expect(updatedEntity.petWeight, equals(30.0));
        expect(updatedEntity.isNeutered, equals(true));
        expect(updatedEntity.selectedPetType, equals('dog')); // unchanged
        expect(updatedEntity.selectedDogBreed, equals('柴犬')); // unchanged
      });

      test('should return new instance with null values', () {
        // Act
        final updatedEntity = testEntity.copyWith(
          petName: null,
          petWeight: null,
          isNeutered: null,
        );

        // Assert
        expect(updatedEntity.petName, equals('テストペット')); // unchanged
        expect(updatedEntity.petWeight, equals(25.5)); // unchanged
        expect(updatedEntity.isNeutered, equals(false)); // unchanged
      });

      test('should update all fields', () {
        // Act
        final updatedEntity = testEntity.copyWith(
          selectedPetType: 'cat',
          selectedCatBreed: 'ペルシャ',
          selectedDogBreed: null,
          petName: '新しい猫',
          petGender: 'female',
          petBirthday: DateTime(2021, 1, 1),
          petSize: 'large',
          petWeight: 5.0,
          petImagePath: 'new/path.jpg',
          microchipNumber: '111111111',
          isNeutered: true,
          petArrivalDate: DateTime(2021, 2, 1),
        );

        // Assert
        expect(updatedEntity.selectedPetType, equals('cat'));
        expect(updatedEntity.selectedCatBreed, equals('ペルシャ'));
        expect(updatedEntity.selectedDogBreed, isNull);
        expect(updatedEntity.petName, equals('新しい猫'));
        expect(updatedEntity.petGender, equals('female'));
        expect(updatedEntity.petBirthday, equals(DateTime(2021, 1, 1)));
        expect(updatedEntity.petSize, equals('large'));
        expect(updatedEntity.petWeight, equals(5.0));
        expect(updatedEntity.petImagePath, equals('new/path.jpg'));
        expect(updatedEntity.microchipNumber, equals('111111111'));
        expect(updatedEntity.isNeutered, equals(true));
        expect(updatedEntity.petArrivalDate, equals(DateTime(2021, 2, 1)));
      });
    });

    group('currentBreed getter', () {
      test('should return dog breed when dog is selected', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
        );

        // Act
        final breed = entity.currentBreed;

        // Assert
        expect(breed, equals('柴犬'));
      });

      test('should return custom breed when custom is selected for dog', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: 'custom',
          customBreed: 'ミックス犬',
        );

        // Act
        final breed = entity.currentBreed;

        // Assert
        expect(breed, equals('ミックス犬'));
      });

      test('should return cat breed when cat is selected', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'cat',
          selectedCatBreed: 'ペルシャ',
        );

        // Act
        final breed = entity.currentBreed;

        // Assert
        expect(breed, equals('ペルシャ'));
      });

      test('should return custom breed when custom is selected for cat', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'cat',
          selectedCatBreed: 'custom',
          customBreed: 'ミックス猫',
        );

        // Act
        final breed = entity.currentBreed;

        // Assert
        expect(breed, equals('ミックス猫'));
      });

      test('should return null when no pet type is selected', () {
        // Arrange
        const entity = PetRegistrationDataEntity();

        // Act
        final breed = entity.currentBreed;

        // Assert
        expect(breed, isNull);
      });

      test('should return null when other pet type is selected', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'bird',
          selectedDogBreed: '柴犬',
        );

        // Act
        final breed = entity.currentBreed;

        // Assert
        expect(breed, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all key fields are same', () {
        // Arrange
        final entity1 = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petBirthday: DateTime(2020, 1, 1),
        );
        final entity2 = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petBirthday: DateTime(2020, 1, 1),
        );

        // Act & Assert
        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when key fields are different', () {
        // Arrange
        final entity1 = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petBirthday: DateTime(2020, 1, 1),
        );
        final entity2 = PetRegistrationDataEntity(
          selectedPetType: 'cat',
          petName: 'テストペット',
          petBirthday: DateTime(2020, 1, 1),
        );

        // Act & Assert
        expect(entity1, isNot(equals(entity2)));
        expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
      });

      test('should not be equal to different type', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
        );

        // Act & Assert
        expect(entity, isNot(equals('string')));
        expect(entity, isNot(equals(123)));
        expect(entity, isNot(equals(null)));
      });
    });

    group('toString', () {
      test('should return string representation with key fields', () {
        // Arrange
        const entity = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          selectedDogBreed: '柴犬',
        );

        // Act
        final string = entity.toString();

        // Assert
        expect(string, contains('PetRegistrationDataEntity'));
        expect(string, contains('petType: dog'));
        expect(string, contains('name: テストペット'));
        expect(string, contains('breed: 柴犬'));
      });

      test('should handle null values in toString', () {
        // Arrange
        const entity = PetRegistrationDataEntity();

        // Act
        final string = entity.toString();

        // Assert
        expect(string, contains('PetRegistrationDataEntity'));
        expect(string, contains('petType: null'));
        expect(string, contains('name: null'));
        expect(string, contains('breed: null'));
      });
    });
  });
}
