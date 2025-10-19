import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// ⭐ 즐겨찾기 토글 UseCase
class ToggleFavoriteUseCase {
  final AiRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<Result<void>> call(ToggleFavoriteParams params) async {
    try {
      final result = await _repository.toggleFavoriteMessage(params.messageId);
      if (result.isSuccess) {
        return Result.success('お気に入りを設定しました', null);
      } else {
        return Result.failure('お気に入りの設定に失敗しました');
      }
    } catch (e) {
      return Result.failure('즐겨찾기 설정 중 오류가 발생했습니다: $e');
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
