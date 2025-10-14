import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 증상 카드 위젯
class SymptomsCard extends StatelessWidget {
  final DailyHealthRecord healthRecord;

  const SymptomsCard({super.key, required this.healthRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              const Icon(
                Icons.medical_services,
                color: AppColors.pointOrange,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '症状記録',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (healthRecord.symptoms.isNotEmpty) ...[
            _buildSymptomsList(),
          ] else ...[
            _buildEmptyState(),
          ],
          if (healthRecord.notes != null && healthRecord.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildNotesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記録された症状 (${healthRecord.symptoms.length}件)',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: healthRecord.symptoms.map((symptom) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.pointOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: AppColors.pointOrange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.pointOrange,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    symptom,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.pointGreen,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '症状なし',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.pointGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '現在、異常な症状は記録されていません',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.note_alt,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'メモ',
              style: AppFonts.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            healthRecord.notes!,
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
