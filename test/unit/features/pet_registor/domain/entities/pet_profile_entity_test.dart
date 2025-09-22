import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileEntity', () {
    group('constructor', () {
      test('should create PetProfileEntity with required fields', () {
        // Arrange & Act
        final pet = PetProfileEntity(
          id: 'test-id',
          name: 'Test Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Assert
        expect(pet.id, equals('test-id'));
        expect(pet.name, equals('Test Pet'));
        expect(pet.type, equals('dog'));
        expect(pet.birthDate, equals(DateTime(2020, 1, 1)));
        expect(pet.ownerId, equals('owner-123'));
        expect(pet.createdAt, equals(DateTime(2023, 1, 1)));
        expect(pet.updatedAt, equals(DateTime(2023, 1, 1)));
        expect(pet.isActive, isTrue);
        expect(pet.breed, isNull);
        expect(pet.imagePath, isNull);
        expect(pet.additionalInfo, isNull);
      });

      test('should create PetProfileEntity with all fields', () {
        // Arrange & Act
        final pet = PetProfileEntity(
          id: 'test-id',
          name: 'Test Pet',
          type: 'dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          imagePath: 'path/to/image.jpg',
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          isActive: false,
          additionalInfo: {'color': 'golden', 'weight': 25.5},
        );

        // Assert
        expect(pet.id, equals('test-id'));
        expect(pet.name, equals('Test Pet'));
        expect(pet.type, equals('dog'));
        expect(pet.breed, equals('Golden Retriever'));
        expect(pet.birthDate, equals(DateTime(2020, 1, 1)));
        expect(pet.imagePath, equals('path/to/image.jpg'));
        expect(pet.ownerId, equals('owner-123'));
        expect(pet.createdAt, equals(DateTime(2023, 1, 1)));
        expect(pet.updatedAt, equals(DateTime(2023, 1, 1)));
        expect(pet.isActive, isFalse);
        expect(pet.additionalInfo, equals({'color': 'golden', 'weight': 25.5}));
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        // Arrange
        final original = PetProfileEntity(
          id: 'test-id',
          name: 'Original Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Act
        final copy = original.copyWith(
          name: 'Updated Pet',
          breed: 'Golden Retriever',
          isActive: false,
        );

        // Assert
        expect(copy.id, equals('test-id'));
        expect(copy.name, equals('Updated Pet'));
        expect(copy.type, equals('dog'));
        expect(copy.breed, equals('Golden Retriever'));
        expect(copy.birthDate, equals(DateTime(2020, 1, 1)));
        expect(copy.ownerId, equals('owner-123'));
        expect(copy.createdAt, equals(DateTime(2023, 1, 1)));
        expect(copy.updatedAt, equals(DateTime(2023, 1, 1)));
        expect(copy.isActive, isFalse);

        // Original should remain unchanged
        expect(original.name, equals('Original Pet'));
        expect(original.breed, isNull);
        expect(original.isActive, isTrue);
      });

      test('should create identical copy when no values provided', () {
        // Arrange
        final original = PetProfileEntity(
          id: 'test-id',
          name: 'Original Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.id, equals(original.id));
        expect(copy.name, equals(original.name));
        expect(copy.type, equals(original.type));
        expect(copy.birthDate, equals(original.birthDate));
        expect(copy.ownerId, equals(original.ownerId));
        expect(copy.createdAt, equals(original.createdAt));
        expect(copy.updatedAt, equals(original.updatedAt));
        expect(copy.isActive, equals(original.isActive));
      });
    });

    group('age getter', () {
      test('should calculate age correctly for pet born this year', () {
        // Arrange
        final now = DateTime.now();
        final pet = PetProfileEntity(
          id: 'test-id',
          name: 'Young Pet',
          type: 'dog',
          birthDate: DateTime(now.year, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: now,
          updatedAt: now,
        );

        // Act & Assert
        expect(pet.age, isA<int>());
        expect(pet.age, greaterThanOrEqualTo(0));
      });

      test('should calculate age correctly for pet born last year', () {
        // Arrange
        final now = DateTime.now();
        final pet = PetProfileEntity(
          id: 'test-id',
          name: 'One Year Old Pet',
          type: 'dog',
          birthDate: DateTime(now.year - 1, now.month, now.day),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: now,
          updatedAt: now,
        );

        // Act & Assert
        expect(pet.age, equals(1));
      });

      test('should calculate age correctly before birthday', () {
        // Arrange
        final now = DateTime.now();
        final pet = PetProfileEntity(
          id: 'test-id',
          name: 'Pet Before Birthday',
          type: 'dog',
          birthDate: DateTime(
            now.year - 2,
            now.month + 1,
            now.day,
          ), // Birthday next month
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: now,
          updatedAt: now,
        );

        // Act & Assert
        expect(
          pet.age,
          equals(1),
        ); // Should be 1, not 2, since birthday hasn't occurred
      });
    });

    group('typeName getter', () {
      test('should return correct Japanese names for all pet types', () {
        final testCases = {
          'dog': '犬',
          'cat': '猫',
          'bird': '鳥',
          'hamster': 'ハムスター',
          'rabbit': 'うさぎ',
          'turtle': '亀',
          'unknown': 'ペット',
        };

        for (final entry in testCases.entries) {
          final pet = PetProfileEntity(
            id: 'test-id',
            name: 'Test Pet',
            type: entry.key,
            birthDate: DateTime(2020, 1, 1),
            gender: 'male',
            weight: 25.0,
            ownerId: 'owner-123',
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          );

          expect(
            pet.typeName,
            equals(entry.value),
            reason: 'Type ${entry.key} should return ${entry.value}',
          );
        }
      });

      test('should handle case insensitive types', () {
        final pet = PetProfileEntity(
          id: 'test-id',
          name: 'Test Pet',
          type: 'DOG',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        expect(pet.typeName, equals('犬'));
      });
    });

    group('typeIcon getter', () {
      test('should return correct emojis for all pet types', () {
        final testCases = {
          'dog': '🐕',
          'cat': '🐱',
          'bird': '🐦',
          'hamster': '🐹',
          'rabbit': '🐰',
          'turtle': '🐢',
          'unknown': '🐾',
        };

        for (final entry in testCases.entries) {
          final pet = PetProfileEntity(
            id: 'test-id',
            name: 'Test Pet',
            type: entry.key,
            birthDate: DateTime(2020, 1, 1),
            gender: 'male',
            weight: 25.0,
            ownerId: 'owner-123',
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          );

          expect(
            pet.typeIcon,
            equals(entry.value),
            reason: 'Type ${entry.key} should return ${entry.value}',
          );
        }
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields are same', () {
        // Arrange
        final pet1 = PetProfileEntity(
          id: 'same-id',
          name: 'Same Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final pet2 = PetProfileEntity(
          id: 'same-id',
          name: 'Same Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Act & Assert
        expect(pet1, equals(pet2));
        expect(pet1.hashCode, equals(pet2.hashCode));
      });

      test('should not be equal when ids are different', () {
        // Arrange
        final pet1 = PetProfileEntity(
          id: 'id-1',
          name: 'Same Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final pet2 = PetProfileEntity(
          id: 'id-2',
          name: 'Same Pet',
          type: 'dog',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 25.0,
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // Act & Assert
        expect(pet1, isNot(equals(pet2)));
        expect(pet1.hashCode, isNot(equals(pet2.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation with key fields', () {
        // Arrange
        final pet = PetProfileEntity(
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

        // Act
        final stringRepresentation = pet.toString();

        // Assert
        expect(stringRepresentation, contains('test-id'));
        expect(stringRepresentation, contains('Test Pet'));
        expect(stringRepresentation, contains('dog'));
        expect(stringRepresentation, contains('Golden Retriever'));
      });
    });
  });
}
