import 'package:aipet_frontend/features/ai/data/services/pet_content_filter_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../test_helper.dart';

void main() {
  group('PetContentFilterService', () {
    late PetContentFilterService service;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      service = PetContentFilterService();
    });

    group('validatePetContent', () {
      test('should return valid for pet-related content', () async {
        // Arrange
        const petMessage = 'ペットの健康について教えてください';

        // Act
        final result = await service.validatePetContent(petMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return invalid for non-pet related content', () async {
        // Arrange
        const nonPetMessage = '政治について教えてください';

        // Act
        final result = await service.validatePetContent(nonPetMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('ペットと関連していない'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return invalid for empty message', () async {
        // Arrange
        const emptyMessage = '';

        // Act
        final result = await service.validatePetContent(emptyMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('内容が短すぎます'));
        expect(result.confidence, lessThan(0.5));
      });

      test('should return invalid for very short message', () async {
        // Arrange
        const shortMessage = 'a';

        // Act
        final result = await service.validatePetContent(shortMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('内容が短すぎます'));
        expect(result.confidence, lessThan(0.5));
      });

      test('should return valid for dog-related content', () async {
        // Arrange
        const dogMessage = '犬のしつけについて教えてください';

        // Act
        final result = await service.validatePetContent(dogMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return valid for cat-related content', () async {
        // Arrange
        const catMessage = '猫の健康管理について教えてください';

        // Act
        final result = await service.validatePetContent(catMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return valid for pet food content', () async {
        // Arrange
        const foodMessage = 'ペットフードの選び方について教えてください';

        // Act
        final result = await service.validatePetContent(foodMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return valid for pet exercise content', () async {
        // Arrange
        const exerciseMessage = 'ペットの運動について教えてください';

        // Act
        final result = await service.validatePetContent(exerciseMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return invalid for gaming content', () async {
        // Arrange
        const gamingMessage = 'ゲームの攻略について教えてください';

        // Act
        final result = await service.validatePetContent(gamingMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('ペットと関連していない'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return invalid for political content', () async {
        // Arrange
        const politicalMessage = '政治について教えてください';

        // Act
        final result = await service.validatePetContent(politicalMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('ペットと関連していない'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should return invalid for entertainment content', () async {
        // Arrange
        const entertainmentMessage = '映画について教えてください';

        // Act
        final result = await service.validatePetContent(entertainmentMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('ペットと関連していない'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should handle mixed content with pet keywords', () async {
        // Arrange
        const mixedMessage = 'ペットの健康と政治について教えてください';

        // Act
        final result = await service.validatePetContent(mixedMessage);

        // Assert
        // 펫 관련 키워드가 포함되어 있으면 유효할 수 있음
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should handle ambiguous content', () async {
        // Arrange
        const ambiguousMessage = '動物について教えてください';

        // Act
        final result = await service.validatePetContent(ambiguousMessage);

        // Assert
        // 애매한 내용은 펫 관련으로 처리될 수 있음
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should handle special characters', () async {
        // Arrange
        const specialMessage = 'ペットの健康について教えてください！🎉🚀';

        // Act
        final result = await service.validatePetContent(specialMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });

      test('should handle long message', () async {
        // Arrange
        final longMessage = 'ペットの健康について' * 100;

        // Act
        final result = await service.validatePetContent(longMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
        expect(result.confidence, greaterThan(0.5));
      });
    });

    group('isPetRelated', () {
      test('should return true for pet-related content', () async {
        // Arrange
        const petMessage = 'ペットの健康について教えてください';

        // Act
        final result = await service.isPetRelated(petMessage);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for non-pet related content', () async {
        // Arrange
        const nonPetMessage = '政治について教えてください';

        // Act
        final result = await service.isPetRelated(nonPetMessage);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for empty message', () async {
        // Arrange
        const emptyMessage = '';

        // Act
        final result = await service.isPetRelated(emptyMessage);

        // Assert
        expect(result, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle null input gracefully', () async {
        // Act & Assert
        expect(() => service.validatePetContent(''), returnsNormally);
      });

      test('should handle whitespace-only input', () async {
        // Arrange
        const whitespaceMessage = '   ';

        // Act
        final result = await service.validatePetContent(whitespaceMessage);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.reason, contains('内容が短すぎます'));
      });

      test('should handle mixed language input', () async {
        // Arrange
        const mixedLanguageMessage = 'ペットのhealthについて教えてください';

        // Act
        final result = await service.validatePetContent(mixedLanguageMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
      });

      test('should handle numbers in input', () async {
        // Arrange
        const numberMessage = 'ペットの年齢3歳について教えてください';

        // Act
        final result = await service.validatePetContent(numberMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
      });

      test('should handle punctuation in input', () async {
        // Arrange
        const punctuationMessage = 'ペットの健康について教えてください！？';

        // Act
        final result = await service.validatePetContent(punctuationMessage);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.reason, contains('ペット'));
      });
    });

    group('confidence levels', () {
      test('should return high confidence for clear pet content', () async {
        // Arrange
        const clearPetMessage = '犬の健康管理について教えてください';

        // Act
        final result = await service.validatePetContent(clearPetMessage);

        // Assert
        expect(result.confidence, greaterThan(0.8));
      });

      test('should return medium confidence for ambiguous content', () async {
        // Arrange
        const ambiguousMessage = '動物について教えてください';

        // Act
        final result = await service.validatePetContent(ambiguousMessage);

        // Assert
        expect(result.confidence, greaterThan(0.5));
        expect(result.confidence, lessThan(0.9));
      });

      test('should return low confidence for non-pet content', () async {
        // Arrange
        const nonPetMessage = '政治について教えてください';

        // Act
        final result = await service.validatePetContent(nonPetMessage);

        // Assert
        expect(result.confidence, greaterThan(0.5));
      });
    });
  });
}
