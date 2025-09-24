import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_form_controller.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pet Profile 기본 정보 편집 폼
class PetProfileBasicInfoForm extends ConsumerWidget {
  final PetProfileEntity pet;
  final VoidCallback? onImageTap;

  const PetProfileBasicInfoForm({
    super.key,
    required this.pet,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(petProfileFormControllerProvider);
    final formController = ref.read(petProfileFormControllerProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // 프로필 이미지
            _buildProfileImage(context, formState),
            const SizedBox(height: AppSpacing.lg),

            // 이름 필드
            if (formState.isEditMode) ...[
              AppTextField(
                controller: formState.nameController,
                label: '이름',
                hintText: '펫의 이름을 입력하세요',
                prefixIcon: const Icon(Icons.pets),
              ),
              const SizedBox(height: AppSpacing.md),
            ] else ...[
              _buildInfoRow('이름', pet.name, Icons.pets),
              const SizedBox(height: AppSpacing.md),
            ],

            // 품종 필드
            if (formState.isEditMode) ...[
              AppTextField(
                controller: formState.breedController,
                label: '품종',
                hintText: '품종을 입력하세요',
                prefixIcon: const Icon(Icons.category),
              ),
              const SizedBox(height: AppSpacing.md),
            ] else ...[
              _buildInfoRow('품종', pet.breed ?? '미등록', Icons.category),
              const SizedBox(height: AppSpacing.md),
            ],

            // 성별 선택
            _buildGenderSelection(context, formState, formController),
            const SizedBox(height: AppSpacing.md),

            // 타입 선택
            _buildTypeSelection(context, formState, formController),
            const SizedBox(height: AppSpacing.md),

            // 몸무게 필드
            if (formState.isEditMode) ...[
              AppTextField(
                controller: formState.weightController,
                label: '몸무게 (kg)',
                hintText: '몸무게를 입력하세요',
                prefixIcon: const Icon(Icons.monitor_weight),
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              _buildInfoRow('몸무게', '${pet.weight}kg', Icons.monitor_weight),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    PetProfileFormState formState,
  ) {
    final imagePath = formState.isEditMode
        ? formState.selectedImagePath ?? pet.imagePath
        : pet.imagePath;

    return GestureDetector(
      onTap: formState.isEditMode ? onImageTap : null,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.pointBrown, width: 3),
        ),
        child: ClipOval(
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.pointOffWhite,
                      child: const Icon(
                        Icons.pets,
                        size: 60,
                        color: AppColors.pointBrown,
                      ),
                    );
                  },
                )
              : Container(
                  color: AppColors.pointOffWhite,
                  child: const Icon(
                    Icons.pets,
                    size: 60,
                    color: AppColors.pointBrown,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.pointBrown, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.pointDark,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(
    BuildContext context,
    PetProfileFormState formState,
    PetProfileFormController formController,
  ) {
    if (!formState.isEditMode) {
      return _buildInfoRow(
        '성별',
        pet.gender == 'male' ? '수컷' : '암컷',
        Icons.pets,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('수컷'),
                value: 'male',
                groupValue: formState.editingGender ?? pet.gender,
                onChanged: formController.updateGender,
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('암컷'),
                value: 'female',
                groupValue: formState.editingGender ?? pet.gender,
                onChanged: formController.updateGender,
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSelection(
    BuildContext context,
    PetProfileFormState formState,
    PetProfileFormController formController,
  ) {
    if (!formState.isEditMode) {
      return _buildInfoRow('타입', pet.typeName, Icons.category);
    }

    final types = [
      {'value': 'dog', 'label': '강아지'},
      {'value': 'cat', 'label': '고양이'},
      {'value': 'bird', 'label': '새'},
      {'value': 'hamster', 'label': '햄스터'},
      {'value': 'rabbit', 'label': '토끼'},
      {'value': 'turtle', 'label': '거북이'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '타입',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: formState.editingType ?? pet.type,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: types.map((type) {
            return DropdownMenuItem<String>(
              value: type['value'],
              child: Text(type['label']!),
            );
          }).toList(),
          onChanged: formController.updateType,
        ),
      ],
    );
  }
}
