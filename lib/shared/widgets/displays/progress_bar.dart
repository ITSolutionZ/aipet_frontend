import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 범용 프로그레스 바 위젯
class ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool showStepNumbers;
  final List<String>? stepLabels;

  const ProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.progressColor,
    this.backgroundColor,
    this.height = 6,
    this.showStepNumbers = false,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      children: [
        if (showStepNumbers) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$currentStep / $totalSteps',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.pointGray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor ?? AppColors.pointPink,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),

        if (stepLabels != null && stepLabels!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepLabels!.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep - 1;

              return Expanded(
                child: Text(
                  label,
                  textAlign: index == 0
                      ? TextAlign.start
                      : index == stepLabels!.length - 1
                          ? TextAlign.end
                          : TextAlign.center,
                  style: AppFonts.bodySmall.copyWith(
                    color: isCompleted || isCurrent
                        ? AppColors.pointDark
                        : AppColors.pointGray,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}