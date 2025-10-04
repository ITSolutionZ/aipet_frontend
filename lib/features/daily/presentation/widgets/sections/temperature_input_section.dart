import 'package:aipet_frontend/shared/mixins/mixins.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 체온 입력 섹션 위젯
class TemperatureInputSection extends StatelessWidget with ValidationMixin {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TemperatureInputSection({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCardContainer(
      title: '体温',
      child: CommonFormField(
        controller: controller,
        label: '',
        hint: '37.5',
        keyboardType: TextInputType.number,
        suffix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '°C',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.thermostat, color: AppColors.pointRed, size: 24),
          ],
        ),
        validator: validator ?? (value) => validatePetTemperature(value),
      ),
    );
  }
}