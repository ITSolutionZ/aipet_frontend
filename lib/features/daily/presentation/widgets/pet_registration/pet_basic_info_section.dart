import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 기본 정보 입력 섹션
class PetBasicInfoSection extends StatelessWidget {
  final TextEditingController petNameController;
  final TextEditingController birthDateController;
  final TextEditingController adoptionDateController;
  final TextEditingController weightController;
  final TextEditingController appearanceController;
  final DateTime? selectedBirthDate;
  final DateTime? selectedAdoptionDate;
  final VoidCallback onBirthDateTap;
  final VoidCallback onAdoptionDateTap;
  final String? Function(String?)? petNameValidator;
  final String? Function(String?)? birthDateValidator;
  final String? Function(String?)? adoptionDateValidator;
  final String? Function(String?)? weightValidator;
  final String? Function(String?)? appearanceValidator;
  final Function(String)? onAppearanceChanged;

  const PetBasicInfoSection({
    super.key,
    required this.petNameController,
    required this.birthDateController,
    required this.adoptionDateController,
    required this.weightController,
    required this.appearanceController,
    required this.selectedBirthDate,
    required this.selectedAdoptionDate,
    required this.onBirthDateTap,
    required this.onAdoptionDateTap,
    this.petNameValidator,
    this.birthDateValidator,
    this.adoptionDateValidator,
    this.weightValidator,
    this.appearanceValidator,
    this.onAppearanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 펫 이름
        _buildRequiredFieldLabel('名前'),
        const SizedBox(height: AppSpacing.sm),
        CommonFormField(
          controller: petNameController,
          label: '',
          hint: '名前を入力してください（最大10文字）',
          validator: petNameValidator,
        ),
        const SizedBox(height: AppSpacing.lg),

        // 생년월일
        _buildRequiredFieldLabel('生年月日'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: CommonFormField(
                controller: birthDateController,
                label: '',
                hint: '2020-02-19',
                validator: birthDateValidator,
                readOnly: true,
                onTap: onBirthDateTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onBirthDateTap,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 집에 온 날
        _buildOptionalFieldLabel('お迎えした日'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: CommonFormField(
                controller: adoptionDateController,
                label: '',
                hint: '2023-05-15',
                validator: adoptionDateValidator,
                readOnly: true,
                onTap: onAdoptionDateTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onAdoptionDateTap,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 몸무게
        _buildOptionalFieldLabel('体重'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: CommonFormField(
                controller: weightController,
                label: '',
                hint: '例）3.23',
                keyboardType: TextInputType.number,
                validator: weightValidator,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'kg',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '1kg未満の場合、例：750gなら0.75と入力',
          style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 외견
        _buildOptionalFieldLabel('外見'),
        const SizedBox(height: AppSpacing.sm),
        CommonFormField(
          controller: appearanceController,
          label: '',
          hint: '例）茶色の毛、白い斑点、長い耳など',
          maxLines: 3,
          validator: appearanceValidator,
          onChanged: onAppearanceChanged,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'ペットの外見的特徴を記述してください',
          style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRequiredFieldLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.pointRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalFieldLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
