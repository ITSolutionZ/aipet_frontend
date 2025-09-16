import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

/// 재사용 가능한 펫 프로필 카드 위젯
class PetProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PetProfileCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.pointBlue).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.pointBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// 편집 가능한 속성 카드
class EditableAttributeCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditMode;
  final Widget? editWidget;

  const EditableAttributeCard({
    super.key,
    required this.label,
    required this.value,
    this.isEditMode = false,
    this.editWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
          ),
          if (isEditMode && editWidget != null)
            editWidget!
          else
            Text(
              value,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// 날짜 정보 카드
class DateInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;
  final String? additionalInfo;

  const DateInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.date,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return PetProfileCard(
      label: label,
      value: date,
      icon: icon,
      iconColor: AppColors.pointBlue,
      trailing: additionalInfo != null
          ? Text(
              additionalInfo!,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

/// 펫 프로필 헤더
class PetProfileHeader extends StatelessWidget {
  final String? imagePath;
  final String? selectedImagePath;
  final String name;
  final String typeAndBreed;
  final bool isEditMode;
  final VoidCallback? onImageTap;
  final Widget? nameWidget;

  const PetProfileHeader({
    super.key,
    this.imagePath,
    this.selectedImagePath,
    required this.name,
    required this.typeAndBreed,
    this.isEditMode = false,
    this.onImageTap,
    this.nameWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 프로필 사진
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              backgroundImage: (selectedImagePath ?? imagePath) != null
                  ? AssetImage(selectedImagePath ?? imagePath!)
                  : null,
              child: (selectedImagePath ?? imagePath) == null
                  ? const Icon(
                      Icons.pets,
                      size: 50,
                      color: AppColors.pointBrown,
                    )
                  : null,
            ),
            if (isEditMode)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onImageTap,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.pointBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),

        // 이름과 종류
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameWidget ??
                  Row(
                    children: [
                      Text(
                        name,
                        style: AppFonts.titleLarge.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isEditMode) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColors.pointBlue,
                        ),
                      ],
                    ],
                  ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                typeAndBreed,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}