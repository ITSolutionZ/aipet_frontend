import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/ai/domain/entities/ai_category_entity.dart';

void main() {
  group('AiCategoryEntity', () {
    late AiCategoryEntity testCategory;

    setUp(() {
      testCategory = AiCategoryEntity(
        id: 'health',
        name: '健康管理',
        description: 'ペットの健康に関する質問',
        icon: Icons.health_and_safety,
        color: Colors.red,
        order: 1,
        isActive: true,
        keywords: ['健康', '病気', '症状', '治療'],
        subcategories: [
          AiCategoryEntity(
            id: 'vaccination',
            name: 'ワクチン',
            description: 'ワクチン接種に関する質問',
            icon: Icons.vaccines,
            color: Colors.orange,
            order: 1,
            isActive: true,
            keywords: ['ワクチン', '接種', '予防'],
          ),
        ],
      );
    });

    group('constructor', () {
      test('should create category with all parameters', () {
        // Act
        final category = AiCategoryEntity(
          id: 'test-category',
          name: 'テストカテゴリ',
          description: 'テスト用のカテゴリ',
          icon: Icons.pets,
          color: Colors.blue,
          order: 5,
          isActive: true,
          keywords: ['テスト', 'カテゴリ'],
          subcategories: [],
        );

        // Assert
        expect(category.id, equals('test-category'));
        expect(category.name, equals('テストカテゴリ'));
        expect(category.description, equals('テスト用のカテゴリ'));
        expect(category.icon, equals(Icons.pets));
        expect(category.color, equals(Colors.blue));
        expect(category.order, equals(5));
        expect(category.isActive, isTrue);
        expect(category.keywords, equals(['テスト', 'カテゴリ']));
        expect(category.subcategories, isEmpty);
      });

      test('should create category with required parameters only', () {
        // Act
        final category = AiCategoryEntity(
          id: 'simple-category',
          name: 'シンプルカテゴリ',
          description: 'シンプルなカテゴリ',
          icon: Icons.star,
          color: Colors.green,
          order: 1,
          isActive: true,
        );

        // Assert
        expect(category.id, equals('simple-category'));
        expect(category.name, equals('シンプルカテゴリ'));
        expect(category.description, equals('シンプルなカテゴリ'));
        expect(category.icon, equals(Icons.star));
        expect(category.color, equals(Colors.green));
        expect(category.order, equals(1));
        expect(category.isActive, isTrue);
        expect(category.keywords, isNull);
        expect(category.subcategories, isNull);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedCategory = testCategory.copyWith(
          name: 'Updated Name',
          isActive: false,
        );

        // Assert
        expect(updatedCategory.id, equals('health')); // unchanged
        expect(updatedCategory.name, equals('Updated Name'));
        expect(
          updatedCategory.description,
          equals('ペットの健康に関する質問'),
        ); // unchanged
        expect(
          updatedCategory.icon,
          equals(Icons.health_and_safety),
        ); // unchanged
        expect(updatedCategory.color, equals(Colors.red)); // unchanged
        expect(updatedCategory.order, equals(1)); // unchanged
        expect(updatedCategory.isActive, isFalse);
        expect(
          updatedCategory.keywords,
          equals(['健康', '病気', '症状', '治療']),
        ); // unchanged
        expect(updatedCategory.subcategories, isNotNull); // unchanged
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedCategory = testCategory.copyWith();

        // Assert
        expect(updatedCategory.id, equals(testCategory.id));
        expect(updatedCategory.name, equals(testCategory.name));
        expect(updatedCategory.description, equals(testCategory.description));
        expect(updatedCategory.icon, equals(testCategory.icon));
        expect(updatedCategory.color, equals(testCategory.color));
        expect(updatedCategory.order, equals(testCategory.order));
        expect(updatedCategory.isActive, equals(testCategory.isActive));
        expect(updatedCategory.keywords, equals(testCategory.keywords));
        expect(
          updatedCategory.subcategories,
          equals(testCategory.subcategories),
        );
      });
    });

    group('hasSubcategories', () {
      test('should return true when subcategories exist', () {
        // Assert
        expect(testCategory.hasSubcategories, isTrue);
      });

      test('should return false when no subcategories', () {
        // Arrange
        final categoryWithoutSubs = testCategory.copyWith(subcategories: []);

        // Assert
        expect(categoryWithoutSubs.hasSubcategories, isFalse);
      });

      test('should return false when subcategories is null', () {
        // Arrange
        final categoryWithoutSubs = testCategory.copyWith(subcategories: null);

        // Assert
        expect(categoryWithoutSubs.hasSubcategories, isFalse);
      });
    });

    group('subcategoryCount', () {
      test('should return correct count when subcategories exist', () {
        // Assert
        expect(testCategory.subcategoryCount, equals(1));
      });

      test('should return zero when no subcategories', () {
        // Arrange
        final categoryWithoutSubs = testCategory.copyWith(subcategories: []);

        // Assert
        expect(categoryWithoutSubs.subcategoryCount, equals(0));
      });

      test('should return zero when subcategories is null', () {
        // Arrange
        final categoryWithoutSubs = testCategory.copyWith(subcategories: null);

        // Assert
        expect(categoryWithoutSubs.subcategoryCount, equals(0));
      });
    });

    group('activeSubcategories', () {
      test('should return only active subcategories', () {
        // Arrange
        final categoryWithMixedSubs = testCategory.copyWith(
          subcategories: [
            AiCategoryEntity(
              id: 'active-sub',
              name: 'Active Sub',
              description: 'Active subcategory',
              icon: Icons.star,
              color: Colors.blue,
              order: 1,
              isActive: true,
            ),
            AiCategoryEntity(
              id: 'inactive-sub',
              name: 'Inactive Sub',
              description: 'Inactive subcategory',
              icon: Icons.star,
              color: Colors.red,
              order: 2,
              isActive: false,
            ),
          ],
        );

        // Act
        final activeSubs = categoryWithMixedSubs.activeSubcategories;

        // Assert
        expect(activeSubs, hasLength(1));
        expect(activeSubs.first.id, equals('active-sub'));
      });

      test('should return empty list when no active subcategories', () {
        // Arrange
        final categoryWithInactiveSubs = testCategory.copyWith(
          subcategories: [
            AiCategoryEntity(
              id: 'inactive-sub',
              name: 'Inactive Sub',
              description: 'Inactive subcategory',
              icon: Icons.star,
              color: Colors.red,
              order: 1,
              isActive: false,
            ),
          ],
        );

        // Act
        final activeSubs = categoryWithInactiveSubs.activeSubcategories;

        // Assert
        expect(activeSubs, isEmpty);
      });
    });

    group('edge cases', () {
      test('should handle empty keywords list', () {
        // Act
        final categoryWithEmptyKeywords = testCategory.copyWith(keywords: []);

        // Assert
        expect(categoryWithEmptyKeywords.keywords, isEmpty);
      });

      test('should handle many keywords', () {
        // Arrange
        final manyKeywords = List.generate(100, (index) => 'keyword$index');

        // Act
        final categoryWithManyKeywords = testCategory.copyWith(
          keywords: manyKeywords,
        );

        // Assert
        expect(categoryWithManyKeywords.keywords, hasLength(100));
        expect(categoryWithManyKeywords.keywords!.first, equals('keyword0'));
        expect(categoryWithManyKeywords.keywords!.last, equals('keyword99'));
      });

      test('should handle special characters in name and description', () {
        // Act
        final specialCategory = AiCategoryEntity(
          id: 'special',
          name: 'スペシャルカテゴリ🎉',
          description: '特殊文字を含むカテゴリ: !@#\$%^&*()',
          icon: Icons.star,
          color: Colors.purple,
          order: 1,
          isActive: true,
        );

        // Assert
        expect(specialCategory.name, equals('スペシャルカテゴリ🎉'));
        expect(specialCategory.description, equals('特殊文字を含むカテゴリ: !@#\$%^&*()'));
      });

      test('should handle negative order', () {
        // Act
        final negativeOrderCategory = testCategory.copyWith(order: -1);

        // Assert
        expect(negativeOrderCategory.order, equals(-1));
      });

      test('should handle zero order', () {
        // Act
        final zeroOrderCategory = testCategory.copyWith(order: 0);

        // Assert
        expect(zeroOrderCategory.order, equals(0));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final sameCategory = AiCategoryEntity(
          id: 'health',
          name: '健康管理',
          description: 'ペットの健康に関する質問',
          icon: Icons.health_and_safety,
          color: Colors.red,
          order: 1,
          isActive: true,
          keywords: ['健康', '病気', '症状', '治療'],
        );

        // Assert
        expect(testCategory, equals(sameCategory));
        expect(testCategory.hashCode, equals(sameCategory.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentCategory = testCategory.copyWith(name: 'Different Name');

        // Assert
        expect(testCategory, isNot(equals(differentCategory)));
        expect(
          testCategory.hashCode,
          isNot(equals(differentCategory.hashCode)),
        );
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testCategory.toString();

        // Assert
        expect(stringRepresentation, contains('AiCategoryEntity'));
        expect(stringRepresentation, contains('health'));
        expect(stringRepresentation, contains('健康管理'));
      });
    });
  });
}
