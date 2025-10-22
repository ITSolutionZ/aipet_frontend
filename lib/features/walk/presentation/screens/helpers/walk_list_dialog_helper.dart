import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import 'walk_list_activity_helper.dart';

/// 산책 리스트 다이얼로그 헬퍼
class WalkListDialogHelper {
  /// 산책 종료 다이얼로그 표시
  static void showEndWalkDialog({
    required BuildContext context,
    required WalkRecordEntity currentWalk,
    required int elapsedSeconds,
    required WalkController controller,
    required List<Map<String, dynamic>> petActivities,
    required VoidCallback onEndSuccess,
  }) {
    final currentDistance = currentWalk.distance ?? 0.0;
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩を終了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${currentWalk.petName}との散歩を終了しますか？'),
            const SizedBox(height: 16),
            Text(
              '経過時間: $hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '距離: ${currentDistance < 1 ? '${(currentDistance * 1000).toStringAsFixed(0)}m' : '${currentDistance.toStringAsFixed(2)}km'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _handleEndWalk(
                context: context,
                controller: controller,
                currentDistance: currentDistance,
                petActivities: petActivities,
                onEndSuccess: onEndSuccess,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  /// 산책 종료 처리
  static Future<void> _handleEndWalk({
    required BuildContext context,
    required WalkController controller,
    required double currentDistance,
    required List<Map<String, dynamic>> petActivities,
    required VoidCallback onEndSuccess,
  }) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.pop();

    // 활동 기록을 notes에 JSON 형식으로 저장
    final notesWithActivities = WalkListActivityHelper.convertActivitiesToNotes(
      petActivities,
    );

    debugPrint(
      '🔄 산책 종료 시작 - 거리: $currentDistance, 활동: ${petActivities.length}개',
    );

    // 산책 종료
    final result = await controller.endCurrentWalk(
      distance: currentDistance,
      notes: notesWithActivities,
    );

    debugPrint(
      '✅ 산책 종료 결과: ${result.isSuccess ? "성공" : "실패"} - ${result.message}',
    );

    if (!context.mounted) return;

    // 성공 콜백 실행
    onEndSuccess();

    // 결과 메시지 표시
    if (result.isSuccess) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('散歩が終了しました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.pointPink,
        ),
      );
    }
  }

  /// 활동 마커 삭제 다이얼로그 표시
  static void showDeleteActivityDialog({
    required BuildContext context,
    required String activityType,
    required VoidCallback onDelete,
  }) {
    final label = WalkListActivityHelper.getActivityDetailLabel(activityType);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除'),
        content: Text('$labelの記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
              SnackBarService.showSuccess(
                context,
                '$labelを削除しました',
                duration: const Duration(seconds: 1),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
