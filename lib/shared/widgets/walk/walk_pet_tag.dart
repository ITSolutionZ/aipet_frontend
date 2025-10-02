import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 산책 기록의 반려동물 태그 위젯
class WalkPetTag extends StatelessWidget {
  final String petName;
  final Color? color;
  final IconData? icon;

  const WalkPetTag({super.key, required this.petName, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? AppColors.pointGreen;
    final tagIcon = icon ?? Icons.pets;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tagIcon, size: 16, color: tagColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$petNameとの散歩',
            style: AppFonts.base(
              fontSize: AppFonts.sm,
              color: tagColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
