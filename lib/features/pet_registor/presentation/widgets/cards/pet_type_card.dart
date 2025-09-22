import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// 펫 타입 선택 카드 위젯
///
/// CommonCard를 확장하여 일관된 디자인과 접근성을 제공합니다.
class PetTypeCard extends CommonCard {
  final String imagePath;
  final Color selectionColor;
  final String? petType;
  final String? title;
  final String? subtitle;

  const PetTypeCard({
    super.key,
    required this.imagePath,
    required this.selectionColor,
    required super.onTap,
    super.isSelected = false,
    this.petType,
    this.title,
    this.subtitle,
    super.semanticLabel,
  }) : super(
          padding: const EdgeInsets.all(AppSpacing.sm),
          borderRadius: AppRadius.large,
          border: null, // CommonCard에서 처리
        );

  @override
  Widget buildContent(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              Icons.pets,
              size: 40,
              color: selectionColor,
            ),
          );
        },
      ),
    );
  }

}