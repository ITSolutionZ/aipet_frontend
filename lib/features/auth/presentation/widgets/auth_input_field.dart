import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    required this.onChanged,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.labelColor,
  });

  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final Function(String) onChanged;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
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
          keyboardType: keyboardType,
          style: AppFonts.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: AppColors.pointGray, size: 20),
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
              borderSide: const BorderSide(color: AppColors.pointBrown, width: 2),
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
