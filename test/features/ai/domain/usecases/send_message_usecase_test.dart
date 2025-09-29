import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'send_message_usecase_test.mocks.dart';

@GenerateMocks([AiRepository])
void main() {
  group('SendMessageUseCase', () {
    late SendMessageUseCase useCase;
    late MockAiRepository mockRepository;

    setUp(() {
      mockRepository = MockAiRepository();
      useCase = SendMessageUseCase(mockRepository);
    });

    test('should return success when message is sent successfully', () async {
      // Arrange
      const userMessage = 'ペットの健康について相談したいです';
      final expectedResponse = AiMessageEntity(
        id: 'msg_123',
        content: 'ペットの健康管理についてお手伝いできます。具体的な症状を教えてください。',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      when(mockRepository.sendMessage(userMessage)).thenAnswer(
        (_) async => ResultFactory.success(expectedResponse, 'メッセージを送信しました'),
      );

      // Act
      final result = await useCase.call(userMessage);

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, expectedResponse);
      verify(mockRepository.sendMessage(userMessage)).called(1);
    });

    test(
      'should return success when message is sent with pet context',
      () async {
        // Arrange
        const userMessage = '散歩について相談したいです';
        final petContext = PetProfileEntity(
          id: 'pet_1',
          name: 'ポチ',
          type: PetType.dog,
          breed: '柴犬',
          age: 3,
          birthDate: DateTime(2021, 1, 1),
          createdAt: DateTime.now(),
        );

        final expectedResponse = AiMessageEntity(
          id: 'msg_124',
          content: 'ポチの散歩についてお手伝いできます。柴犬の特性を考慮したアドバイスを提供します。',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
          petId: 'pet_1',
          petName: 'ポチ',
        );

        when(
          mockRepository.sendMessageWithPetContext(
            userMessage,
            petContext: petContext,
          ),
        ).thenAnswer(
          (_) async =>
              ResultFactory.success(expectedResponse, 'ペット情報を含むメッセージを送信しました'),
        );

        // Act
        final result = await useCase.call(userMessage, petContext: petContext);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, expectedResponse);
        expect(result.dataOrNull?.petId, 'pet_1');
        expect(result.dataOrNull?.petName, 'ポチ');
        verify(
          mockRepository.sendMessageWithPetContext(
            userMessage,
            petContext: petContext,
          ),
        ).called(1);
      },
    );

    test('should return failure when repository throws exception', () async {
      // Arrange
      const userMessage = 'テストメッセージ';
      when(
        mockRepository.sendMessage(userMessage),
      ).thenThrow(Exception('API connection failed'));

      // Act
      final result = await useCase.call(userMessage);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('メッセージの送信に失敗しました'));
    });

    test('should handle empty message', () async {
      // Arrange
      const userMessage = '';
      when(mockRepository.sendMessage(userMessage)).thenAnswer(
        (_) async => ResultFactory.failure<AiMessageEntity>('メッセージが空です'),
      );

      // Act
      final result = await useCase.call(userMessage);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, 'メッセージが空です');
    });
  });
}
