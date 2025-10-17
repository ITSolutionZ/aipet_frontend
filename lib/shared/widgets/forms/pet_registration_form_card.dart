import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 🐾 Pet Registration 전용 폼 카드 컴포넌트
///
/// 참고 이미지의 깔끔한 카드 레이아웃을 구현
class PetRegistrationFormCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const PetRegistrationFormCard({
    super.key,
    this.title,
    required this.children,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointGray.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

/// 🎯 Pet Registration 전용 텍스트 필드
class PetRegistrationTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? errorText;

  const PetRegistrationTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          textAlign: textAlign,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: AppFonts.bodyLarge.copyWith(
            color: AppColors.pointDark,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.bodyLarge.copyWith(
              color: AppColors.pointGray.withValues(alpha: 0.6),
              fontSize: 16,
            ),
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: AppColors.cardBackgroundGray.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.pointBrown,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// 📋 Pet Registration 전용 선택 카드
class PetRegistrationSelectionCard extends StatelessWidget {
  final String label;
  final String? value;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;

  const PetRegistrationSelectionCard({
    super.key,
    required this.label,
    this.value,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : AppColors.cardBackgroundGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.sm)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFonts.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.pointBrown
                          : AppColors.pointDark,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pointBrown,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// 🖼️ Pet 프로필 이미지 카드
class PetProfileImageCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onTap;
  final double size;

  const PetProfileImageCard({
    super.key,
    this.imagePath,
    this.onTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: Image.asset(
                  imagePath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                ),
              )
            else
              _buildPlaceholder(),

            // 편집 아이콘
            if (onTap != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.pureWhite, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.pureWhite,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(Icons.pets, color: AppColors.pointGray, size: size * 0.4),
    );
  }
}
