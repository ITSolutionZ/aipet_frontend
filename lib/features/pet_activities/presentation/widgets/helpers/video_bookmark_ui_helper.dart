import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 비디오 북마크 UI 헬퍼
class VideoBookmarkUiHelper {
  /// 북마크 아이템 위젯 빌드
  static Widget buildBookmarkItem({
    required VideoBookmarkEntity bookmark,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: _buildTimeIndicator(bookmark.positionSec),
        title: Text(
          bookmark.title,
          style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: bookmark.description != null
            ? Text(
                bookmark.description!,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text('削除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  /// 시간 표시기 빌드
  static Widget _buildTimeIndicator(int positionSec) {
    final minutes = positionSec ~/ 60;
    final seconds = positionSec % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          timeText,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 빈 상태 위젯 빌드
  static Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ブックマークがありません',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ビデオの好きな部分にブックマークを追加しましょう',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 로딩 상태 위젯 빌드
  static Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBlue),
      ),
    );
  }

  /// 에러 상태 위젯 빌드
  static Widget buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ブックマークの読み込みに失敗しました',
            style: AppFonts.bodyMedium.copyWith(color: Colors.red),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
        ],
      ),
    );
  }

  /// 헤더 위젯 빌드
  static Widget buildHeader({required VoidCallback onAddBookmark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Text(
            'ブックマーク',
            style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: onAddBookmark,
            icon: const Icon(Icons.add),
            tooltip: 'ブックマークを追加',
          ),
        ],
      ),
    );
  }

  /// 핸들 위젯 빌드
  static Widget buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
