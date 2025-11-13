import 'package:aipet_frontend/features/walk/domain/entities/no_entry_zone_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 산책 중 경고 알림 관리
class WalkAlertHelper {
  /// 금지구역 접근 경고 모달 표시
  static void showProximityWarning(
    BuildContext context, {
    required NoEntryZone zone,
    required double distance,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🚫 立入禁止エリア接近中'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '禁止エリアに接近しています!',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.pointPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '距離: ${distance.toStringAsFixed(1)}m',
              style: AppTextStyles.bodyMedium,
            ),
            if (zone.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '説明: ${zone.description}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.pointPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ 5m以内のエリアです。進入にご注意ください。',
                style: TextStyle(color: AppColors.pointPink),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  /// 산책 시간 절반 도달 - 돌아가기 권장 모달
  static void showTurnBackAlert(
    BuildContext context, {
    required int recommendedTime,
    required int elapsedMinutes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏰ 折り返しの時間です'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'そろそろ引き返しましょう!',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '推奨時間',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$recommendedTime 分',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '経過時間',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$elapsedMinutes 分',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointPink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '帰宅まで同じ時間がかかります。\n折り返して戻りましょう!',
                style: TextStyle(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
}
