import '../../../../shared/shared.dart';

import '../entities/ai_message_entity.dart';
import '../repositories/ai_chat_repository.dart';


/// AI 메시지 전송 UseCase
class SendMessageUseCase {
  final AiChatRepository _repository;

  const SendMessageUseCase(this._repository);

  /// 일반 메시지 전송
  ///
  /// [message] 사용자가 입력한 메시지
  ///
  /// Returns: AI 응답 메시지
  Future<Result<AiMessageEntity>> call(SendMessageParams params) async {
    try {
      // 입력 유효성 검사
      if (params.message.trim().isEmpty) {
        return Result.failure('メッセージを入力してください');
      }

      if (params.message.length > 2000) {
        return Result.failure('メッセージは2000文字以内で入力してください');
      }

      // Repository를 통한 메시지 전송
      return await _repository.sendMessage(
        message: params.message,
        sessionId: 'default_session', // TODO: 실제 세션 ID 전달
        petId: params.petId,
        categoryId: params.categoryId,
        attachedImages: params.attachedImages,
      );
    } catch (error) {
      return Result.failure('メッセージの送信に失敗しました: ${error.toString()}');
    }
  }

  /// 펫 정보와 함께 메시지 전송
  ///
  /// [message] 사용자가 입력한 메시지
  /// [petContext] 펫 프로필 정보
  /// [weatherAdvice] 날씨 어드바이스
  /// [walkGuide] 산책 가이드
  ///
  /// Returns: AI 응답 메시지 (펫 정보 포함)
  Future<Result<AiMessageEntity>> callWithPetContext(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
  }) async {
    try {
      // 입력 유효성 검사
      if (message.trim().isEmpty) {
        return Result.failure('メッセージを入力してください');
      }

      if (message.length > 2000) {
        return Result.failure('メッセージは2000文字以内で入力してください');
      }

      // Repository를 통한 펫 컨텍스트와 함께 메시지 전송
      return await _repository.sendMessageWithPetContext(
        message,
        petContext: petContext,
        weatherAdvice: weatherAdvice,
        walkGuide: walkGuide,
      );
    } catch (error) {
      return Result.failure('メッセージの送信に失敗しました: ${error.toString()}');
    }
  }
}

/// 📤 메시지 전송 파라미터
class SendMessageParams {
  final String message;
  final String petId;
  final String? categoryId;
  final List<String> attachedImages;

  const SendMessageParams({
    required this.message,
    required this.petId,
    this.categoryId,
    this.attachedImages = const [],
  });
}
