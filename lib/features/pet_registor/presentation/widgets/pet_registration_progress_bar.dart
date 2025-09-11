import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

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
    return Container(
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
    );
  }
}
