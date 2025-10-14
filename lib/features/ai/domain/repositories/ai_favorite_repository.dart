import 'package:aipet_frontend/shared/core/domain/result.dart';

import '../entities/ai_favorite_entity.dart';
import '../entities/ai_favorite_qa_entity.dart';
import '../entities/ai_message_entity.dart';

/// AI 즐겨찾기 관련 Repository
abstract class AiFavoriteRepository {
  /// 즐겨찾기 메시지 관련
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  });

  Future<void> removeFavoriteMessage(String favoriteId);

  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  });

  Future<Result<bool>> toggleFavoriteMessage(String messageId);

  /// 즐겨찾기 QA 관련
  Future<List<AiFavoriteQaEntity>> getFavoriteQAs({
    String? petId,
    String? category,
  });

  Future<AiFavoriteQaEntity> addFavoriteQA({
    required String question,
    required String answer,
    required String category,
    String? petId,
    String? petName,
    String? userNote,
  });

  Future<void> removeFavoriteQA(String qaId);

  /// 즐겨찾기 관리
  Future<void> organizeFavorites({
    required String folderId,
    required List<String> favoriteIds,
  });

  Future<List<String>> getFavoriteFolders(String userId);

  Future<void> createFavoriteFolder({
    required String userId,
    required String folderName,
    String? description,
  });

  /// 즐겨찾기 검색
  Future<List<AiFavoriteEntity>> searchFavorites({
    required String query,
    String? petId,
    String? category,
  });

  /// 즐겨찾기 통계
  Future<FavoriteStatistics> getFavoriteStatistics(String userId);
}

/// 즐겨찾기 통계
class FavoriteStatistics {
  final int totalFavorites;
  final int totalQAs;
  final Map<String, int> categoryDistribution;
  final Map<String, int> petDistribution;
  final DateTime? oldestFavorite;
  final DateTime? newestFavorite;

  const FavoriteStatistics({
    required this.totalFavorites,
    required this.totalQAs,
    required this.categoryDistribution,
    required this.petDistribution,
    this.oldestFavorite,
    this.newestFavorite,
  });
}
