import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 즐겨찾기 메시지 관리 UseCase
class FavoriteMessageUseCase {
  final AiRepository _repository;

  const FavoriteMessageUseCase(this._repository);

  /// 즐겨찾기 메시지 추가
  ///
  /// [message] 즐겨찾기할 메시지
  /// [category] 카테고리
  /// [petId] 펫 ID (선택사항)
  /// [petName] 펫 이름 (선택사항)
  /// [userNote] 사용자 메모 (선택사항)
  ///
  /// Returns: 추가된 즐겨찾기 엔티티
  Future<Result<AiFavoriteEntity>> addFavorite({
    required AiMessageEntity message,
    required String category,
    String? petId,
    String? petName,
    String? userNote,
  }) async {
    try {
      // 입력 유효성 검사
      if (category.trim().isEmpty) {
        return ResultFactory.failure<AiFavoriteEntity>('カテゴリを入力してください').toFuture();
      }

      final favorite = await _repository.addFavoriteMessage(
        message,
        category,
        petId: petId,
        petName: petName,
        userNote: userNote,
      );
      return ResultFactory.success(favorite, 'お気に入りに追加しました').toFuture();
    } catch (error) {
      return ResultFactory.failure<AiFavoriteEntity>(
        'お気に入りの追加に失敗しました: ${error.toString()}',
      ).toFuture();
    }
  }

  /// 즐겨찾기 메시지 삭제
  ///
  /// [favoriteId] 삭제할 즐겨찾기 ID
  ///
  /// Returns: 삭제 결과
  Future<Result<void>> removeFavorite(String favoriteId) async {
    try {
      // 입력 유효성 검사
      if (favoriteId.trim().isEmpty) {
        return ResultFactory.failure<void>('お気に入りIDが無効です').toFuture();
      }

      await _repository.removeFavoriteMessage(favoriteId);
      return ResultFactory.success(null, 'お気に入りを削除しました').toFuture();
    } catch (error) {
      return ResultFactory.failure<void>('お気に入りの削除に失敗しました: ${error.toString()}').toFuture();
    }
  }

  /// 즐겨찾기 메시지 목록 조회
  ///
  /// [petId] 펫 ID로 필터링 (선택사항)
  /// [category] 카테고리로 필터링 (선택사항)
  ///
  /// Returns: 즐겨찾기 목록
  Future<Result<List<AiFavoriteEntity>>> getFavorites({
    String? petId,
    String? category,
  }) async {
    try {
      final favorites = await _repository.getFavoriteMessages(
        petId: petId,
        category: category,
      );
      return ResultFactory.success(favorites, 'お気に入り一覧を取得しました').toFuture();
    } catch (error) {
      return ResultFactory.failure<List<AiFavoriteEntity>>(
        'お気に入り一覧の取得に失敗しました: ${error.toString()}',
      ).toFuture();
    }
  }
}
