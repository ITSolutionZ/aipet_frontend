import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 달력 다이얼로그 헬퍼
class WalkCalendarDialogHelper {
  /// 산책 기록 정리 확인 다이얼로그 표시
  static Future<bool?> showCleanOldRecordsDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('古い記録を削除'),
        content: const Text('6ヶ月以上前の散歩記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// 삭제 성공 스낵바
  static void showDeleteSuccessSnackBar(
    BuildContext context,
    int deletedCount,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('古い散歩記録を$deletedCount件削除しました'),
        backgroundColor: AppColors.pointGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 삭제할 기록 없음 스낵바
  static void showNoRecordsToDeleteSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('削除する古い記録はありません'),
        backgroundColor: AppColors.pointBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 삭제 에러 스낵바
  static void showDeleteErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('削除中にエラーが発生しました'),
        backgroundColor: AppColors.pointPink,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
