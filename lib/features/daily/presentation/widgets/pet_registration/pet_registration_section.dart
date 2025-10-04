import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 등록증 정보 섹션
class PetRegistrationSection extends StatelessWidget {
  final TextEditingController guardianNameController;
  final TextEditingController registrationNumberController;
  final VoidCallback onRegistrationImageTap;

  const PetRegistrationSection({
    super.key,
    required this.guardianNameController,
    required this.registrationNumberController,
    required this.onRegistrationImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '動物登録証',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '動物登録証情報を写真と一緒に管理してみましょう。',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CommonFormField(
                  controller: guardianNameController,
                  label: '',
                  hint: '保護者名前',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CommonFormField(
                  controller: registrationNumberController,
                  label: '',
                  hint: '登録番号入力',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.borderGray,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: onRegistrationImageTap,
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
