import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/services/pet_validation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetValidationUtils', () {
    group('canProceedToNextStep', () {
      test(
        'should return true when all required data for step 1 is present',
        () {
          // Arrange
          final data = PetRegistrationDataEntity(
            selectedPetType: 'dog',
            petName: 'テストペット',
            petGender: 'male',
            petBirthday: DateTime(2020, 1, 1),
            petSize: 'medium',
            petWeight: 25.5,
          );

          // Act
          final result = PetValidationUtils.canProceedToNextStep(data, 1);

          // Assert
          expect(result, isTrue);
        },
      );

      test('should return false when required data for step 1 is missing', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: null,
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        final result = PetValidationUtils.canProceedToNextStep(data, 1);

        // Assert
        expect(result, isFalse);
      });

      test(
        'should return true when all required data for step 2 is present',
        () {
          // Arrange
          final data = PetRegistrationDataEntity(
            selectedPetType: 'dog',
            selectedDogBreed: '柴犬',
            petName: 'テストペット',
            petGender: 'male',
            petBirthday: DateTime(2020, 1, 1),
            petSize: 'medium',
            petWeight: 25.5,
          );

          // Act
          final result = PetValidationUtils.canProceedToNextStep(data, 2);

          // Assert
          expect(result, isTrue);
        },
      );

      test('should return false when breed is missing for step 2', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: null,
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        final result = PetValidationUtils.canProceedToNextStep(data, 2);

        // Assert
        expect(result, isFalse);
      });
    });

    group('isRegistrationComplete', () {
      test('should return true when all required fields are present', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
          selectedDogBreed: '柴犬',
        );

        // Act
        final result = PetValidationUtils.isRegistrationComplete(data);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when any required field is missing', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: null, // Missing required field
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
          selectedDogBreed: '柴犬',
        );

        // Act
        final result = PetValidationUtils.isRegistrationComplete(data);

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasDataBeyondStep', () {
      test('should return true when there is data beyond current step', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        final result = PetValidationUtils.hasDataBeyondStep(data, 1);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when there is no data beyond current step', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        final result = PetValidationUtils.hasDataBeyondStep(data, 5);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCurrentBreed', () {
      test('should return dog breed when dog is selected', () {
        // Arrange
        const data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          selectedCatBreed: null,
          customBreed: null,
        );

        // Act
        final result = PetValidationUtils.getCurrentBreed(data);

        // Assert
        expect(result, equals('柴犬'));
      });

      test('should return cat breed when cat is selected', () {
        // Arrange
        const data = PetRegistrationDataEntity(
          selectedPetType: 'cat',
          selectedDogBreed: null,
          selectedCatBreed: 'ペルシャ',
          customBreed: null,
        );

        // Act
        final result = PetValidationUtils.getCurrentBreed(data);

        // Assert
        expect(result, equals('ペルシャ'));
      });

      test('should return custom breed when custom is selected', () {
        // Arrange
        const data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: 'custom',
          selectedCatBreed: null,
          customBreed: 'ミックス犬',
        );

        // Act
        final result = PetValidationUtils.getCurrentBreed(data);

        // Assert
        expect(result, equals('ミックス犬'));
      });

      test('should return null when no pet type is selected', () {
        // Arrange
        const data = PetRegistrationDataEntity(
          selectedPetType: null,
          selectedDogBreed: null,
          selectedCatBreed: null,
          customBreed: null,
        );

        // Act
        final result = PetValidationUtils.getCurrentBreed(data);

        // Assert
        expect(result, isNull);
      });
    });

    group('isValidPetName', () {
      test('should return true for valid pet name', () {
        // Act & Assert
        expect(PetValidationUtils.isValidPetName('テストペット'), isTrue);
        expect(PetValidationUtils.isValidPetName('ポチ'), isTrue);
        expect(PetValidationUtils.isValidPetName('Max'), isTrue);
      });

      test('should return false for invalid pet name', () {
        // Act & Assert
        expect(PetValidationUtils.isValidPetName(null), isFalse);
        expect(PetValidationUtils.isValidPetName(''), isFalse);
        expect(PetValidationUtils.isValidPetName('   '), isFalse);
      });
    });

    group('isValidWeight', () {
      test('should return true for valid weight', () {
        // Act & Assert
        expect(PetValidationUtils.isValidWeight(1.0), isTrue);
        expect(PetValidationUtils.isValidWeight(25.5), isTrue);
        expect(PetValidationUtils.isValidWeight(100.0), isTrue);
      });

      test('should return false for invalid weight', () {
        // Act & Assert
        expect(PetValidationUtils.isValidWeight(null), isFalse);
        expect(PetValidationUtils.isValidWeight(0.0), isFalse);
        expect(PetValidationUtils.isValidWeight(-1.0), isFalse);
        expect(PetValidationUtils.isValidWeight(1000.0), isFalse); // Too heavy
      });
    });

    group('isValidMicrochipNumber', () {
      test('should return true for valid microchip number', () {
        // Act & Assert
        expect(
          PetValidationUtils.isValidMicrochipNumber('123456789012345'),
          isTrue,
        );
      });

      test('should return false for invalid microchip number', () {
        // Act & Assert
        expect(PetValidationUtils.isValidMicrochipNumber(null), isFalse);
        expect(PetValidationUtils.isValidMicrochipNumber(''), isFalse);
        expect(
          PetValidationUtils.isValidMicrochipNumber('12'),
          isFalse,
        ); // Too short
      });
    });

    group('canProceedToNextStep - additional cases', () {
      test('should handle step 3 (name input)', () {
        // Arrange
        const dataWithName = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
        );
        const dataWithoutName = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: null,
        );

        // Act & Assert
        expect(
          PetValidationUtils.canProceedToNextStep(dataWithName, 3),
          isTrue,
        );
        expect(
          PetValidationUtils.canProceedToNextStep(dataWithoutName, 3),
          isFalse,
        );
      });

      test('should handle step 4 (size/weight input)', () {
        // Arrange
        const dataWithSizeWeight = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petSize: 'medium',
          petWeight: 25.5,
        );
        const dataWithoutSizeWeight = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petSize: null,
          petWeight: null,
        );

        // Act & Assert
        expect(
          PetValidationUtils.canProceedToNextStep(dataWithSizeWeight, 4),
          isTrue,
        );
        expect(
          PetValidationUtils.canProceedToNextStep(dataWithoutSizeWeight, 4),
          isFalse,
        );
      });

      test('should handle step 5 (birthday input)', () {
        // Arrange
        final dataWithBirthday = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petSize: 'medium',
          petWeight: 25.5,
          petBirthday: DateTime(2020, 1, 1),
        );
        const dataWithoutBirthday = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petSize: 'medium',
          petWeight: 25.5,
          petBirthday: null,
        );

        // Act & Assert
        expect(
          PetValidationUtils.canProceedToNextStep(dataWithBirthday, 5),
          isTrue,
        );
        expect(
          PetValidationUtils.canProceedToNextStep(dataWithoutBirthday, 5),
          isFalse,
        );
      });

      test('should return false for invalid step numbers', () {
        // Arrange
        const data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
        );

        // Act & Assert
        expect(PetValidationUtils.canProceedToNextStep(data, 0), isFalse);
        expect(PetValidationUtils.canProceedToNextStep(data, 6), isFalse);
        expect(PetValidationUtils.canProceedToNextStep(data, -1), isFalse);
      });
    });

    group('hasDataBeyondStep - additional cases', () {
      test('should detect data beyond step 3', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petBirthday: DateTime(2020, 1, 1),
        );

        // Act & Assert
        expect(PetValidationUtils.hasDataBeyondStep(data, 3), isTrue);
      });

      test('should detect data beyond step 4', () {
        // Arrange
        final data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petSize: 'medium',
          petWeight: 25.5,
          petBirthday: DateTime(2020, 1, 1),
        );

        // Act & Assert
        expect(PetValidationUtils.hasDataBeyondStep(data, 4), isTrue);
      });

      test('should return false when no data beyond step', () {
        // Arrange
        const data = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
        );

        // Act & Assert
        expect(PetValidationUtils.hasDataBeyondStep(data, 5), isFalse);
      });
    });
  });
}
