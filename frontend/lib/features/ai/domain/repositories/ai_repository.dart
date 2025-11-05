import '../../../../shared/shared.dart';

import '../entities/entities.dart';


/// AI Repository
///
/// AI 관련 추천, 즐겨찾기, 분석 기능을 담당합니다.
/// 채팅 기능은 AiChatRepository로 분리되었습니다.
abstract class AiRepository {
  /// 추천 질문 가져오기
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions();

  /// 펫 정보 기반 맞춤형 추천 질문 가져오기
  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  });

  /// 즐겨찾기 메시지 추가
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  });

  /// 즐겨찾기 메시지 제거
  Future<void> removeFavoriteMessage(String favoriteId);

  /// 즐겨찾기 목록 가져오기
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  });

  /// 즐겨찾기 QA 목록 가져오기
  Future<List<AiFavoriteQaEntity>> getFavoriteQAs();

  /// 메시지 분석 (UseCase에서 사용)
  Future<Result<AiAnalysisEntity>> analyzeMessage({
    required String message,
    String? petId,
    Map<String, dynamic>? context,
  });

  /// 즐겨찾기 토글
  Future<Result<bool>> toggleFavoriteMessage(String messageId);

  /// 파라미터와 함께 제안 질문 가져오기
  Future<Result<List<AiSuggestedQuestionEntity>>>
  getSuggestedQuestionsWithParams({String? petId, String? categoryId});
}
