import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 현재 급여량 요약 섹션
class CurrentFeedingSummarySection extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const CurrentFeedingSummarySection({super.key, required this.analysisData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '現在の食事量',
            style: AppFonts.fredoka(
              fontSize: AppFonts.xl,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _CurrentFeedingCard(
                  value: '${analysisData['currentAmount'].toInt()}g',
                  label: '現在',
                  color: AppColors.pointBrown,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CurrentFeedingCard(
                  value:
                      '${analysisData['changeAmount'] > 0 ? '+' : ''}${analysisData['changeAmount'].toInt()}g',
                  label: '変化',
                  color: AppColors.pointGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CurrentFeedingCard(
                  value: '${analysisData['targetAmount'].toInt()}g',
                  label: '目標',
                  color: AppColors.pointBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 현재 급여량 카드 위젯
class _CurrentFeedingCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _CurrentFeedingCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppFonts.fredoka(
              fontSize: AppFonts.xl,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppFonts.fredoka(fontSize: AppFonts.sm, color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}
