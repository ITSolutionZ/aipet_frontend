import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 카드 네비게이션 점들
class PetNavigationDots extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final ValueChanged<int>? onTap;

  const PetNavigationDots({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalCount,
        (index) => GestureDetector(
          onTap: () => onTap?.call(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex
                  ? AppColors.pointBrown
                  : AppColors.pointBrown.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}