import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 급수/물 관리 메인 화면
class WateringMainScreen extends StatelessWidget {
  const WateringMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('給水管理'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペットの水分補給を管理しましょう',
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
                    icon: Icons.water_drop,
                    title: '給水スケジュール',
                    subtitle: '定期的な給水',
                    color: AppColors.tonePeach,
                    onTap: () {
                      // TODO: 급수 스케줄 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('給水スケジュール - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.history,
                    title: '給水記録',
                    subtitle: '給水履歴',
                    color: AppColors.pointBlue,
                    onTap: () {
                      // TODO: 급수 기록 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('給水記録 - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.analytics,
                    title: '給水分析',
                    subtitle: '水分摂取量',
                    color: AppColors.pointGreen,
                    onTap: () {
                      // TODO: 급수 분석 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('給水分析 - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.settings,
                    title: '給水設定',
                    subtitle: '給水器の設定',
                    color: AppColors.pointBrown,
                    onTap: () {
                      // TODO: 급수 설정 페이지로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('給水設定 - Coming Soon')),
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
                  color: color.withValues(alpha: 0.1),
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
