import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;

  const SectionHeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        bottom: AppSpacing.sm,
        top: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.pointBrown,
        ),
      ),
    );
  }
}
