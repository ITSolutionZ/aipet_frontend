import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiFavoriteQaEntity', () {
    late AiFavoriteQaEntity testFavoriteQa;
    late PetProfileEntity testPet;
    final testDateTime = DateTime(2024, 1, 1, 12, 0);
    final testOriginalTimestamp = DateTime(2024, 1, 1, 10, 0);

    setUp(() {
      testPet = PetProfileEntity(
        id: 'pet-1',
        name: 'テストペット',
        type: 'dog',
        breed: 'ゴールデンレトリバー',
        birthDate: DateTime(2020, 1, 1),
        ownerId: 'owner-1',
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      );

      testFavoriteQa = AiFavoriteQaEntity(
        id: 'fav-qa-1',
        question: '犬の健康について教えて',
        answer: '犬の健康を保つためには...',
        pet: testPet,
        categoryId: 'health',
        categoryName: '健康管理',
        createdAt: testDateTime,
        originalTimestamp: testOriginalTimestamp,
      );
    });

    group('constructor', () {
      test('should create AiFavoriteQaEntity with all parameters', () {
        // Assert
        expect(testFavoriteQa.id, equals('fav-qa-1'));
        expect(testFavoriteQa.question, equals('犬の健康について教えて'));
        expect(testFavoriteQa.answer, equals('犬の健康を保つためには...'));
        expect(testFavoriteQa.pet, equals(testPet));
        expect(testFavoriteQa.categoryId, equals('health'));
        expect(testFavoriteQa.categoryName, equals('健康管理'));
        expect(testFavoriteQa.createdAt, equals(testDateTime));
        expect(testFavoriteQa.originalTimestamp, equals(testOriginalTimestamp));
      });

      test('should create AiFavoriteQaEntity with minimal required parameters', () {
        // Act
        final minimalFavoriteQa = AiFavoriteQaEntity(
          id: 'fav-qa-2',
          question: 'テスト質問',
          answer: 'テスト回答',
          createdAt: testDateTime,
          originalTimestamp: testOriginalTimestamp,
        );

        // Assert
        expect(minimalFavoriteQa.id, equals('fav-qa-2'));
        expect(minimalFavoriteQa.question, equals('テスト質問'));
        expect(minimalFavoriteQa.answer, equals('テスト回答'));
        expect(minimalFavoriteQa.pet, isNull);
        expect(minimalFavoriteQa.categoryId, isNull);
        expect(minimalFavoriteQa.categoryName, isNull);
        expect(minimalFavoriteQa.createdAt, equals(testDateTime));
        expect(minimalFavoriteQa.originalTimestamp, equals(testOriginalTimestamp));
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedFavoriteQa = testFavoriteQa.copyWith(
          question: '更新された質問',
          categoryName: '更新されたカテゴリ',
        );

        // Assert
        expect(updatedFavoriteQa.id, equals('fav-qa-1')); // unchanged
        expect(updatedFavoriteQa.question, equals('更新された質問'));
        expect(updatedFavoriteQa.answer, equals('犬の健康を保つためには...')); // unchanged
        expect(updatedFavoriteQa.pet, equals(testPet)); // unchanged
        expect(updatedFavoriteQa.categoryId, equals('health')); // unchanged
        expect(updatedFavoriteQa.categoryName, equals('更新されたカテゴリ'));
        expect(updatedFavoriteQa.createdAt, equals(testDateTime)); // unchanged
        expect(updatedFavoriteQa.originalTimestamp, equals(testOriginalTimestamp)); // unchanged
      });

      test('should keep original values when no parameters provided', () {
        // Act
        final copiedFavoriteQa = testFavoriteQa.copyWith();

        // Assert
        expect(copiedFavoriteQa.id, equals(testFavoriteQa.id));
        expect(copiedFavoriteQa.question, equals(testFavoriteQa.question));
        expect(copiedFavoriteQa.answer, equals(testFavoriteQa.answer));
        expect(copiedFavoriteQa.pet, equals(testFavoriteQa.pet));
        expect(copiedFavoriteQa.categoryId, equals(testFavoriteQa.categoryId));
        expect(copiedFavoriteQa.categoryName, equals(testFavoriteQa.categoryName));
        expect(copiedFavoriteQa.createdAt, equals(testFavoriteQa.createdAt));
        expect(copiedFavoriteQa.originalTimestamp, equals(testFavoriteQa.originalTimestamp));
      });
    });

    group('petGroupKey', () {
      test('should return pet-based key when pet exists', () {
        // Act
        final groupKey = testFavoriteQa.petGroupKey;

        // Assert
        expect(groupKey, equals('pet-1_テストペット'));
      });

      test('should return general key when pet is null', () {
        // Arrange
        final noPetFavoriteQa = testFavoriteQa.copyWith(pet: null);

        // Act
        final groupKey = noPetFavoriteQa.petGroupKey;

        // Assert
        expect(groupKey, equals('general_一般的なペット相談'));
      });
    });

    group('petDisplayName', () {
      test('should return formatted pet name when pet exists', () {
        // Act
        final displayName = testFavoriteQa.petDisplayName;

        // Assert
        expect(displayName, equals('テストペット (ゴールデンレトリバー)'));
      });

      test('should return general name when pet is null', () {
        // Arrange
        final noPetFavoriteQa = testFavoriteQa.copyWith(pet: null);

        // Act
        final displayName = noPetFavoriteQa.petDisplayName;

        // Assert
        expect(displayName, equals('一般的なペット相談'));
      });

      test('should handle pet without breed', () {
        // Arrange
        final petWithoutBreed = PetProfileEntity(
          id: 'pet-2',
          name: '品種なしペット',
          type: 'cat',
          birthDate: DateTime(2021, 1, 1),
          ownerId: 'owner-1',
          createdAt: DateTime(2021, 1, 1),
          updatedAt: DateTime(2021, 1, 1),
        );
        final favoriteQaWithCat = testFavoriteQa.copyWith(pet: petWithoutBreed);

        // Act
        final displayName = favoriteQaWithCat.petDisplayName;

        // Assert
        expect(displayName, equals('品種なしペット (cat)'));
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        // Act
        final json = testFavoriteQa.toJson();

        // Assert
        expect(json['id'], equals('fav-qa-1'));
        expect(json['question'], equals('犬の健康について教えて'));
        expect(json['answer'], equals('犬の健康を保つためには...'));
        expect(json['petId'], equals('pet-1'));
        expect(json['petName'], equals('テストペット'));
        expect(json['categoryId'], equals('health'));
        expect(json['categoryName'], equals('健康管理'));
        expect(json['createdAt'], equals(testDateTime.toIso8601String()));
        expect(json['originalTimestamp'], equals(testOriginalTimestamp.toIso8601String()));
      });

      test('should handle null pet in JSON conversion', () {
        // Arrange
        final noPetFavoriteQa = testFavoriteQa.copyWith(pet: null);

        // Act
        final json = noPetFavoriteQa.toJson();

        // Assert
        expect(json['petId'], isNull);
        expect(json['petName'], isNull);
      });
    });

    group('fromJson', () {
      test('should create entity from JSON without pet', () {
        // Arrange
        final json = {
          'id': 'fav-qa-2',
          'question': 'JSON質問',
          'answer': 'JSON回答',
          'categoryId': 'nutrition',
          'categoryName': '栄養管理',
          'createdAt': testDateTime.toIso8601String(),
          'originalTimestamp': testOriginalTimestamp.toIso8601String(),
        };

        // Act
        final favoriteQa = AiFavoriteQaEntity.fromJson(json);

        // Assert
        expect(favoriteQa.id, equals('fav-qa-2'));
        expect(favoriteQa.question, equals('JSON質問'));
        expect(favoriteQa.answer, equals('JSON回答'));
        expect(favoriteQa.pet, isNull);
        expect(favoriteQa.categoryId, equals('nutrition'));
        expect(favoriteQa.categoryName, equals('栄養管理'));
        expect(favoriteQa.createdAt, equals(testDateTime));
        expect(favoriteQa.originalTimestamp, equals(testOriginalTimestamp));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when ids are same', () {
        // Arrange
        final sameFavoriteQa = AiFavoriteQaEntity(
          id: 'fav-qa-1', // same id
          question: '異なる質問',
          answer: '異なる回答',
          createdAt: DateTime(2023, 1, 1),
          originalTimestamp: DateTime(2023, 1, 1),
        );

        // Assert
        expect(testFavoriteQa, equals(sameFavoriteQa));
        expect(testFavoriteQa.hashCode, equals(sameFavoriteQa.hashCode));
      });

      test('should not be equal when ids are different', () {
        // Arrange
        final differentFavoriteQa = testFavoriteQa.copyWith(id: 'different-id');

        // Assert
        expect(testFavoriteQa, isNot(equals(differentFavoriteQa)));
        expect(testFavoriteQa.hashCode, isNot(equals(differentFavoriteQa.hashCode)));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testFavoriteQa.toString();

        // Assert
        expect(stringRepresentation, contains('AiFavoriteQaEntity'));
        expect(stringRepresentation, contains('fav-qa-1'));
        expect(stringRepresentation, contains('犬の健康について教えて'));
        expect(stringRepresentation, contains('テストペット'));
      });

      test('should handle long questions in toString', () {
        // Arrange
        const longQuestion = 'とても長い質問で20文字を超える内容を含んでいます。これはどのように表示されるでしょうか？';
        final longQuestionFavoriteQa = testFavoriteQa.copyWith(question: longQuestion);

        // Act
        final stringRepresentation = longQuestionFavoriteQa.toString();

        // Assert
        expect(stringRepresentation, contains('AiFavoriteQaEntity'));
        expect(stringRepresentation, contains('とても長い質問で20文字を超える内容を含んでい'));
        expect(stringRepresentation, contains('...'));
      });
    });
  });
}