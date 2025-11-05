import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
import 'helpers/helpers.dart';


/// 건강 관리 메인 화면
class HealthMainScreen extends StatelessWidget {
  const HealthMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SoftGradientAppBar(title: '健康管理'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペットの健康状態を管理しましょう',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  HealthUiHelper.buildMenuCard(
                    icon: Icons.medical_services,
                    title: '健康チェック',
                    subtitle: '定期的な健康診断',
                    color: AppColors.pointBrown,
                    onTap: () =>
                        HealthSheetHelper.showHealthCheckSheet(context),
                  ),
                  HealthUiHelper.buildMenuCard(
                    icon: Icons.medication,
                    title: '投薬管理',
                    subtitle: '薬のスケジュール',
                    color: AppColors.pointBrown,
                    onTap: () =>
                        HealthSheetHelper.showMedicationManagementDialog(
                          context,
                        ),
                  ),
                  HealthUiHelper.buildMenuCard(
                    icon: Icons.fitness_center,
                    title: '運動記録',
                    subtitle: '運動量と活動',
                    color: AppColors.pointGreen,
                    onTap: () =>
                        HealthSheetHelper.showExerciseRecordSheet(context),
                  ),
                  HealthUiHelper.buildMenuCard(
                    icon: Icons.analytics,
                    title: '健康分析',
                    subtitle: '健康データの分析',
                    color: AppColors.pointBlue,
                    onTap: () =>
                        HealthSheetHelper.showHealthAnalysisDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
