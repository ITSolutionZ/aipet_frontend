import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/core/base_usecase.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 📜 채팅 히스토리 로드 UseCase
class LoadChatHistoryUseCase extends BaseUseCase<List<AiMessageEntity>, LoadChatHistoryParams> {
  final AiRepository _repository;

  LoadChatHistoryUseCase(this._repository);

  @override
  Future<Result<List<AiMessageEntity>>> execute(LoadChatHistoryParams params) async {
    return await _repository.loadChatHistory(
      userId: params.userId,
      petId: params.petId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// 📜 채팅 히스토리 로드 파라미터
class LoadChatHistoryParams {
  final String userId;
  final String? petId;
  final int? limit;
  final int? offset;

  const LoadChatHistoryParams({
    required this.userId,
    this.petId,
    this.limit,
    this.offset,
  });
}