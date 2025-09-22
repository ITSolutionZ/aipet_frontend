import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/shared/testing/mock_data/test/test_data_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetSummaryEntity', () {
    late PetSummaryEntity testPet;

    setUp(() {
      testPet = TestDataHelper.petSummary;
    });

    group('constructor', () {
      test('should create pet summary with all parameters', () {
        // Act
        final pet = PetSummaryEntity(
          id: 'test-pet',
          name: 'テストペット',
          typeName: 'cat',
          breed: 'アメリカンショートヘア',
          age: 2,
          birthDate: DateTime(2022, 1, 1),
          createdAt: DateTime(2022, 1, 1),
          profileImageUrl: '/path/to/test.jpg',
          additionalInfo: {'test': 'data'},
        );

        // Assert
        expect(pet.id, equals('test-pet'));
        expect(pet.name, equals('テストペット'));
        expect(pet.typeName, equals('cat'));
        expect(pet.breed, equals('アメリカンショートヘア'));
        expect(pet.age, equals(2));
        expect(pet.birthDate, equals(DateTime(2022, 1, 1)));
        expect(pet.createdAt, equals(DateTime(2022, 1, 1)));
        expect(pet.profileImageUrl, equals('/path/to/test.jpg'));
        expect(pet.additionalInfo, equals({'test': 'data'}));
      });

      test('should create pet summary with required parameters only', () {
        // Act
        final pet = PetSummaryEntity(
          id: 'simple-pet',
          name: 'シンプルペット',
          typeName: 'bird',
          age: 1,
          birthDate: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        // Assert
        expect(pet.id, equals('simple-pet'));
        expect(pet.name, equals('シンプルペット'));
        expect(pet.typeName, equals('bird'));
        expect(pet.breed, isNull);
        expect(pet.age, equals(1));
        expect(pet.birthDate, equals(DateTime(2023, 1, 1)));
        expect(pet.createdAt, equals(DateTime(2023, 1, 1)));
        expect(pet.profileImageUrl, isNull);
        expect(pet.additionalInfo, isNull);
      });
    });

    group('typeIcon getter', () {
      test('should return dog icon for dog type', () {
        // Arrange
        final dogPet = testPet.copyWith(typeName: 'dog');

        // Act
        final icon = dogPet.typeIcon;

        // Assert
        expect(icon, equals('🐕'));
      });

      test('should return dog icon for Japanese dog type', () {
        // Arrange
        final dogPet = testPet.copyWith(typeName: '개');

        // Act
        final icon = dogPet.typeIcon;

        // Assert
        expect(icon, equals('🐕'));
      });

      test('should return cat icon for cat type', () {
        // Arrange
        final catPet = testPet.copyWith(typeName: 'cat');

        // Act
        final icon = catPet.typeIcon;

        // Assert
        expect(icon, equals('🐱'));
      });

      test('should return cat icon for Japanese cat type', () {
        // Arrange
        final catPet = testPet.copyWith(typeName: '고양이');

        // Act
        final icon = catPet.typeIcon;

        // Assert
        expect(icon, equals('🐱'));
      });

      test('should return default icon for unknown type', () {
        // Arrange
        final unknownPet = testPet.copyWith(typeName: 'unknown');

        // Act
        final icon = unknownPet.typeIcon;

        // Assert
        expect(icon, equals('🐾'));
      });

      test('should return default icon for empty type', () {
        // Arrange
        final emptyPet = testPet.copyWith(typeName: '');

        // Act
        final icon = emptyPet.typeIcon;

        // Assert
        expect(icon, equals('🐾'));
      });

      test('should handle case insensitive type matching', () {
        // Arrange
        final upperCasePet = testPet.copyWith(typeName: 'DOG');
        final mixedCasePet = testPet.copyWith(typeName: 'Cat');

        // Act
        final upperIcon = upperCasePet.typeIcon;
        final mixedIcon = mixedCasePet.typeIcon;

        // Assert
        expect(upperIcon, equals('🐕'));
        expect(mixedIcon, equals('🐱'));
      });
    });

    group('ageCategory getter', () {
      test('should return puppy for age less than 1', () {
        // Arrange
        final puppyPet = testPet.copyWith(age: 0);

        // Act
        final category = puppyPet.ageCategory;

        // Assert
        expect(category, equals('puppy'));
      });

      test('should return adult for age 1 to 7', () {
        // Arrange
        final adultPet1 = testPet.copyWith(age: 1);
        final adultPet7 = testPet.copyWith(age: 7);

        // Act
        final category1 = adultPet1.ageCategory;
        final category7 = adultPet7.ageCategory;

        // Assert
        expect(category1, equals('adult'));
        expect(category7, equals('adult'));
      });

      test('should return senior for age 8 and above', () {
        // Arrange
        final seniorPet8 = testPet.copyWith(age: 8);
        final seniorPet15 = testPet.copyWith(age: 15);

        // Act
        final category8 = seniorPet8.ageCategory;
        final category15 = seniorPet15.ageCategory;

        // Assert
        expect(category8, equals('senior'));
        expect(category15, equals('senior'));
      });

      test('should handle negative age', () {
        // Arrange
        final negativePet = testPet.copyWith(age: -1);

        // Act
        final category = negativePet.ageCategory;

        // Assert
        expect(category, equals('puppy'));
      });
    });

    group('copyWith method', () {
      test('should update only provided fields', () {
        // Act
        final updatedPet = testPet.copyWith(name: 'Updated Name', age: 5);

        // Assert
        expect(updatedPet.id, equals('pet-1')); // unchanged
        expect(updatedPet.name, equals('Updated Name'));
        expect(updatedPet.typeName, equals('dog')); // unchanged
        expect(updatedPet.breed, equals('柴犬')); // unchanged
        expect(updatedPet.age, equals(5));
        expect(updatedPet.birthDate, equals(DateTime(2021, 1, 1))); // unchanged
        expect(updatedPet.createdAt, equals(DateTime(2021, 1, 1))); // unchanged
        expect(
          updatedPet.profileImageUrl,
          equals('/path/to/image.jpg'),
        ); // unchanged
        expect(
          updatedPet.additionalInfo,
          equals({'color': 'brown', 'weight': 10.5}),
        ); // unchanged
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedPet = testPet.copyWith();

        // Assert
        expect(updatedPet.id, equals(testPet.id));
        expect(updatedPet.name, equals(testPet.name));
        expect(updatedPet.typeName, equals(testPet.typeName));
        expect(updatedPet.breed, equals(testPet.breed));
        expect(updatedPet.age, equals(testPet.age));
        expect(updatedPet.birthDate, equals(testPet.birthDate));
        expect(updatedPet.createdAt, equals(testPet.createdAt));
        expect(updatedPet.profileImageUrl, equals(testPet.profileImageUrl));
        expect(updatedPet.additionalInfo, equals(testPet.additionalInfo));
      });
    });

    group('edge cases', () {
      test('should handle empty name and breed', () {
        // Act
        final emptyPet = testPet.copyWith(name: '', breed: '');

        // Assert
        expect(emptyPet.name, equals(''));
        expect(emptyPet.breed, equals(''));
      });

      test('should handle very long name and breed', () {
        // Arrange
        final longName = 'A' * 1000;
        final longBreed = 'B' * 1000;

        // Act
        final longPet = testPet.copyWith(name: longName, breed: longBreed);

        // Assert
        expect(longPet.name, equals(longName));
        expect(longPet.breed, equals(longBreed));
        expect(longPet.name.length, equals(1000));
        expect(longPet.breed!.length, equals(1000));
      });

      test('should handle special characters in name and breed', () {
        // Arrange
        const specialName = 'スペシャルペット: !@#\$%^&*()🎉🚀';
        const specialBreed = 'スペシャル品種: !@#\$%^&*()🎉🚀';

        // Act
        final specialPet = testPet.copyWith(
          name: specialName,
          breed: specialBreed,
        );

        // Assert
        expect(specialPet.name, equals(specialName));
        expect(specialPet.breed, equals(specialBreed));
      });

      test('should handle complex additionalInfo', () {
        // Arrange
        final complexInfo = {
          'nested': {'key': 'value'},
          'list': [1, 2, 3],
          'boolean': true,
          'number': 42.5,
          'nullValue': null,
        };

        // Act
        final complexPet = testPet.copyWith(additionalInfo: complexInfo);

        // Assert
        expect(complexPet.additionalInfo, equals(complexInfo));
      });

      test('should handle very old birth date', () {
        // Arrange
        final oldDate = DateTime(1900, 1, 1);

        // Act
        final oldPet = testPet.copyWith(birthDate: oldDate);

        // Assert
        expect(oldPet.birthDate, equals(oldDate));
      });

      test('should handle future birth date', () {
        // Arrange
        final futureDate = DateTime(2030, 1, 1);

        // Act
        final futurePet = testPet.copyWith(birthDate: futureDate);

        // Assert
        expect(futurePet.birthDate, equals(futureDate));
      });

      test('should handle very large age', () {
        // Act
        final oldPet = testPet.copyWith(age: 1000);

        // Assert
        expect(oldPet.age, equals(1000));
        expect(oldPet.ageCategory, equals('senior'));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final samePet = PetSummaryEntity(
          id: 'pet-1',
          name: 'テストペット',
          typeName: 'dog',
          breed: '柴犬',
          age: 3,
          birthDate: DateTime(2021, 1, 1),
          createdAt: DateTime(2021, 1, 1),
          profileImageUrl: '/path/to/image.jpg',
          additionalInfo: {'color': 'brown', 'weight': 10.5},
        );

        // Assert
        expect(testPet, equals(samePet));
        expect(testPet.hashCode, equals(samePet.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentPet = testPet.copyWith(name: 'Different Name');

        // Assert
        expect(testPet, isNot(equals(differentPet)));
        expect(testPet.hashCode, isNot(equals(differentPet.hashCode)));
      });

      test('should be equal to itself', () {
        // Assert
        expect(testPet, equals(testPet));
        expect(testPet.hashCode, equals(testPet.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testPet.toString();

        // Assert
        expect(stringRepresentation, contains('PetSummaryEntity'));
        expect(stringRepresentation, contains('pet-1'));
        expect(stringRepresentation, contains('テストペット'));
      });
    });
  });
}
