import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// 펫 등록증 정보 섹션
class PetRegistrationSection extends StatelessWidget {
  final TextEditingController guardianNameController;
  final TextEditingController institutionNameController;
  final TextEditingController registrationNumberController;
  final VoidCallback onRegistrationImageTap;
  final String? registrationImagePath;
  final bool isProcessingOCR;

  const PetRegistrationSection({
    super.key,
    required this.guardianNameController,
    required this.institutionNameController,
    required this.registrationNumberController,
    required this.onRegistrationImageTap,
    this.registrationImagePath,
    this.isProcessingOCR = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredFieldLabel('動物登録証'),
        const SizedBox(height: AppSpacing.lg),

        // 보호자명
        CommonFormField(
          controller: guardianNameController,
          label: '飼い主名',
          hint: '飼い主名を入力してください',
          validator: (value) => value?.isEmpty == true ? '飼い主名を入力してください' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // 기관명
        CommonFormField(
          controller: institutionNameController,
          label: '機関名',
          hint: '登録機関名を入力してください',
          validator: (value) => value?.isEmpty == true ? '機関名を入力してください' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // 등록번호
        CommonFormField(
          controller: registrationNumberController,
          label: '登録番号',
          hint: '登録番号を入力してください',
          validator: (value) => value?.isEmpty == true ? '登録番号を入力してください' : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // 등록증 이미지 업로드
        _buildImageUploadSection(context),
      ],
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: InkWell(
        onTap: onRegistrationImageTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (isProcessingOCR) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'OCR処理中...',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else if (registrationImagePath != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    image: DecorationImage(
                      image: FileImage(File(registrationImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // 이미지 제거 로직 (상위에서 처리)
                      },
                      icon: const Icon(Icons.delete, color: AppColors.pointRed),
                      label: const Text('削除'),
                    ),
                    TextButton.icon(
                      onPressed: onRegistrationImageTap,
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      label: const Text('変更'),
                    ),
                  ],
                ),
              ] else ...[
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '登録証画像をアップロードしてください',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'OCRで自動的に情報を抽出します',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredFieldLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '*',
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointRed,
          ),
        ),
      ],
    );
  }
}
