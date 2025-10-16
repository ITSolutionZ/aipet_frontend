import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 분석 내용 섹션
class AnalysisDetailSection extends StatelessWidget {
  final String analysis;

  const AnalysisDetailSection({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: const Color(0x0D000000), // 투명도 대신 고정 색상 사용
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // 투명도 대신 고정 색상 사용
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.article_outlined,
                color: AppColors.pointBrown,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '詳細分析',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            analysis,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
