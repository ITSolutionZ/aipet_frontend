import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration/pet_registration_form_data.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/pet_registration/pet_registration_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 등록 폼 컨텐츠
class RegistrationFormContent extends ConsumerWidget {
  final PetRegistrationFormData formData;
  final PetRegistrationController controller;
  final VoidCallback onBirthDateTap;
  final VoidCallback onAdoptionDateTap;
  final VoidCallback onImageSelection;
  final VoidCallback onRegistrationImageSelection;

  const RegistrationFormContent({
    super.key,
    required this.formData,
    required this.controller,
    required this.onBirthDateTap,
    required this.onAdoptionDateTap,
    required this.onImageSelection,
    required this.onRegistrationImageSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          PetImageSection(
            petImagePath: formData.petImagePath,
            isLoading: formData.isImageLoading,
            onImageTap: onImageSelection,
          ),
          _buildSectionDivider(),
          PetBasicInfoSection(
            petNameController: controller.petNameController,
            birthDateController: controller.birthDateController,
            adoptionDateController: controller.adoptionDateController,
            weightController: controller.weightController,
            appearanceController: controller.appearanceController,
            selectedBirthDate: formData.birthDate,
            selectedAdoptionDate: formData.adoptionDate,
            onBirthDateTap: onBirthDateTap,
            onAdoptionDateTap: onAdoptionDateTap,
            petNameValidator: controller.validatePetName,
            birthDateValidator: controller.validateBirthDate,
            adoptionDateValidator: controller.validateAdoptionDate,
            weightValidator: controller.validateWeight,
            appearanceValidator: controller.validateAppearance,
            onAppearanceChanged: controller.updateAppearance,
          ),
          _buildSectionDivider(),
          PetTypeSection(
            selectedPetType: formData.petType,
            onPetTypeChanged: controller.updatePetType,
          ),
          _buildSectionDivider(),
          PetBreedSection(
            selectedPetType: formData.petType,
            selectedBreed: formData.breed,
            onBreedChanged: controller.updateBreed,
          ),
          _buildSectionDivider(),
          PetGenderSection(
            selectedGender: formData.gender,
            isNeutered: formData.isNeutered,
            onGenderChanged: controller.updateGender,
            onNeuteringChanged: controller.updateNeuteringStatus,
          ),
          _buildSectionDivider(),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(petRegistrationControllerProvider);
              return PetRegistrationSection(
                guardianNameController: controller.guardianNameController,
                institutionNameController: controller.institutionNameController,
                registrationNumberController:
                    controller.registrationNumberController,
                onRegistrationImageTap: onRegistrationImageSelection,
                registrationImagePath: state.registrationImagePath,
                isProcessingOCR: state.isProcessingOCR,
              );
            },
          ),
          _buildSectionDivider(),
          PetFoodSection(
            selectedFood: formData.food,
            selectedSupplement: formData.supplement,
            selectedTreat: formData.treat,
            onFoodChanged: controller.updateFood,
            onSupplementChanged: controller.updateSupplement,
            onTreatChanged: controller.updateTreat,
          ),
          _buildSectionDivider(),
          Consumer(
            builder: (context, ref, child) {
              final controllerNotifier = ref.watch(
                petRegistrationControllerProvider.notifier,
              );
              final state = ref.watch(petRegistrationControllerProvider);

              return PetIngredientsSection(
                forbiddenIngredients: state.forbiddenIngredients,
                onAddIngredient: (ingredient, context) {
                  controllerNotifier.addForbiddenIngredientWithNotification(
                    ingredient,
                    context,
                  );
                },
                onRemoveIngredient: (ingredient) {
                  controllerNotifier.removeForbiddenIngredient(ingredient);
                },
              );
            },
          ),
          _buildSectionDivider(),
          Consumer(
            builder: (context, ref, child) {
              final controllerNotifier = ref.watch(
                petRegistrationControllerProvider.notifier,
              );
              final state = ref.watch(petRegistrationControllerProvider);

              return PetBodyPartsSection(
                bodyPartsToManage: state.bodyPartsToManage,
                onUpdateBodyParts: (bodyParts) {
                  controllerNotifier.updateBodyPartsToManage(bodyParts);
                },
                onClearBodyParts: () {
                  controllerNotifier.clearBodyPartsToManage();
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// 섹션 구분선
  Widget _buildSectionDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Divider(
        color: AppColors.borderGray.withValues(alpha: 0.2),
        thickness: 1,
        height: 1,
      ),
    );
  }
}
