import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';


import '../../../../../shared/shared.dart';
/// 병원 목록 빈 상태 위젯
class HospitalEmptyState extends StatelessWidget {
  const HospitalEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '登録された病院がありません',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => context.push('/home/hospital-list'),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('病院を探す'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pointGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 병원 목록 에러 상태 위젯
class HospitalErrorState extends StatelessWidget {
  final String error;

  const HospitalErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'エラーが発生しました',
            style: AppFonts.bodyMedium.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: AppFonts.bodySmall.copyWith(color: Colors.red[600]),
          ),
        ],
      ),
    );
  }
}
