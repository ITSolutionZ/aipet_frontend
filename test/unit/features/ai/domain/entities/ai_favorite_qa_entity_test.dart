import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart';

void main() {
  group('AiFavoriteQaEntity', () {
    late AiFavoriteQaEntity testFavoriteQa;

    setUp(() {
      testFavoriteQa = AiFavoriteQaEntity(
        id: 'favorite-1',
        question: 'ペットの健康管理について教えて',
        answer: 'ペットの健康管理は定期的な健康診断と適切な食事が重要です。',
        category: 'health',
        petId: 'pet-123',
        petName: 'テストペット',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        updatedAt: DateTime(2024, 1, 2, 12, 0, 0),
        tags: ['健康', '管理', 'アドバイス'],
        isShared: true,
        sharedAt: DateTime(2024, 1, 1, 15, 0, 0),
        sharedWith: ['user-1', 'user-2'],
        metadata: {'source': 'ai_chat', 'confidence': 0.95},
      );
    });

    group('constructor', () {
      test('should create favorite QA with all parameters', () {
        // Act
        final favoriteQa = AiFavoriteQaEntity(
          id: 'test-favorite',
          question: 'テスト質問',
          answer: 'テスト回答',
          category: 'test-category',
          petId: 'test-pet',
          petName: 'テストペット',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          tags: ['タグ1', 'タグ2'],
          isShared: false,
          sharedAt: DateTime(2024, 1, 3),
          sharedWith: ['user1'],
          metadata: {'key': 'value'},
        );

        // Assert
        expect(favoriteQa.id, equals('test-favorite'));
        expect(favoriteQa.question, equals('テスト質問'));
        expect(favoriteQa.answer, equals('テスト回答'));
        expect(favoriteQa.category, equals('test-category'));
        expect(favoriteQa.petId, equals('test-pet'));
        expect(favoriteQa.petName, equals('テストペット'));
        expect(favoriteQa.createdAt, equals(DateTime(2024, 1, 1)));
        expect(favoriteQa.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(favoriteQa.tags, equals(['タグ1', 'タグ2']));
        expect(favoriteQa.isShared, isFalse);
        expect(favoriteQa.sharedAt, equals(DateTime(2024, 1, 3)));
        expect(favoriteQa.sharedWith, equals(['user1']));
        expect(favoriteQa.metadata, equals({'key': 'value'}));
      });

      test('should create favorite QA with required parameters only', () {
        // Act
        final favoriteQa = AiFavoriteQaEntity(
          id: 'simple-favorite',
          question: 'シンプル質問',
          answer: 'シンプル回答',
          category: 'simple-category',
          petId: 'simple-pet',
          petName: 'シンプルペット',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(favoriteQa.id, equals('simple-favorite'));
        expect(favoriteQa.question, equals('シンプル質問'));
        expect(favoriteQa.answer, equals('シンプル回答'));
        expect(favoriteQa.category, equals('simple-category'));
        expect(favoriteQa.petId, equals('simple-pet'));
        expect(favoriteQa.petName, equals('シンプルペット'));
        expect(favoriteQa.createdAt, equals(DateTime(2024, 1, 1)));
        expect(favoriteQa.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(favoriteQa.tags, isNull);
        expect(favoriteQa.isShared, isFalse);
        expect(favoriteQa.sharedAt, isNull);
        expect(favoriteQa.sharedWith, isNull);
        expect(favoriteQa.metadata, isNull);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedFavoriteQa = testFavoriteQa.copyWith(
          question: 'Updated Question',
          isShared: false,
          tags: ['Updated', 'Tags'],
        );

        // Assert
        expect(updatedFavoriteQa.id, equals('favorite-1')); // unchanged
        expect(updatedFavoriteQa.question, equals('Updated Question'));
        expect(
          updatedFavoriteQa.answer,
          equals('ペットの健康管理は定期的な健康診断と適切な食事が重要です。'),
        ); // unchanged
        expect(updatedFavoriteQa.category, equals('health')); // unchanged
        expect(updatedFavoriteQa.petId, equals('pet-123')); // unchanged
        expect(updatedFavoriteQa.petName, equals('テストペット')); // unchanged
        expect(
          updatedFavoriteQa.createdAt,
          equals(DateTime(2024, 1, 1, 12, 0, 0)),
        ); // unchanged
        expect(
          updatedFavoriteQa.updatedAt,
          equals(DateTime(2024, 1, 2, 12, 0, 0)),
        ); // unchanged
        expect(updatedFavoriteQa.tags, equals(['Updated', 'Tags']));
        expect(updatedFavoriteQa.isShared, isFalse);
        expect(
          updatedFavoriteQa.sharedAt,
          equals(DateTime(2024, 1, 1, 15, 0, 0)),
        ); // unchanged
        expect(
          updatedFavoriteQa.sharedWith,
          equals(['user-1', 'user-2']),
        ); // unchanged
        expect(
          updatedFavoriteQa.metadata,
          equals({'source': 'ai_chat', 'confidence': 0.95}),
        ); // unchanged
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedFavoriteQa = testFavoriteQa.copyWith();

        // Assert
        expect(updatedFavoriteQa.id, equals(testFavoriteQa.id));
        expect(updatedFavoriteQa.question, equals(testFavoriteQa.question));
        expect(updatedFavoriteQa.answer, equals(testFavoriteQa.answer));
        expect(updatedFavoriteQa.category, equals(testFavoriteQa.category));
        expect(updatedFavoriteQa.petId, equals(testFavoriteQa.petId));
        expect(updatedFavoriteQa.petName, equals(testFavoriteQa.petName));
        expect(updatedFavoriteQa.createdAt, equals(testFavoriteQa.createdAt));
        expect(updatedFavoriteQa.updatedAt, equals(testFavoriteQa.updatedAt));
        expect(updatedFavoriteQa.tags, equals(testFavoriteQa.tags));
        expect(updatedFavoriteQa.isShared, equals(testFavoriteQa.isShared));
        expect(updatedFavoriteQa.sharedAt, equals(testFavoriteQa.sharedAt));
        expect(updatedFavoriteQa.sharedWith, equals(testFavoriteQa.sharedWith));
        expect(updatedFavoriteQa.metadata, equals(testFavoriteQa.metadata));
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        // Act
        final json = testFavoriteQa.toJson();

        // Assert
        expect(json['id'], equals('favorite-1'));
        expect(json['question'], equals('ペットの健康管理について教えて'));
        expect(json['answer'], equals('ペットの健康管理は定期的な健康診断と適切な食事が重要です。'));
        expect(json['category'], equals('health'));
        expect(json['petId'], equals('pet-123'));
        expect(json['petName'], equals('テストペット'));
        expect(json['createdAt'], equals('2024-01-01T12:00:00.000'));
        expect(json['updatedAt'], equals('2024-01-02T12:00:00.000'));
        expect(json['tags'], equals(['健康', '管理', 'アドバイス']));
        expect(json['isShared'], isTrue);
        expect(json['sharedAt'], equals('2024-01-01T15:00:00.000'));
        expect(json['sharedWith'], equals(['user-1', 'user-2']));
        expect(
          json['metadata'],
          equals({'source': 'ai_chat', 'confidence': 0.95}),
        );
      });

      test('should convert to JSON with null fields', () {
        // Arrange
        final favoriteQaWithNulls = testFavoriteQa.copyWith(
          tags: null,
          sharedAt: null,
          sharedWith: null,
          metadata: null,
        );

        // Act
        final json = favoriteQaWithNulls.toJson();

        // Assert
        expect(json['tags'], isNull);
        expect(json['sharedAt'], isNull);
        expect(json['sharedWith'], isNull);
        expect(json['metadata'], isNull);
      });
    });

    group('fromJson', () {
      test('should create from JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'json-favorite',
          'question': 'JSON質問',
          'answer': 'JSON回答',
          'category': 'json-category',
          'petId': 'json-pet',
          'petName': 'JSONペット',
          'createdAt': '2024-01-01T10:00:00.000',
          'updatedAt': '2024-01-02T10:00:00.000',
          'tags': ['JSON', 'タグ'],
          'isShared': true,
          'sharedAt': '2024-01-01T14:00:00.000',
          'sharedWith': ['json-user'],
          'metadata': {'json': 'data'},
        };

        // Act
        final favoriteQa = AiFavoriteQaEntity.fromJson(json);

        // Assert
        expect(favoriteQa.id, equals('json-favorite'));
        expect(favoriteQa.question, equals('JSON質問'));
        expect(favoriteQa.answer, equals('JSON回答'));
        expect(favoriteQa.category, equals('json-category'));
        expect(favoriteQa.petId, equals('json-pet'));
        expect(favoriteQa.petName, equals('JSONペット'));
        expect(favoriteQa.createdAt, equals(DateTime(2024, 1, 1, 10, 0, 0)));
        expect(favoriteQa.updatedAt, equals(DateTime(2024, 1, 2, 10, 0, 0)));
        expect(favoriteQa.tags, equals(['JSON', 'タグ']));
        expect(favoriteQa.isShared, isTrue);
        expect(favoriteQa.sharedAt, equals(DateTime(2024, 1, 1, 14, 0, 0)));
        expect(favoriteQa.sharedWith, equals(['json-user']));
        expect(favoriteQa.metadata, equals({'json': 'data'}));
      });

      test('should create from JSON with null fields', () {
        // Arrange
        final json = {
          'id': 'null-favorite',
          'question': 'Null質問',
          'answer': 'Null回答',
          'category': 'null-category',
          'petId': 'null-pet',
          'petName': 'Nullペット',
          'createdAt': '2024-01-01T10:00:00.000',
          'updatedAt': '2024-01-02T10:00:00.000',
          'tags': null,
          'isShared': false,
          'sharedAt': null,
          'sharedWith': null,
          'metadata': null,
        };

        // Act
        final favoriteQa = AiFavoriteQaEntity.fromJson(json);

        // Assert
        expect(favoriteQa.tags, isNull);
        expect(favoriteQa.isShared, isFalse);
        expect(favoriteQa.sharedAt, isNull);
        expect(favoriteQa.sharedWith, isNull);
        expect(favoriteQa.metadata, isNull);
      });
    });

    group('utility getters', () {
      test('petGroupKey should return correct key', () {
        // Act
        final groupKey = testFavoriteQa.petGroupKey;

        // Assert
        expect(groupKey, equals('pet-123'));
      });

      test('petDisplayName should return pet name or default', () {
        // Act
        final displayName = testFavoriteQa.petDisplayName;

        // Assert
        expect(displayName, equals('テストペット'));
      });

      test('petDisplayName should return default when petName is null', () {
        // Arrange
        final favoriteQaWithoutPetName = testFavoriteQa.copyWith(petName: null);

        // Act
        final displayName = favoriteQaWithoutPetName.petDisplayName;

        // Assert
        expect(displayName, equals('ペット'));
      });

      test('hasTags should return true when tags exist', () {
        // Assert
        expect(testFavoriteQa.hasTags, isTrue);
      });

      test('hasTags should return false when no tags', () {
        // Arrange
        final favoriteQaWithoutTags = testFavoriteQa.copyWith(tags: null);

        // Act
        final hasTags = favoriteQaWithoutTags.hasTags;

        // Assert
        expect(hasTags, isFalse);
      });

      test('hasTags should return false when empty tags', () {
        // Arrange
        final favoriteQaWithEmptyTags = testFavoriteQa.copyWith(tags: []);

        // Act
        final hasTags = favoriteQaWithEmptyTags.hasTags;

        // Assert
        expect(hasTags, isFalse);
      });

      test('isRecentlyCreated should return true for recent creation', () {
        // Arrange
        final recentFavoriteQa = testFavoriteQa.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final isRecent = recentFavoriteQa.isRecentlyCreated;

        // Assert
        expect(isRecent, isTrue);
      });

      test('isRecentlyCreated should return false for old creation', () {
        // Arrange
        final oldFavoriteQa = testFavoriteQa.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        // Act
        final isRecent = oldFavoriteQa.isRecentlyCreated;

        // Assert
        expect(isRecent, isFalse);
      });

      test('isRecentlyUpdated should return true for recent update', () {
        // Arrange
        final recentlyUpdatedFavoriteQa = testFavoriteQa.copyWith(
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final isRecent = recentlyUpdatedFavoriteQa.isRecentlyUpdated;

        // Assert
        expect(isRecent, isTrue);
      });

      test('isRecentlyUpdated should return false for old update', () {
        // Arrange
        final oldUpdatedFavoriteQa = testFavoriteQa.copyWith(
          updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        // Act
        final isRecent = oldUpdatedFavoriteQa.isRecentlyUpdated;

        // Assert
        expect(isRecent, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle empty question and answer', () {
        // Act
        final emptyFavoriteQa = testFavoriteQa.copyWith(
          question: '',
          answer: '',
        );

        // Assert
        expect(emptyFavoriteQa.question, equals(''));
        expect(emptyFavoriteQa.answer, equals(''));
      });

      test('should handle very long question and answer', () {
        // Arrange
        final longText = 'A' * 1000;

        // Act
        final longFavoriteQa = testFavoriteQa.copyWith(
          question: longText,
          answer: longText,
        );

        // Assert
        expect(longFavoriteQa.question, equals(longText));
        expect(longFavoriteQa.answer, equals(longText));
        expect(longFavoriteQa.question.length, equals(1000));
        expect(longFavoriteQa.answer.length, equals(1000));
      });

      test('should handle special characters in text fields', () {
        // Arrange
        const specialText = 'スペシャル文字: !@#\$%^&*()🎉🚀';

        // Act
        final specialFavoriteQa = testFavoriteQa.copyWith(
          question: specialText,
          answer: specialText,
        );

        // Assert
        expect(specialFavoriteQa.question, equals(specialText));
        expect(specialFavoriteQa.answer, equals(specialText));
      });

      test('should handle many tags', () {
        // Arrange
        final manyTags = List.generate(50, (index) => 'tag$index');

        // Act
        final manyTagsFavoriteQa = testFavoriteQa.copyWith(tags: manyTags);

        // Assert
        expect(manyTagsFavoriteQa.tags, hasLength(50));
        expect(manyTagsFavoriteQa.tags!.first, equals('tag0'));
        expect(manyTagsFavoriteQa.tags!.last, equals('tag49'));
      });

      test('should handle many shared users', () {
        // Arrange
        final manyUsers = List.generate(100, (index) => 'user$index');

        // Act
        final manyUsersFavoriteQa = testFavoriteQa.copyWith(
          sharedWith: manyUsers,
        );

        // Assert
        expect(manyUsersFavoriteQa.sharedWith, hasLength(100));
        expect(manyUsersFavoriteQa.sharedWith!.first, equals('user0'));
        expect(manyUsersFavoriteQa.sharedWith!.last, equals('user99'));
      });

      test('should handle complex metadata', () {
        // Arrange
        final complexMetadata = {
          'nested': {'key': 'value'},
          'list': [1, 2, 3],
          'boolean': true,
          'number': 42.5,
          'nullValue': null,
        };

        // Act
        final complexFavoriteQa = testFavoriteQa.copyWith(
          metadata: complexMetadata,
        );

        // Assert
        expect(complexFavoriteQa.metadata, equals(complexMetadata));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final sameFavoriteQa = AiFavoriteQaEntity(
          id: 'favorite-1',
          question: 'ペットの健康管理について教えて',
          answer: 'ペットの健康管理は定期的な健康診断と適切な食事が重要です。',
          category: 'health',
          petId: 'pet-123',
          petName: 'テストペット',
          createdAt: DateTime(2024, 1, 1, 12, 0, 0),
          updatedAt: DateTime(2024, 1, 2, 12, 0, 0),
          tags: ['健康', '管理', 'アドバイス'],
          isShared: true,
          sharedAt: DateTime(2024, 1, 1, 15, 0, 0),
          sharedWith: ['user-1', 'user-2'],
          metadata: {'source': 'ai_chat', 'confidence': 0.95},
        );

        // Assert
        expect(testFavoriteQa, equals(sameFavoriteQa));
        expect(testFavoriteQa.hashCode, equals(sameFavoriteQa.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentFavoriteQa = testFavoriteQa.copyWith(
          question: 'Different Question',
        );

        // Assert
        expect(testFavoriteQa, isNot(equals(differentFavoriteQa)));
        expect(
          testFavoriteQa.hashCode,
          isNot(equals(differentFavoriteQa.hashCode)),
        );
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testFavoriteQa.toString();

        // Assert
        expect(stringRepresentation, contains('AiFavoriteQaEntity'));
        expect(stringRepresentation, contains('favorite-1'));
        expect(stringRepresentation, contains('ペットの健康管理について教えて'));
      });
    });
  });
}
