import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
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
        gradient: const LinearGradient(
          colors: [
            AppColors.pointBrown,
            Color(0xFF8B4513), // 투명도 대신 고정 색상 사용
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // 투명도 대신 고정 색상 사용
            blurRadius: 8,
            offset: Offset(0, 4),
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
                color: const Color(0x4DFFFFFF), // 투명도 대신 고정 색상 사용
              ),
              _buildStatItem(
                '✓ なし',
                '$nonAllergyCount個',
                const Color(0xFF4CAF50),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0x4DFFFFFF), // 투명도 대신 고정 색상 사용
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
            color: const Color(0xCCFFFFFF), // 투명도 대신 고정 색상 사용
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
