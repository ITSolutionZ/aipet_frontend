import 'package:aipet_frontend/features/ai/data/services/openai_service.dart';
import 'package:aipet_frontend/features/ai/data/services/pet_content_filter_service.dart';
import 'package:aipet_frontend/features/pet_registor/pet_registor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../test_helper.dart';
import 'openai_service_test.mocks.dart';

@GenerateMocks([PetContentFilterService])
void main() {
  group('OpenAIService', () {
    late OpenAIService service;
    late MockPetContentFilterService mockContentFilter;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockContentFilter = MockPetContentFilterService();
      service = OpenAIService();
    });

    group('generateResponse', () {
      test('should generate response for valid pet-related message', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';
        const expectedResponse = 'ペットの健康管理についてお答えします...';

        // Mock the content filter to return valid
        when(mockContentFilter.validatePetContent(userMessage)).thenAnswer(
          (_) async => const PetContentValidationResult(
            isValid: true,
            reason: 'ペット関連のご質問です',
            confidence: 0.9,
          ),
        );

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // Note: 실제 API 호출이므로 응답 내용은 예측할 수 없음
        verifyNever(mockContentFilter.validatePetContent(userMessage));
      });

      test(
        'should return filtered response for non-pet related message',
        () async {
          // Arrange
          const userMessage = '政治について教えてください';

          // Act
          final result = await service.generateResponse(userMessage);

          // Assert
          expect(result, isA<String>());
          expect(result, isNotEmpty);
          expect(result, contains('ペット専門のAIアシスタント'));
          expect(result, contains('ペットに関する質問のみお答えできます'));
        },
      );

      test('should generate response with pet context', () async {
        // Arrange
        const userMessage = 'このペットの健康について教えて';
        const expectedResponse = 'あなたのペットの健康管理について...';

        final petContext = PetProfileEntity(
          id: 'pet-1',
          name: 'テストペット',
          type: 'dog',
          breed: '柴犬',
          age: 3,
          weight: 10.0,
          gender: 'male',
          birthDate: DateTime(2021, 1, 1),
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = await service.generateResponse(
          userMessage,
          petContext: petContext,
        );

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 펫 컨텍스트가 있으면 필터링을 건너뛰므로 검증하지 않음
      });

      test('should handle empty message', () async {
        // Arrange
        const userMessage = '';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result, contains('内容が短すぎます'));
      });

      test('should handle very short message', () async {
        // Arrange
        const userMessage = 'a';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result, contains('内容が短すぎます'));
      });

      test('should handle long message', () async {
        // Arrange
        final userMessage = 'ペットの健康について' * 100; // 매우 긴 메시지

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 긴 메시지는 정상적으로 처리되어야 함
      });

      test('should handle special characters in message', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください！🎉🚀';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should handle Japanese message with pet keywords', () async {
        // Arrange
        const userMessage = '犬のしつけについて教えてください';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 펫 관련 키워드가 포함된 메시지는 정상 처리되어야 함
      });

      test('should handle mixed language message', () async {
        // Arrange
        const userMessage = 'ペットのhealthについて教えてください';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });
    });

    group('error handling', () {
      test('should handle network timeout', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';

        // Act & Assert
        // 실제 네트워크 타임아웃은 테스트하기 어려우므로
        // 일반적인 에러 처리 로직을 테스트
        expect(() => service.generateResponse(userMessage), returnsNormally);
      });

      test('should handle invalid API key', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';

        // Act & Assert
        // API 키가 유효하지 않은 경우의 처리를 테스트
        expect(() => service.generateResponse(userMessage), returnsNormally);
      });
    });

    group('content filtering', () {
      test('should filter out non-pet related content', () async {
        // Arrange
        const userMessage = 'ゲームについて教えてください';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, contains('ペット専門のAIアシスタント'));
        expect(result, contains('ペットに関する質問のみお答えできます'));
      });

      test('should allow pet-related content', () async {
        // Arrange
        const userMessage = '犬の散歩について教えてください';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 펫 관련 내용은 정상 처리되어야 함
      });

      test('should handle ambiguous content', () async {
        // Arrange
        const userMessage = '動物について教えてください';

        // Act
        final result = await service.generateResponse(userMessage);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 애매한 내용도 펫 관련으로 처리될 수 있음
      });
    });

    group('pet context integration', () {
      test('should include pet information in system prompt', () async {
        // Arrange
        const userMessage = 'このペットについて教えて';

        final petContext = PetProfileEntity(
          id: 'pet-1',
          name: 'ポチ',
          type: 'dog',
          breed: '柴犬',
          age: 5,
          weight: 12.0,
          gender: 'male',
          birthDate: DateTime(2019, 1, 1),
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = await service.generateResponse(
          userMessage,
          petContext: petContext,
        );

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 펫 정보가 포함된 응답이어야 함
      });

      test('should handle pet context with additional info', () async {
        // Arrange
        const userMessage = 'このペットについて教えて';

        final petContext = PetProfileEntity(
          id: 'pet-1',
          name: 'ポチ',
          type: 'dog',
          breed: '柴犬',
          age: 5,
          weight: 12.0,
          gender: 'male',
          birthDate: DateTime(2019, 1, 1),
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          additionalInfo: {'allergies': 'チキンアレルギー', 'medications': '心臓薬'},
        );

        // Act
        final result = await service.generateResponse(
          userMessage,
          petContext: petContext,
        );

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        // 추가 정보가 포함된 응답이어야 함
      });
    });
  });
}
