import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 분석 결과 헤더 카드
class AnalysisHeaderCard extends StatelessWidget {
  final String petName;
  final int allergyCount;
  final int nonAllergyCount;
  final double confidence;

  const AnalysisHeaderCard({
    super.key,
    required this.petName,
    required this.allergyCount,
    required this.nonAllergyCount,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pointBrown,
            AppColors.pointBrown.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointBrown.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, color: Colors.white, size: 32),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$petNameの分析結果',
                style: AppFonts.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '⚠ アレルギー',
                '$allergyCount個',
                const Color(0xFFFF6B9D),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                '✓ なし',
                '$nonAllergyCount個',
                const Color(0xFF4CAF50),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                '信頼度',
                '${(confidence * 100).toInt()}%',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppFonts.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
