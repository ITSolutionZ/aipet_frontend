import '../../features/ai/domain/domain.dart';

/// Mock 데이터 서비스 인터페이스
///
/// 실제 API 연계 전까지 사용하는 Mock 데이터를 중앙 관리합니다.
/// API 연계 시점에는 이 인터페이스의 구현만 실제 API 호출로 변경하면 됩니다.
abstract class MockDataService {
  /// API 지연 시뮬레이션
  Future<void> simulateApiDelay({int seconds = 1});

  /// AI 관련 Mock 데이터
  Future<List<AiMessageEntity>> getChatHistory();
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions();
  Future<List<AiFavoriteQaEntity>> getFavoriteQAs();
  Future<List<AiChatSessionEntity>> getChatSessions();

  /// AI 응답 생성
  Future<Map<String, dynamic>> generateAiResponse(String userMessage);

  /// 채팅 세션 생성
  Future<Map<String, dynamic>> createChatSession(String title, {String? petId});
}
