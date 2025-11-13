import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_common_widgets.dart'
    as daily_widgets;
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Daily Health 화면 빠른 액션 섹션
class DailyHealthQuickActionsGrid extends StatelessWidget {
  final DailyHealthLogic logic;

  const DailyHealthQuickActionsGrid({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const daily_widgets.SectionHeaderWidget(
          title: 'クイックアクション',
          subtitle: 'よく使う機能',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildQuickActionGrid(context),
      ],
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    final quickActions = logic.getQuickActions(
      onTemperatureRecord: () => logic.navigateToHealthInput(context, null),
      onSymptomRecord: () => logic.navigateToHealthInput(context, null),
      onMedicationRecord: () => logic.navigateToHealthInput(context, null),
      onHospitalBooking: () => logic.navigateToHospitalSearch(context),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: quickActions.length,
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return _buildQuickActionCard(
          title: action.title,
          icon: action.icon,
          color: action.color,
          onTap: action.onTap,
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
