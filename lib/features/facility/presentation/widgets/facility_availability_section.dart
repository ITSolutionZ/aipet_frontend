import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityAvailabilitySection extends StatelessWidget {
  final Facility facility;

  const FacilityAvailabilitySection({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '営業日',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 요일 칩
        Row(
          children: [
            _buildDayChip('月', true),
            const SizedBox(width: AppSpacing.xs),
            _buildDayChip('火', true),
            const SizedBox(width: AppSpacing.xs),
            _buildDayChip('水', true),
            const SizedBox(width: AppSpacing.xs),
            _buildDayChip('木', true),
            const SizedBox(width: AppSpacing.xs),
            _buildDayChip('金', true),
            const SizedBox(width: AppSpacing.xs),
            _buildDayChip('土', false),
            const SizedBox(width: AppSpacing.xs),
            _buildDayChip('日', false),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // 영업시간
        Text(
          '営業時間: 10:00 - 20:00',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
        ),
      ],
    );
  }

  Widget _buildDayChip(String day, bool isAvailable) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isAvailable ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Center(
        child: Text(
          day,
          style: AppFonts.bodySmall.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
