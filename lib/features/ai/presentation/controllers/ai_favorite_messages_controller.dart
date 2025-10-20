import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/domain.dart';

part 'ai_favorite_messages_controller.g.dart';

/// AI 즐겨찾기 메시지 컨트롤러
@riverpod
AiFavoriteMessagesController aiFavoriteMessagesController(Ref ref) {
  return AiFavoriteMessagesController();
}

/// AI 즐겨찾기 메시지 컨트롤러 클래스
class AiFavoriteMessagesController {
  /// 펫별로 즐겨찾기 그룹화
  Map<String, List<AiFavoriteQaEntity>> groupFavoritesByPet(
    List<AiFavoriteQaEntity> favorites,
  ) {
    final grouped = <String, List<AiFavoriteQaEntity>>{};

    for (final favorite in favorites) {
      final key = favorite.petGroupKey;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(favorite);
    }

    // 각 그룹을 최신 순으로 정렬
    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  /// 날짜/시간 포맷팅
  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  /// 최신 활동 텍스트 생성
  String getLatestActivityText(List<AiFavoriteQaEntity> favorites) {
    if (favorites.isEmpty) return '';

    // 최신 즐겨찾기 찾기
    final latest = favorites.reduce(
      (current, next) =>
          current.createdAt.isAfter(next.createdAt) ? current : next,
    );

    return '最新: ${formatTime(latest.createdAt)}';
  }

  /// 클립보드에 복사
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// QA 공유
  Future<void> shareQA(AiFavoriteQaEntity favorite) async {
    final petInfo = favorite.pet != null
        ? '【${favorite.pet!.name} (${favorite.pet!.type})】'
        : '【一般的なペット相談】';

    final shareText =
        '''$petInfo

質問: ${favorite.question}

回答: ${favorite.answer}

--- AI Pet アプリより ---''';

    await SharePlus.instance.share(
      ShareParams(text: shareText, subject: 'AI Pet アプリより'),
    );
  }
}
