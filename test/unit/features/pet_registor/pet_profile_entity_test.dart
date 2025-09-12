import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileEntity', () {
    late PetProfileEntity testPet;

    setUp(() {
      testPet = PetProfileEntity(
        id: '1',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 3, 15),
        imagePath: 'test_image.jpg',
        ownerId: 'user1',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isActive: true,
        additionalInfo: {
          'personality': ['friendly'],
        },
      );
    });

    test('should create pet profile entity with all required fields', () {
      expect(testPet.id, '1');
      expect(testPet.name, 'テストペット');
      expect(testPet.type, 'dog');
      expect(testPet.breed, '柴犬');
      expect(testPet.birthDate, DateTime(2020, 3, 15));
      expect(testPet.imagePath, 'test_image.jpg');
      expect(testPet.ownerId, 'user1');
      expect(testPet.isActive, true);
      expect(testPet.additionalInfo, {
        'personality': ['friendly'],
      });
    });

    test('should calculate age correctly', () {
      final now = DateTime.now();
      final expectedAge = now.year - 2020;

      expect(testPet.age, expectedAge);
    });

    test('should return correct type icon for different pet types', () {
      expect(testPet.typeIcon, '🐕');

      final catPet = testPet.copyWith(type: 'cat');
      expect(catPet.typeIcon, '🐱');

      final birdPet = testPet.copyWith(type: 'bird');
      expect(birdPet.typeIcon, '🐦');
    });

    test('should return correct Japanese type name', () {
      expect(testPet.typeName, '犬');

      final catPet = testPet.copyWith(type: 'cat');
      expect(catPet.typeName, '猫');

      final birdPet = testPet.copyWith(type: 'bird');
      expect(birdPet.typeName, '鳥');

      final hamsterPet = testPet.copyWith(type: 'hamster');
      expect(hamsterPet.typeName, 'ハムスター');

      final rabbitPet = testPet.copyWith(type: 'rabbit');
      expect(rabbitPet.typeName, 'うさぎ');

      final turtlePet = testPet.copyWith(type: 'turtle');
      expect(turtlePet.typeName, '亀');

      final unknownPet = testPet.copyWith(type: 'unknown');
      expect(unknownPet.typeName, 'ペット');
    });

    test('should copy with new values correctly', () {
      final updatedPet = testPet.copyWith(
        name: '新しい名前',
        breed: 'ゴールデンレトリバー',
        isActive: false,
      );

      expect(updatedPet.id, testPet.id);
      expect(updatedPet.name, '新しい名前');
      expect(updatedPet.breed, 'ゴールデンレトリバー');
      expect(updatedPet.isActive, false);
      expect(updatedPet.type, testPet.type);
    });

    test('should implement equality correctly', () {
      final samePet = PetProfileEntity(
        id: '1',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 3, 15),
        imagePath: 'test_image.jpg',
        ownerId: 'user1',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isActive: true,
        additionalInfo: {
          'personality': ['friendly'],
        },
      );

      final differentPet = testPet.copyWith(id: '2');

      expect(testPet, equals(samePet));
      expect(testPet, isNot(equals(differentPet)));
    });

    test('should generate correct hash code', () {
      final samePet = testPet.copyWith();
      final differentPet = testPet.copyWith(id: '2');

      expect(testPet.hashCode, equals(samePet.hashCode));
      expect(testPet.hashCode, isNot(equals(differentPet.hashCode)));
    });

    test('should return correct string representation', () {
      final stringRep = testPet.toString();

      expect(stringRep, contains('PetProfileEntity'));
      expect(stringRep, contains('id: 1'));
      expect(stringRep, contains('name: テストペット'));
      expect(stringRep, contains('type: dog'));
      expect(stringRep, contains('breed: 柴犬'));
    });
  });
}
