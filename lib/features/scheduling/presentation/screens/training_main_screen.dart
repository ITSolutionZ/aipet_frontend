import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import 'helpers/helpers.dart';

/// 학습/트레이닝 메인 화면
class TrainingMainScreen extends StatelessWidget {
  const TrainingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SoftGradientAppBar(title: '学習・トレーニング'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペットの学習とトレーニングを管理しましょう',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  TrainingUiHelper.buildMenuCard(
                    icon: Icons.school,
                    title: '基本トレーニング',
                    subtitle: '座る、待て、来いなど',
                    color: AppColors.pointBlue,
                    onTap: () =>
                        TrainingSheetHelper.showBasicTrainingSheet(context),
                  ),
                  TrainingUiHelper.buildMenuCard(
                    icon: Icons.psychology,
                    title: '高度な技',
                    subtitle: '複雑なコマンド',
                    color: AppColors.pointGreen,
                    onTap: () =>
                        TrainingDialogHelper.showAdvancedSkillsDialog(context),
                  ),
                  TrainingUiHelper.buildMenuCard(
                    icon: Icons.timer,
                    title: 'トレーニング記録',
                    subtitle: '進捗と成果',
                    color: AppColors.pointBrown,
                    onTap: () =>
                        TrainingSheetHelper.showTrainingRecordsSheet(context),
                  ),
                  TrainingUiHelper.buildMenuCard(
                    icon: Icons.calendar_today,
                    title: 'スケジュール',
                    subtitle: '練習予定',
                    color: AppColors.tonePeach,
                    onTap: () =>
                        TrainingDialogHelper.showTrainingScheduleDialog(
                          context,
                        ),
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
