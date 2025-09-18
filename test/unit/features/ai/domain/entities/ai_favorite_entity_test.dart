import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';

void main() {
  group('AiFavoriteEntity', () {
    late AiFavoriteEntity testFavorite;
    late AiMessageEntity testMessage;

    setUp(() {
      testMessage = AiMessageEntity(
        id: 'msg-1',
        content: 'ペットの健康について教えて',
        type: MessageType.assistant,
        timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        petId: 'pet-123',
        petName: 'テストペット',
      );

      testFavorite = AiFavoriteEntity(
        id: 'favorite-1',
        message: testMessage,
        petId: 'pet-123',
        petName: 'テストペット',
        category: 'health',
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        updatedAt: DateTime(2024, 1, 2, 10, 0, 0),
        userNote: '重要なアドバイス',
      );
    });

    group('constructor', () {
      test('should create favorite with all parameters', () {
        // Act
        final favorite = AiFavoriteEntity(
          id: 'test-favorite',
          message: testMessage,
          petId: 'test-pet',
          petName: 'テストペット',
          category: 'test-category',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          userNote: 'テストノート',
        );

        // Assert
        expect(favorite.id, equals('test-favorite'));
        expect(favorite.message, equals(testMessage));
        expect(favorite.petId, equals('test-pet'));
        expect(favorite.petName, equals('テストペット'));
        expect(favorite.category, equals('test-category'));
        expect(favorite.createdAt, equals(DateTime(2024, 1, 1)));
        expect(favorite.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(favorite.userNote, equals('テストノート'));
      });

      test('should create favorite with required parameters only', () {
        // Act
        final favorite = AiFavoriteEntity(
          id: 'simple-favorite',
          message: testMessage,
          category: 'simple-category',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(favorite.id, equals('simple-favorite'));
        expect(favorite.message, equals(testMessage));
        expect(favorite.petId, isNull);
        expect(favorite.petName, isNull);
        expect(favorite.category, equals('simple-category'));
        expect(favorite.createdAt, equals(DateTime(2024, 1, 1)));
        expect(favorite.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(favorite.userNote, isNull);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedFavorite = testFavorite.copyWith(
          category: 'Updated Category',
          userNote: 'Updated Note',
        );

        // Assert
        expect(updatedFavorite.id, equals('favorite-1')); // unchanged
        expect(updatedFavorite.message, equals(testMessage)); // unchanged
        expect(updatedFavorite.petId, equals('pet-123')); // unchanged
        expect(updatedFavorite.petName, equals('テストペット')); // unchanged
        expect(updatedFavorite.category, equals('Updated Category'));
        expect(
          updatedFavorite.createdAt,
          equals(DateTime(2024, 1, 1, 10, 0, 0)),
        ); // unchanged
        expect(
          updatedFavorite.updatedAt,
          equals(DateTime(2024, 1, 2, 10, 0, 0)),
        ); // unchanged
        expect(updatedFavorite.userNote, equals('Updated Note'));
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedFavorite = testFavorite.copyWith();

        // Assert
        expect(updatedFavorite.id, equals(testFavorite.id));
        expect(updatedFavorite.message, equals(testFavorite.message));
        expect(updatedFavorite.petId, equals(testFavorite.petId));
        expect(updatedFavorite.petName, equals(testFavorite.petName));
        expect(updatedFavorite.category, equals(testFavorite.category));
        expect(updatedFavorite.createdAt, equals(testFavorite.createdAt));
        expect(updatedFavorite.updatedAt, equals(testFavorite.updatedAt));
        expect(updatedFavorite.userNote, equals(testFavorite.userNote));
      });
    });

    group('edge cases', () {
      test('should handle empty category and userNote', () {
        // Act
        final emptyFavorite = testFavorite.copyWith(category: '', userNote: '');

        // Assert
        expect(emptyFavorite.category, equals(''));
        expect(emptyFavorite.userNote, equals(''));
      });

      test('should handle very long category and userNote', () {
        // Arrange
        final longText = 'A' * 1000;

        // Act
        final longFavorite = testFavorite.copyWith(
          category: longText,
          userNote: longText,
        );

        // Assert
        expect(longFavorite.category, equals(longText));
        expect(longFavorite.userNote, equals(longText));
        expect(longFavorite.category.length, equals(1000));
        expect(longFavorite.userNote!.length, equals(1000));
      });

      test('should handle special characters in category and userNote', () {
        // Arrange
        const specialText = 'スペシャル文字: !@#\$%^&*()🎉🚀';

        // Act
        final specialFavorite = testFavorite.copyWith(
          category: specialText,
          userNote: specialText,
        );

        // Assert
        expect(specialFavorite.category, equals(specialText));
        expect(specialFavorite.userNote, equals(specialText));
      });

      test('should handle null petId and petName', () {
        // Act
        final nullPetFavorite = testFavorite.copyWith(
          petId: null,
          petName: null,
        );

        // Assert
        expect(nullPetFavorite.petId, isNull);
        expect(nullPetFavorite.petName, isNull);
      });

      test('should handle null userNote', () {
        // Act
        final nullNoteFavorite = testFavorite.copyWith(userNote: null);

        // Assert
        expect(nullNoteFavorite.userNote, isNull);
      });

      test('should handle different message types', () {
        // Arrange
        final userMessage = AiMessageEntity(
          id: 'user-msg',
          content: 'ユーザーメッセージ',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        );

        final systemMessage = AiMessageEntity(
          id: 'system-msg',
          content: 'システムメッセージ',
          type: MessageType.system,
          timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        );

        // Act
        final userFavorite = testFavorite.copyWith(message: userMessage);
        final systemFavorite = testFavorite.copyWith(message: systemMessage);

        // Assert
        expect(userFavorite.message.type, equals(MessageType.user));
        expect(systemFavorite.message.type, equals(MessageType.system));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when IDs are same', () {
        // Arrange
        final sameIdFavorite = testFavorite.copyWith(
          category: 'Different Category',
          userNote: 'Different Note',
        );

        // Assert
        expect(testFavorite, equals(sameIdFavorite));
        expect(testFavorite.hashCode, equals(sameIdFavorite.hashCode));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final differentIdFavorite = testFavorite.copyWith(id: 'different-id');

        // Assert
        expect(testFavorite, isNot(equals(differentIdFavorite)));
        expect(
          testFavorite.hashCode,
          isNot(equals(differentIdFavorite.hashCode)),
        );
      });

      test('should be equal to itself', () {
        // Assert
        expect(testFavorite, equals(testFavorite));
        expect(testFavorite.hashCode, equals(testFavorite.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testFavorite.toString();

        // Assert
        expect(stringRepresentation, contains('AiFavoriteEntity'));
        expect(stringRepresentation, contains('favorite-1'));
        expect(stringRepresentation, contains('health'));
      });
    });

    group('message relationship', () {
      test('should maintain reference to original message', () {
        // Act
        final updatedFavorite = testFavorite.copyWith(
          category: 'Updated Category',
        );

        // Assert
        expect(updatedFavorite.message, same(testMessage));
        expect(updatedFavorite.message.id, equals('msg-1'));
        expect(updatedFavorite.message.content, equals('ペットの健康について教えて'));
      });

      test('should allow message replacement', () {
        // Arrange
        final newMessage = AiMessageEntity(
          id: 'new-msg',
          content: '新しいメッセージ',
          type: MessageType.assistant,
          timestamp: DateTime(2024, 1, 2, 10, 0, 0),
        );

        // Act
        final updatedFavorite = testFavorite.copyWith(message: newMessage);

        // Assert
        expect(updatedFavorite.message, equals(newMessage));
        expect(updatedFavorite.message.id, equals('new-msg'));
        expect(updatedFavorite.message.content, equals('新しいメッセージ'));
      });
    });

    group('timestamps', () {
      test('should handle same creation and update time', () {
        // Arrange
        final sameTime = DateTime(2024, 1, 1, 12, 0, 0);

        // Act
        final sameTimeFavorite = testFavorite.copyWith(
          createdAt: sameTime,
          updatedAt: sameTime,
        );

        // Assert
        expect(sameTimeFavorite.createdAt, equals(sameTime));
        expect(sameTimeFavorite.updatedAt, equals(sameTime));
      });

      test('should handle future timestamps', () {
        // Arrange
        final futureTime = DateTime(2030, 1, 1, 12, 0, 0);

        // Act
        final futureFavorite = testFavorite.copyWith(
          createdAt: futureTime,
          updatedAt: futureTime,
        );

        // Assert
        expect(futureFavorite.createdAt, equals(futureTime));
        expect(futureFavorite.updatedAt, equals(futureTime));
      });

      test('should handle past timestamps', () {
        // Arrange
        final pastTime = DateTime(2020, 1, 1, 12, 0, 0);

        // Act
        final pastFavorite = testFavorite.copyWith(
          createdAt: pastTime,
          updatedAt: pastTime,
        );

        // Assert
        expect(pastFavorite.createdAt, equals(pastTime));
        expect(pastFavorite.updatedAt, equals(pastTime));
      });
    });
  });
}
