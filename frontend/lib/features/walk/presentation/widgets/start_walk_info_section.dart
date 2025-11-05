import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 산책 시작 시 정보 섹션 위젯
class StartWalkInfoSection extends StatelessWidget {
  const StartWalkInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.pointGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '散歩について',
                style: AppFonts.fredoka(
                  fontSize: AppFonts.baseSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.pointGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'GPS位置情報を使用してルートを記録',
                style: AppFonts.base(
                  fontSize: AppFonts.sm,
                  color: AppColors.pointGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: AppColors.pointGreen),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '歩いた時間と距離を自動測定',
                style: AppFonts.base(
                  fontSize: AppFonts.sm,
                  color: AppColors.pointGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.camera_alt,
                size: 16,
                color: AppColors.pointGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '散歩中の思い出を写真で記録可能',
                style: AppFonts.base(
                  fontSize: AppFonts.sm,
                  color: AppColors.pointGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
