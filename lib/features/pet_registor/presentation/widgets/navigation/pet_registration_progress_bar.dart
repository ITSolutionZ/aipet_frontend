import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

class PetRegistrationProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const PetRegistrationProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 7,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = ((currentStep / totalSteps) * 100).round();
    
    return Semantics(
      label: 'ペット登録の進行状況',
      hint: 'ステップ$currentStepの$totalSteps、$progressPercentage%完了',
      value: '$progressPercentage%',
      child: Container(
        width: double.infinity,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.pointGray.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: currentStep / totalSteps,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.pointPink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
