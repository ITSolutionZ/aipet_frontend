import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 펫 타입 선택 카드 위젯
///
/// const 생성자를 활용하여 성능을 최적화하고 재사용성을 높입니다.
class PetTypeCard extends StatelessWidget {
  final String imagePath;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PetTypeCard({
    super.key,
    required this.imagePath,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.pointGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Image.asset(
              imagePath,
              scale: 0.6,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.pets,
                  size: 40,
                  color: AppColors.pointPink,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
