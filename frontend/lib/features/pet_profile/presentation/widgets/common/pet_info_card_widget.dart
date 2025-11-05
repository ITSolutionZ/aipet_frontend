import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/pet_profile/presentation/constants/pet_profile_constants.dart';

/// Pet 정보 카드 위젯
///
/// 펫의 기본 정보를 표시하는 재사용 가능한 카드 위젯입니다.
class PetInfoCardWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PetInfoCardWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    this.trailing,
    this.onTap,
  });

  factory PetInfoCardWidget.withIcon({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return PetInfoCardWidget(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      subtitle: subtitle,
      badge: badge,
      badgeColor: badgeColor,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildContent()),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badge != null) _buildBadge(),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor ?? AppColors.pointBrown,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        badge!,
        style: AppFonts.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 편집 가능한 Pet 정보 카드 위젯
class EditablePetInfoCardWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final bool isEditMode;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const EditablePetInfoCardWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    this.isEditMode = false,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PetInfoCardWidget.withIcon(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      subtitle: subtitle,
      badge: badge,
      badgeColor: badgeColor,
      trailing: isEditMode && onEdit != null
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: onEdit,
              tooltip: PetProfileConstants.editLabel,
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Pet 프로필 헤더 카드 위젯
class PetProfileHeaderCardWidget extends StatelessWidget {
  final String petName;
  final String petType;
  final String? breed;
  final String gender;
  final Color genderColor;
  final String petTypeIcon;

  const PetProfileHeaderCardWidget({
    super.key,
    required this.petName,
    required this.petType,
    this.breed,
    required this.gender,
    required this.genderColor,
    required this.petTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return PetInfoCardWidget.withIcon(
      icon: Icons.pets,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      title: petName,
      subtitle: _buildSubtitle(),
      badge: gender,
      badgeColor: genderColor,
    );
  }

  String _buildSubtitle() {
    final breedText = breed?.isNotEmpty == true
        ? breed!
        : PetProfileConstants.defaultBreed;
    return '$petType • $breedText';
  }
}

/// Pet 나이 카드 위젯
class PetAgeCardWidget extends StatelessWidget {
  final DateTime birthDate;
  final int age;

  const PetAgeCardWidget({
    super.key,
    required this.birthDate,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return PetInfoCardWidget.withIcon(
      icon: Icons.cake,
      iconColor: AppColors.pointPink,
      iconBackgroundColor: AppColors.pointPink.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      title: PetProfileConstants.birthDateLabel,
      subtitle: _formatBirthDate(birthDate),
      badge: '$age歳',
      badgeColor: AppColors.pointPink,
    );
  }

  String _formatBirthDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// Pet 마이크로칩 카드 위젯
class PetMicrochipCardWidget extends StatelessWidget {
  final String? microchipId;
  final bool isEditMode;
  final VoidCallback? onEdit;

  const PetMicrochipCardWidget({
    super.key,
    this.microchipId,
    this.isEditMode = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isRegistered = microchipId?.isNotEmpty == true;

    return EditablePetInfoCardWidget(
      icon: Icons.memory,
      iconColor: AppColors.pointBlue,
      iconBackgroundColor: AppColors.pointBlue.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      title: PetProfileConstants.microchipLabel,
      subtitle: isRegistered
          ? microchipId!
          : PetProfileConstants.unregisteredStatus,
      badge: isRegistered
          ? PetProfileConstants.registeredStatus
          : PetProfileConstants.unregisteredStatus,
      badgeColor: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
      isEditMode: isEditMode,
      onEdit: onEdit,
    );
  }
}
