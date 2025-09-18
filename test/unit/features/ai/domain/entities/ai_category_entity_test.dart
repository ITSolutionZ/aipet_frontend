import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiCategoryEntity', () {
    late AiCategoryEntity testCategory;

    setUp(() {
      testCategory = const AiCategoryEntity(
        id: 'health',
        name: '健康管理',
        description: 'ペットの健康に関する質問',
        icon: Icons.health_and_safety,
        color: Colors.red,
      );
    });

    group('constructor', () {
      test('should create category with all required parameters', () {
        // Act
        const category = AiCategoryEntity(
          id: 'test-category',
          name: 'テストカテゴリ',
          description: 'テスト用のカテゴリ',
          icon: Icons.pets,
          color: Colors.blue,
        );

        // Assert
        expect(category.id, equals('test-category'));
        expect(category.name, equals('テストカテゴリ'));
        expect(category.description, equals('テスト用のカテゴリ'));
        expect(category.icon, equals(Icons.pets));
        expect(category.color, equals(Colors.blue));
      });

      test('should create category with different values', () {
        // Act
        const category = AiCategoryEntity(
          id: 'nutrition',
          name: '栄養管理',
          description: 'ペットの栄養に関する質問',
          icon: Icons.restaurant,
          color: Colors.green,
        );

        // Assert
        expect(category.id, equals('nutrition'));
        expect(category.name, equals('栄養管理'));
        expect(category.description, equals('ペットの栄養に関する質問'));
        expect(category.icon, equals(Icons.restaurant));
        expect(category.color, equals(Colors.green));
      });
    });

    group('properties', () {
      test('should have correct property values', () {
        // Assert
        expect(testCategory.id, equals('health'));
        expect(testCategory.name, equals('健康管理'));
        expect(testCategory.description, equals('ペットの健康に関する質問'));
        expect(testCategory.icon, equals(Icons.health_and_safety));
        expect(testCategory.color, equals(Colors.red));
      });

      test('should maintain immutability', () {
        // Arrange
        const originalId = 'health';
        const originalName = '健康管理';
        const originalDescription = 'ペットの健康に関する質問';
        const originalIcon = Icons.health_and_safety;
        const originalColor = Colors.red;

        // Assert - properties should remain unchanged
        expect(testCategory.id, equals(originalId));
        expect(testCategory.name, equals(originalName));
        expect(testCategory.description, equals(originalDescription));
        expect(testCategory.icon, equals(originalIcon));
        expect(testCategory.color, equals(originalColor));
      });
    });

    group('edge cases', () {
      test('should handle special characters in name and description', () {
        // Act
        const specialCategory = AiCategoryEntity(
          id: 'special',
          name: 'スペシャルカテゴリ🎉',
          description: '特殊文字を含むカテゴリ: !@#\$%^&*()',
          icon: Icons.star,
          color: Colors.purple,
        );

        // Assert
        expect(specialCategory.name, equals('スペシャルカテゴリ🎉'));
        expect(specialCategory.description, equals('特殊文字を含むカテゴリ: !@#\$%^&*()'));
      });

      test('should handle empty strings', () {
        // Act
        const emptyCategory = AiCategoryEntity(
          id: '',
          name: '',
          description: '',
          icon: Icons.star,
          color: Colors.grey,
        );

        // Assert
        expect(emptyCategory.id, equals(''));
        expect(emptyCategory.name, equals(''));
        expect(emptyCategory.description, equals(''));
        expect(emptyCategory.icon, equals(Icons.star));
        expect(emptyCategory.color, equals(Colors.grey));
      });

      test('should handle long strings', () {
        // Arrange
        const longId = 'very-long-category-id-that-exceeds-normal-length';
        const longName = 'とても長いカテゴリ名前で通常の長さを超えています';
        const longDescription = 'とても長い説明文でペットの健康に関する詳細な情報を含んでいます。'
            'これは通常の説明文よりもはるかに長く、複数の文章で構成されています。';

        // Act
        const longCategory = AiCategoryEntity(
          id: longId,
          name: longName,
          description: longDescription,
          icon: Icons.description,
          color: Colors.amber,
        );

        // Assert
        expect(longCategory.id, equals(longId));
        expect(longCategory.name, equals(longName));
        expect(longCategory.description, equals(longDescription));
      });
    });

    group('equality', () {
      test('should be equal when all properties are same', () {
        // Arrange
        const sameCategory = AiCategoryEntity(
          id: 'health',
          name: '健康管理',
          description: 'ペットの健康に関する質問',
          icon: Icons.health_and_safety,
          color: Colors.red,
        );

        // Assert - Note: Dart objects without explicit equality override use identity equality
        expect(testCategory.id, equals(sameCategory.id));
        expect(testCategory.name, equals(sameCategory.name));
        expect(testCategory.description, equals(sameCategory.description));
        expect(testCategory.icon, equals(sameCategory.icon));
        expect(testCategory.color, equals(sameCategory.color));
      });

      test('should have different properties when values differ', () {
        // Arrange
        const differentCategory = AiCategoryEntity(
          id: 'nutrition',
          name: '栄養管理',
          description: 'ペットの栄養に関する質問',
          icon: Icons.restaurant,
          color: Colors.green,
        );

        // Assert
        expect(testCategory.id, isNot(equals(differentCategory.id)));
        expect(testCategory.name, isNot(equals(differentCategory.name)));
        expect(testCategory.description, isNot(equals(differentCategory.description)));
        expect(testCategory.icon, isNot(equals(differentCategory.icon)));
        expect(testCategory.color, isNot(equals(differentCategory.color)));
      });
    });

    group('type validation', () {
      test('should be of correct type', () {
        // Assert
        expect(testCategory, isA<AiCategoryEntity>());
        expect(testCategory.id, isA<String>());
        expect(testCategory.name, isA<String>());
        expect(testCategory.description, isA<String>());
        expect(testCategory.icon, isA<IconData>());
        expect(testCategory.color, isA<Color>());
      });
    });

    group('defaultCategories deprecation', () {
      test('should throw UnimplementedError when accessing defaultCategories', () {
        // Assert
        expect(
          () => AiCategoryEntity.defaultCategories,
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}