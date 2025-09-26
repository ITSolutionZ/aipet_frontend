import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// ⭐ 즐겨찾기 토글 UseCase
class ToggleFavoriteUseCase {
  final AiRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<Result<void>> call(ToggleFavoriteParams params) async {
    try {
      return await _repository.toggleFavoriteMessage(
        messageId: params.messageId,
        isFavorite: params.isFavorite,
      );
    } catch (e) {
      return ResultFactory.failure('즐겨찾기 설정 중 오류가 발생했습니다: $e');
    }
  }
}

/// ⭐ 즐겨찾기 토글 파라미터
class ToggleFavoriteParams {
  final String messageId;
  final bool isFavorite;

  const ToggleFavoriteParams({
    required this.messageId,
    required this.isFavorite,
  });
}