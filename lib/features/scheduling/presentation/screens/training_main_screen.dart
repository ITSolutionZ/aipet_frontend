import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 학습/트레이닝 메인 화면
class TrainingMainScreen extends StatelessWidget {
  const TrainingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習・トレーニング'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
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
                  _buildMenuCard(
                    icon: Icons.school,
                    title: '基本トレーニング',
                    subtitle: '座る、待て、来いなど',
                    color: AppColors.pointBlue,
                    onTap: () {
                      // TODO: 기본 트레이닝 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('基本トレーニング - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.psychology,
                    title: '高度な技',
                    subtitle: '複雑なコマンド',
                    color: AppColors.pointGreen,
                    onTap: () {
                      // TODO: 고급 기술 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('高度な技 - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.timer,
                    title: 'トレーニング記録',
                    subtitle: '進捗と成果',
                    color: AppColors.pointBrown,
                    onTap: () {
                      // TODO: 트레이닝 기록 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('トレーニング記録 - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.calendar_today,
                    title: 'スケジュール',
                    subtitle: '練習予定',
                    color: AppColors.tonePeach,
                    onTap: () {
                      // TODO: 트레이닝 스케줄 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('練習スケジュール - Coming Soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppFonts.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
