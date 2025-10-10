import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Live Walk 바텀시트 헬퍼
class LiveWalkSheetHelper {
  /// 산책 기록 리스트 바텀시트 표시
  static void showWalkRecordsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.pointOffWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 제목
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '散歩記録',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 산책 기록 리스트
            Expanded(
              child: Center(
                child: Text(
                  '散歩記録がありません',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 옵션 메뉴 바텀시트 표시
  static void showWalkOptionsSheet({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onPause,
    required VoidCallback onCancel,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('一時停止'),
              onTap: () {
                Navigator.of(context).pop();
                onPause();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.pointPink),
              title: const Text(
                '散歩をキャンセル',
                style: TextStyle(color: AppColors.pointPink),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onCancel();
              },
            ),
          ],
        ),
      ),
    );
  }
}
