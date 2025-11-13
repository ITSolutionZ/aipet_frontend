import 'package:aipet_frontend/features/facility/presentation/screens/booking/constants/booking_constants.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

/// 予約者情報セクション
class UserInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const UserInfoSection({
    super.key,
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(BookingConstants.titleBookerInfo),
        const SizedBox(height: AppSpacing.md),
        _buildTextFormField(
          controller: nameController,
          label: BookingConstants.labelName,
          hint: BookingConstants.hintName,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return BookingConstants.errorEmptyName;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextFormField(
          controller: phoneController,
          label: BookingConstants.labelPhone,
          hint: BookingConstants.hintPhone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return BookingConstants.errorEmptyPhone;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              borderSide: const BorderSide(color: AppColors.pointGreen),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }
}
