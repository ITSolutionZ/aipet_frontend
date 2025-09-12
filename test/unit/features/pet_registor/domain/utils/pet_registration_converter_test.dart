import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/utils/pet_registration_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetRegistrationConverter', () {
    group('toPetProfileEntity', () {
      test('should convert PetRegistrationDataEntity to PetProfileEntity', () {
        // Arrange
        final registrationData = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
          petImagePath: 'path/to/image.jpg',
          microchipNumber: '123456789',
          selectedDogBreed: '柴犬',
          customBreed: null,
          isNeutered: false,
          petArrivalDate: DateTime(2020, 2, 1),
        );

        // Act
        final petProfile = PetRegistrationConverter.convertToProfile(
          registrationData,
        );

        // Assert
        expect(petProfile.name, equals('テストペット'));
        expect(petProfile.type, equals('dog'));
        expect(petProfile.breed, equals('柴犬'));
        expect(petProfile.birthDate, equals(DateTime(2020, 1, 1)));
        expect(petProfile.imagePath, equals('path/to/image.jpg'));
        expect(petProfile.ownerId, equals('current_user'));
        expect(petProfile.isActive, isTrue);
        expect(petProfile.additionalInfo, isNotNull);
        expect(petProfile.additionalInfo!['gender'], equals('male'));
        expect(petProfile.additionalInfo!['size'], equals('medium'));
        expect(petProfile.additionalInfo!['weight'], equals(25.5));
        expect(
          petProfile.additionalInfo!['microchipNumber'],
          equals('123456789'),
        );
        expect(petProfile.additionalInfo!['isNeutered'], equals(false));
        expect(
          petProfile.additionalInfo!['arrivalDate'],
          equals('2020-02-01T00:00:00.000'),
        );
      });

      test('should handle null values correctly', () {
        // Arrange
        final registrationData = PetRegistrationDataEntity(
          selectedPetType: 'cat',
          petName: 'テスト猫',
          petGender: 'female',
          petBirthday: DateTime(2021, 1, 1),
          petSize: 'small',
          petWeight: 3.5,
          petImagePath: null,
          microchipNumber: null,
          selectedCatBreed: 'ペルシャ',
          customBreed: null,
          isNeutered: true,
          petArrivalDate: null,
        );

        // Act
        final petProfile = PetRegistrationConverter.convertToProfile(
          registrationData,
        );

        // Assert
        expect(petProfile.name, equals('テスト猫'));
        expect(petProfile.type, equals('cat'));
        expect(petProfile.breed, equals('ペルシャ'));
        expect(petProfile.imagePath, isNotNull);
        expect(petProfile.ownerId, equals('current_user'));
        expect(petProfile.additionalInfo!['microchipNumber'], isNull);
        expect(petProfile.additionalInfo!['arrivalDate'], isNull);
      });

      test('should handle custom breed', () {
        // Arrange
        final registrationData = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'カスタム犬',
          petGender: 'male',
          petBirthday: DateTime(2019, 1, 1),
          petSize: 'large',
          petWeight: 40.0,
          petImagePath: null,
          microchipNumber: null,
          selectedDogBreed: 'custom',
          customBreed: 'ミックス犬',
          isNeutered: false,
          petArrivalDate: null,
        );

        // Act
        final petProfile = PetRegistrationConverter.convertToProfile(
          registrationData,
        );

        // Assert
        expect(petProfile.breed, equals('ミックス犬'));
      });
    });

    group('convertToProfile edge cases', () {
      test('should throw error when required data is missing', () {
        // Arrange
        const registrationData = PetRegistrationDataEntity(
          selectedPetType: null,
          petName: 'テストペット',
        );

        // Act & Assert
        expect(
          () => PetRegistrationConverter.convertToProfile(registrationData),
          throwsArgumentError,
        );
      });

      test('should use default birth date when not provided', () {
        // Arrange
        const registrationData = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petBirthday: null,
        );

        // Act
        final petProfile = PetRegistrationConverter.convertToProfile(
          registrationData,
        );

        // Assert
        expect(petProfile.birthDate, isNotNull);
        expect(petProfile.birthDate, isA<DateTime>());
      });
    });

    group('utility methods', () {
      test('isValidForRegistration should return true for valid data', () {
        // Arrange
        const validData = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
        );

        // Act
        final result = PetRegistrationConverter.isValidForRegistration(
          validData,
        );

        // Assert
        expect(result, isTrue);
      });

      test('isValidForRegistration should return false for invalid data', () {
        // Arrange
        const invalidData1 = PetRegistrationDataEntity(
          selectedPetType: null,
          petName: 'テストペット',
        );
        const invalidData2 = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: null,
        );
        const invalidData3 = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: '',
        );

        // Act & Assert
        expect(
          PetRegistrationConverter.isValidForRegistration(invalidData1),
          isFalse,
        );
        expect(
          PetRegistrationConverter.isValidForRegistration(invalidData2),
          isFalse,
        );
        expect(
          PetRegistrationConverter.isValidForRegistration(invalidData3),
          isFalse,
        );
      });

      test('isRegistrationComplete should return true for complete data', () {
        // Arrange
        final completeData = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: 'テストペット',
          petBirthday: DateTime(2020, 1, 1),
        );

        // Act
        final result = PetRegistrationConverter.isRegistrationComplete(
          completeData,
        );

        // Assert
        expect(result, isTrue);
      });

      test(
        'isRegistrationComplete should return false for incomplete data',
        () {
          // Arrange
          const incompleteData1 = PetRegistrationDataEntity(
            selectedPetType: 'dog',
            petName: 'テストペット',
            petBirthday: null,
          );
          final incompleteData2 = PetRegistrationDataEntity(
            selectedPetType: 'dog',
            petName: null,
            petBirthday: DateTime(2020, 1, 1),
          );

          // Act & Assert
          expect(
            PetRegistrationConverter.isRegistrationComplete(incompleteData1),
            isFalse,
          );
          expect(
            PetRegistrationConverter.isRegistrationComplete(incompleteData2),
            isFalse,
          );
        },
      );
    });
  });
}
