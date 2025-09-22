import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// 펫 타입 선택 카드 위젯
///
/// AppCard를 사용하여 일관된 디자인과 접근성을 제공합니다.
class PetTypeCard extends StatelessWidget {
  final String imagePath;
  final Color selectionColor;
  final String? petType;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isSelected;
  final String? semanticLabel;

  const PetTypeCard({
    super.key,
    required this.imagePath,
    required this.selectionColor,
    required this.onTap,
    this.isSelected = false,
    this.petType,
    this.title,
    this.subtitle,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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