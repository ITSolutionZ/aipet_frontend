import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 북마크 프로바이더 (임시로 여기에 정의)
final videoBookmarksProvider =
    FutureProvider.family<List<VideoBookmarkEntity>, String>((
      ref,
      videoId,
    ) async {
      final repository = ref.read(petActivitiesRepositoryProvider);
      return repository.getVideoBookmarks(videoId);
    });

/// 비디오 북마크 CRUD 헬퍼
class VideoBookmarkCrudHelper {
  /// 북마크 추가
  static Future<void> addBookmark({
    required WidgetRef ref,
    required String videoId,
    required String title,
    required int positionSec,
    String? description,
  }) async {
    try {
      final bookmark = VideoBookmarkEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        videoId: videoId,
        title: title.isNotEmpty ? title : 'Bookmark',
        positionSec: positionSec,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(petActivitiesRepositoryProvider);
      await repository.addVideoBookmark(bookmark);

      // 북마크 목록 새로고침
      ref.invalidate(videoBookmarksProvider(videoId));
    } catch (error) {
      rethrow;
    }
  }

  /// 북마크 삭제
  static Future<void> deleteBookmark({
    required WidgetRef ref,
    required String bookmarkId,
    required String videoId,
  }) async {
    try {
      final repository = ref.read(petActivitiesRepositoryProvider);
      await repository.removeVideoBookmark(bookmarkId);

      // 북마크 목록 새로고침
      ref.invalidate(videoBookmarksProvider(videoId));
    } catch (error) {
      rethrow;
    }
  }

  /// 북마크 업데이트
  static Future<void> updateBookmark({
    required WidgetRef ref,
    required VideoBookmarkEntity bookmark,
    required String videoId,
  }) async {
    try {
      final updatedBookmark = bookmark.copyWith(updatedAt: DateTime.now());

      final repository = ref.read(petActivitiesRepositoryProvider);
      await repository.addVideoBookmark(updatedBookmark);

      // 북마크 목록 새로고침
      ref.invalidate(videoBookmarksProvider(videoId));
    } catch (error) {
      rethrow;
    }
  }

  /// 북마크 삭제 확인 다이얼로그 표시
  static Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    VideoBookmarkEntity bookmark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ブックマークを削除'),
        content: Text('ブックマーク"${bookmark.displayLabel}"を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// 에러 처리 및 사용자 피드백
  static void handleError(
    BuildContext context,
    String operation,
    dynamic error,
  ) {
    if (context.mounted) {
      UiService.showError(context, '$operationに失敗しました: $error');
    }
  }

  /// 성공 피드백
  static void showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      UiService.showSuccess(context, message);
    }
  }
}
