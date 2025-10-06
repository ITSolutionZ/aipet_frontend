import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 중성화 여부 선택 섹션
class PetNeuteringSection extends StatelessWidget {
  final bool isNeutered;
  final ValueChanged<bool> onNeuteringChanged;

  const PetNeuteringSection({
    super.key,
    required this.isNeutered,
    required this.onNeuteringChanged,
  });

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
          Text(
            '중성화',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isNeutered,
                      onChanged: (value) {
                        if (value != null) {
                          onNeuteringChanged(value);
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      '했어요',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isNeutered,
                      onChanged: (value) {
                        if (value != null) {
                          onNeuteringChanged(value);
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      '안했어요',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
