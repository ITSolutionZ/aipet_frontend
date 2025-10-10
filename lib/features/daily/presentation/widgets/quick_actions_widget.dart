import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 퀵 액션 아이템 데이터
class QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// 퀵 액션 위젯
class QuickActionsWidget extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionsWidget({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'クイック記録',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _QuickActionButton(action: action);
            },
          ),
        ],
      ),
    );
  }
}

/// 퀵 액션 버튼
class _QuickActionButton extends StatelessWidget {
  final QuickActionItem action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: action.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  action.title,
                  style: AppFonts.bodySmall.copyWith(
                    color: action.color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 기본 퀵 액션들
class DefaultQuickActions {
  static List<QuickActionItem> getHealthActions({
    VoidCallback? onTemperatureRecord,
    VoidCallback? onSymptomRecord,
    VoidCallback? onMedicationRecord,
    VoidCallback? onHospitalBooking,
  }) {
    return [
      QuickActionItem(
        title: '体温記録',
        icon: Icons.thermostat,
        color: const Color(0xFFE74C3C),
        onTap: onTemperatureRecord ?? () {},
      ),
      QuickActionItem(
        title: '症状記録',
        icon: Icons.medical_services,
        color: const Color(0xFFFF9500),
        onTap: onSymptomRecord ?? () {},
      ),
      QuickActionItem(
        title: '薬の記録',
        icon: Icons.medication,
        color: const Color(0xFF007AFF),
        onTap: onMedicationRecord ?? () {},
      ),
      QuickActionItem(
        title: '病院予約',
        icon: Icons.local_hospital,
        color: const Color(0xFF34C759),
        onTap: onHospitalBooking ?? () {},
      ),
    ];
  }
}
