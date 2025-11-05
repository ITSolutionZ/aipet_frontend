import 'package:flutter/material.dart';


import '../../../../../../shared/shared.dart';
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
  /// ✅ Shared SnackBarService 사용
  static void showDeleteSuccessSnackBar(
    BuildContext context,
    int deletedCount,
  ) {
    SnackBarService.showSuccess(
      context,
      '古い散歩記録を$deletedCount件削除しました',
      duration: const Duration(seconds: 3),
    );
  }

  /// 삭제할 기록 없음 스낵바
  /// ✅ Shared SnackBarService 사용
  static void showNoRecordsToDeleteSnackBar(BuildContext context) {
    SnackBarService.showInfo(
      context,
      '削除する古い記録はありません',
      duration: const Duration(seconds: 2),
    );
  }

  /// 삭제 에러 스낵바
  /// ✅ Shared SnackBarService 사용
  static void showDeleteErrorSnackBar(BuildContext context) {
    SnackBarService.showError(
      context,
      '削除中にエラーが発生しました',
      duration: const Duration(seconds: 3),
    );
  }
}
