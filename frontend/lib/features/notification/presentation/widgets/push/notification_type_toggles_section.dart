import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../components/forms/alarm_toggle_component.dart';

/// 通知タイプトグルセクション
///
/// 各種アラームのON/OFF設定を提供
class NotificationTypeTogglesSection extends StatelessWidget {
  final bool foodAlarmEnabled;
  final bool walkAlarmEnabled;
  final bool medicineAlarmEnabled;
  final bool systemAlarmEnabled;
  final bool reservationAlarmEnabled;
  final ValueChanged<bool> onFoodAlarmChanged;
  final ValueChanged<bool> onWalkAlarmChanged;
  final ValueChanged<bool> onMedicineAlarmChanged;
  final ValueChanged<bool> onSystemAlarmChanged;
  final ValueChanged<bool> onReservationAlarmChanged;

  const NotificationTypeTogglesSection({
    super.key,
    required this.foodAlarmEnabled,
    required this.walkAlarmEnabled,
    required this.medicineAlarmEnabled,
    required this.systemAlarmEnabled,
    required this.reservationAlarmEnabled,
    required this.onFoodAlarmChanged,
    required this.onWalkAlarmChanged,
    required this.onMedicineAlarmChanged,
    required this.onSystemAlarmChanged,
    required this.onReservationAlarmChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ページ説明
        _buildInfoBanner(),
        const SectionHeaderComponent(title: 'アラーム種類'),
        const SizedBox(height: AppSpacing.md),

        // 各種アラームトグル
        AlarmToggleComponent(
          title: '食事アラーム',
          subtitle: '食事給与時間をお知らせいたします',
          value: foodAlarmEnabled,
          onChanged: onFoodAlarmChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        AlarmToggleComponent(
          title: '散歩アラーム',
          subtitle: '決めた時間に散歩時間をわかるように',
          value: walkAlarmEnabled,
          onChanged: onWalkAlarmChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        AlarmToggleComponent(
          title: '薬のアラーム',
          subtitle: '薬の服用時間をお知らせいたします',
          value: medicineAlarmEnabled,
          onChanged: onMedicineAlarmChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        AlarmToggleComponent(
          title: '予約アラーム',
          subtitle: '予約時間をお知らせいたします',
          value: reservationAlarmEnabled,
          onChanged: onReservationAlarmChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        AlarmToggleComponent(
          title: 'システムアラーム',
          subtitle: '予約などをお知らせいたします',
          value: systemAlarmEnabled,
          onChanged: onSystemAlarmChanged,
        ),
      ],
    );
  }

  /// 情報バナー
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.pointBrown, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'アラームをオンにすると、設定した時間にお知らせを受け取ることができます',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBrown,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
