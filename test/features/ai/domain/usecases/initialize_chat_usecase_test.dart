import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'initialize_chat_usecase_test.mocks.dart';

@GenerateMocks([AiRepository])
void main() {
  group('InitializeChatUseCase', () {
    late InitializeChatUseCase useCase;
    late MockAiRepository mockRepository;

    setUp(() {
      mockRepository = MockAiRepository();
      useCase = InitializeChatUseCase(mockRepository);
    });

    test(
      'should return success when chat is initialized successfully',
      () async {
        // Arrange
        final expectedQuestions = [
          const AiSuggestedQuestionEntity(
            id: '1',
            question: 'ペットの健康について相談したいです',
            category: '健康',
            icon: Icons.health_and_safety,
            description: 'ペットの健康に関する質問',
          ),
        ];

        when(
          mockRepository.getSuggestedQuestions(),
        ).thenAnswer((_) async => expectedQuestions);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, expectedQuestions);
        verify(mockRepository.getSuggestedQuestions()).called(1);
      },
    );

    test('should return failure when repository throws exception', () async {
      // Arrange
      when(
        mockRepository.getSuggestedQuestions(),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('チャット初期化に失敗しました'));
    });

    test('should handle empty suggested questions', () async {
      // Arrange
      when(
        mockRepository.getSuggestedQuestions(),
      ).thenAnswer((_) async => <AiSuggestedQuestionEntity>[]);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isEmpty);
    });
  });
}
