import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onChanged,
    required this.validator,
    this.labelColor,
  });

  final String label;
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final Function(String) onChanged;
  final String? Function(String?) validator;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(
            color: labelColor ?? AppColors.pointGray,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: AppFonts.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.pointGray,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.pointGray,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(
                color: AppColors.pointBrown,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
