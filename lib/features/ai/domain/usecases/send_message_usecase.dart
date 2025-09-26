import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// AI 메시지 전송 UseCase
class SendMessageUseCase {
  final AiRepository _repository;

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
        return ResultFactory.failure('メッセージを入力してください');
      }

      if (params.message.length > 2000) {
        return ResultFactory.failure('メッセージは2000文字以内で入力してください');
      }

      // Repository를 통한 메시지 전송
      return await _repository.sendMessageWithParams(
        message: params.message,
        petId: params.petId,
        categoryId: params.categoryId,
        attachedImages: params.attachedImages,
      );
    } catch (error) {
      return ResultFactory.failure('メッセージの送信に失敗しました: ${error.toString()}');
    }
  }

  /// 펫 정보와 함께 메시지 전송
  ///
  /// [message] 사용자가 입력한 메시지
  /// [petContext] 펫 프로필 정보
  ///
  /// Returns: AI 응답 메시지 (펫 정보 포함)
  Future<Result<AiMessageEntity>> callWithPetContext(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    try {
      // 입력 유효성 검사
      if (message.trim().isEmpty) {
        return ResultFactory.failure('メッセージを入力してください');
      }

      if (message.length > 2000) {
        return ResultFactory.failure('メッセージは2000文字以内で入力してください');
      }

      // Repository를 통한 펫 컨텍스트와 함께 메시지 전송
      return await _repository.sendMessageWithPetContext(
        message,
        petContext: petContext,
      );
    } catch (error) {
      return ResultFactory.failure('メッセージの送信に失敗しました: ${error.toString()}');
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
