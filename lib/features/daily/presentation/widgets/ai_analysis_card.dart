import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// AI 분석 카드 위젯
class AIAnalysisCard extends StatelessWidget {
  final HealthAnalysis analysis;

  const AIAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI 리포트',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRiskLevelIndicator(),
          const SizedBox(height: AppSpacing.md),
          _buildRecommendationsSection(),
          if (analysis.warnings.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildWarningsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskLevelIndicator() {
    final riskData = _getRiskLevelData(analysis.riskLevel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: riskData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: riskData.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Icon(riskData.icon, color: riskData.color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riskData.text,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: riskData.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  riskData.description,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推奨事項',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...analysis.recommendations.map((recommendation) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.pointGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.pointGreen,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recommendation,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWarningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注意事項',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointRed,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...analysis.warnings.map((warning) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointRed.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.pointRed.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.pointRed,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    warning,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  _RiskLevelData _getRiskLevelData(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return _RiskLevelData(
          text: '低リスク',
          description: '現在の健康状態は良好です',
          icon: Icons.check_circle,
          color: AppColors.pointGreen,
        );
      case RiskLevel.medium:
        return _RiskLevelData(
          text: '中リスク',
          description: '注意深く観察してください',
          icon: Icons.warning,
          color: AppColors.pointYellow,
        );
      case RiskLevel.high:
        return _RiskLevelData(
          text: '高リスク',
          description: '獣医師への相談を推奨します',
          icon: Icons.dangerous,
          color: AppColors.pointRed,
        );
    }
  }
}

class _RiskLevelData {
  final String text;
  final String description;
  final IconData icon;
  final Color color;

  _RiskLevelData({
    required this.text,
    required this.description,
    required this.icon,
    required this.color,
  });
}
