import 'package:aipet_frontend/features/ai/data/repositories/ai_chat_repository_impl.dart';
import 'package:aipet_frontend/features/ai/data/services/openai_service.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AiChatRepository repository;
  late OpenAIService openAIService;

  setUp(() {
    openAIService = OpenAIService();
    repository = AiChatRepositoryImpl(openAIService: openAIService);
  });

  group('AiChatRepository - 채팅 기록 테스트', () {
    test('채팅 기록을 가져올 수 있다', () async {
      // Act
      final messages = await repository.getChatHistory();

      // Assert
      expect(messages, isA<List<AiMessageEntity>>());
    });

    test('특정 세션의 채팅 기록을 가져올 수 있다', () async {
      // Arrange
      const sessionId = 'test_session_id';

      // Act
      final messages = await repository.getChatHistory(sessionId: sessionId);

      // Assert
      expect(messages, isA<List<AiMessageEntity>>());
    });

    test('채팅 기록을 로드할 수 있다', () async {
      // Arrange
      const userId = 'test_user_id';
      const petId = 'test_pet_id';

      // Act
      final result = await repository.loadChatHistory(
        userId: userId,
        petId: petId,
        limit: 10,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isA<List<AiMessageEntity>>());
    });

    test('채팅 기록을 지울 수 있다', () async {
      // Act & Assert
      expect(() => repository.clearChatHistory(), returnsNormally);
    });
  });

  group('AiChatRepository - 채팅 세션 테스트', () {
    test('채팅 세션 목록을 가져올 수 있다', () async {
      // Act
      final sessions = await repository.getChatSessions();

      // Assert
      expect(sessions, isA<List>());
    });

    test('펫별 채팅 세션을 필터링할 수 있다', () async {
      // Arrange
      const petId = 'test_pet_id';

      // Act
      final sessions = await repository.getChatSessions(petId: petId);

      // Assert
      expect(sessions, isA<List>());
    });

    test('새 채팅 세션을 생성할 수 있다', () async {
      // Arrange
      const title = 'テスト相談';
      const petId = 'test_pet_id';

      // Act
      final session = await repository.createChatSession(title, petId: petId);

      // Assert
      expect(session.id, isNotEmpty);
      expect(session.title, title);
      expect(session.petId, petId);
    });

    test('빈 제목으로 세션 생성 시 예외가 발생한다', () async {
      // Arrange
      const title = '';

      // Act & Assert
      expect(() => repository.createChatSession(title), throwsException);
    });

    test('채팅 세션을 삭제할 수 있다', () async {
      // Arrange
      const sessionId = 'test_session_id';

      // Act & Assert
      expect(() => repository.deleteChatSession(sessionId), returnsNormally);
    });
  });

  group('AiChatRepository - 채팅 요약 테스트', () {
    test('채팅 요약을 생성할 수 있다', () async {
      // Arrange
      final messages = [
        AiMessageEntity(
          id: 'msg1',
          content: 'ペットの健康について',
          type: MessageType.user,
          timestamp: DateTime.now(),
        ),
        AiMessageEntity(
          id: 'msg2',
          content: 'ペットの健康管理について説明します',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        ),
      ];
      const category = 'health';

      // Act
      final summary = await repository.createChatSummary(
        messages,
        category,
        petName: 'Test Pet',
      );

      // Assert
      expect(summary.id, isNotEmpty);
      expect(summary.category, category);
      expect(summary.messages, messages);
    });

    test('채팅 요약 목록을 가져올 수 있다', () async {
      // Act
      final summaries = await repository.getChatSummaries();

      // Assert
      expect(summaries, isA<List>());
    });

    test('AI 요약을 생성할 수 있다', () async {
      // Arrange
      const userMessages = ['ペットの健康について', '散歩の方法は？'];
      const petName = 'Test Pet';
      const category = 'health';

      // Act
      final summary = await repository.generateChatSummary(
        userMessages: userMessages,
        petName: petName,
        category: category,
      );

      // Assert
      expect(summary.title, isNotEmpty);
      expect(summary.content, isNotEmpty);
    });
  });

  group('AiChatRepository - 히스토리 관리 테스트', () {
    test('채팅 히스토리 목록을 가져올 수 있다', () async {
      // Act
      final histories = await repository.getChatHistories(limit: 10);

      // Assert
      expect(histories, isA<List>());
    });

    test('히스토리를 삭제할 수 있다', () async {
      // Arrange
      const historyId = 'test_history_id';

      // Act & Assert
      expect(
        () => repository.deleteChatHistoryById(historyId),
        returnsNormally,
      );
    });
  });
}
