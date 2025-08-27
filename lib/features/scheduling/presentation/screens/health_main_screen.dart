import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 건강 관리 메인 화면
class HealthMainScreen extends StatelessWidget {
  const HealthMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康管理'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
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
                  _buildMenuCard(
                    icon: Icons.medical_services,
                    title: '健康チェック',
                    subtitle: '定期的な健康診断',
                    color: AppColors.pointBrown,
                    onTap: () {
                      // TODO: 건강 체크 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('健康チェック - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.medication,
                    title: '投薬管理',
                    subtitle: '薬のスケジュール',
                    color: AppColors.pointBrown,
                    onTap: () {
                      // TODO: 투약 관리 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('投薬管理 - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.fitness_center,
                    title: '運動記録',
                    subtitle: '運動量と活動',
                    color: AppColors.pointGreen,
                    onTap: () {
                      // TODO: 운동 기록 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('運動記録 - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.analytics,
                    title: '健康分析',
                    subtitle: '健康データの分析',
                    color: AppColors.pointBlue,
                    onTap: () {
                      // TODO: 건강 분석 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('健康分析 - Coming Soon')),
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
