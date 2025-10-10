import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Live Walk 다이얼로그 헬퍼
class LiveWalkDialogHelper {
  /// 뒤로가기 확인 다이얼로그
  static Future<void> showBackConfirmDialog({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩を終了しますか？'),
        content: const Text('進行中の散歩を終了して戻りますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('終了して戻る'),
          ),
        ],
      ),
    );
  }

  /// 산책 종료 확인 다이얼로그
  static Future<void> showStopWalkDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩を終了しますか？'),
        content: const Text('散歩を終了して記録を保存しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('散歩が保存されました'),
                  backgroundColor: AppColors.pointGreen,
                ),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  /// 산책 취소 확인 다이얼로그
  static Future<void> showCancelWalkDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩をキャンセルしますか？'),
        content: const Text('進行中の散歩データが削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
