import 'package:aipet_frontend/features/pet_profile/presentation/constants/pet_profile_constants.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_unified_controller.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/common/pet_info_card_widget.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/common/pet_profile_image_widget.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/dialogs/pet_edit_dialogs.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 리팩토링된 Pet Basic Info 탭
///
/// Clean Architecture를 적용하여 로직과 UI를 분리했습니다.
/// 재사용 가능한 컴포넌트들을 사용하여 유지보수성을 높였습니다.
class PetBasicInfoTabRefactored extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetBasicInfoTabRefactored({
    super.key,
    required this.pet,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildProfileImageSection(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildProfileHeaderCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildBasicInfoCards(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildMicrochipCard(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildAgeCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildCaretakerSection(),
          if (isEditMode) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(context, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(BuildContext context, WidgetRef ref) {
    return PetProfileImageWidget(
      imagePath: pet.imagePath,
      isEditMode: isEditMode,
      onImageTap: () => _showImageSelectionDialog(context, ref),
    );
  }

  Widget _buildProfileHeaderCard() {
    final genderColor = _getGenderColor(pet.gender);
    final petTypeIcon = _getPetTypeIcon(pet.type);

    return PetProfileHeaderCardWidget(
      petName: pet.name,
      petType: _getPetTypeName(pet.type),
      breed: pet.breed,
      gender: _getGenderDisplayName(pet.gender),
      genderColor: genderColor,
      petTypeIcon: petTypeIcon,
    );
  }

  Widget _buildBasicInfoCards(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildEditableInfoCard(
          context,
          ref,
          PetProfileConstants.nameLabel,
          pet.name,
          Icons.badge,
          'name',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableInfoCard(
          context,
          ref,
          PetProfileConstants.genderLabel,
          _getGenderDisplayName(pet.gender),
          Icons.wc,
          'gender',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableInfoCard(
          context,
          ref,
          PetProfileConstants.weightLabel,
          '${pet.weight}kg',
          Icons.monitor_weight,
          'weight',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableInfoCard(
          context,
          ref,
          PetProfileConstants.appearanceLabel,
          pet.additionalInfo?['appearance'] ??
              PetProfileConstants.defaultAppearance,
          Icons.palette,
          'appearance',
        ),
      ],
    );
  }

  Widget _buildEditableInfoCard(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    IconData icon,
    String fieldType,
  ) {
    return EditablePetInfoCardWidget(
      icon: icon,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      title: label,
      subtitle: value,
      isEditMode: isEditMode,
      onEdit: () => _editField(context, ref, fieldType),
    );
  }

  Widget _buildMicrochipCard(BuildContext context, WidgetRef ref) {
    return PetMicrochipCardWidget(
      microchipId: pet.additionalInfo?['microchipId'],
      isEditMode: isEditMode,
      onEdit: () => _editField(context, ref, 'microchip'),
    );
  }

  Widget _buildAgeCard() {
    final age = _calculateAge(pet.birthDate);
    return PetAgeCardWidget(birthDate: pet.birthDate, age: age);
  }

  Widget _buildCaretakerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PetProfileConstants.caretakerLabel,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCaretakerCard('田中 太郎', 'tanaka@example.com'),
        const SizedBox(height: AppSpacing.sm),
        _buildCaretakerCard('田中 花子', 'hanako@example.com'),
      ],
    );
  }

  Widget _buildCaretakerCard(String name, String email) {
    return PetInfoCardWidget.withIcon(
      icon: Icons.person,
      iconColor: AppColors.pointGray,
      iconBackgroundColor: AppColors.pointGray.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      title: name,
      subtitle: email,
      badge: PetProfileConstants.managerStatus,
      badgeColor: AppColors.pointBrown,
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _cancelEdit(ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointBrown,
              side: const BorderSide(color: AppColors.pointBrown),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveChanges(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text(PetProfileConstants.saveLabel),
          ),
        ),
      ],
    );
  }

  void _showImageSelectionDialog(BuildContext context, WidgetRef ref) {
    PetImageSelectionDialog.show(
      context,
      onTakePhoto: () => _pickImageFromCamera(context, ref),
      onSelectFromGallery: () => _pickImageFromGallery(context, ref),
      allowRemoval: pet.imagePath != null,
      onRemove: () => _removeImage(ref),
    );
  }

  void _editField(BuildContext context, WidgetRef ref, String fieldType) {
    switch (fieldType) {
      case 'name':
        PetEditDialogs.showEditNameDialog(context, pet.name, (newName) {
          ref
              .read(petProfileUnifiedControllerProvider.notifier)
              .updateFormData('name', newName);
        });
        break;
      case 'gender':
        PetEditDialogs.showEditGenderDialog(context, pet.gender, (newGender) {
          ref
              .read(petProfileUnifiedControllerProvider.notifier)
              .updateFormData('gender', newGender);
        });
        break;
      case 'weight':
        PetEditDialogs.showEditWeightDialog(context, pet.weight, (newWeight) {
          ref
              .read(petProfileUnifiedControllerProvider.notifier)
              .updateFormData('weight', newWeight);
        });
        break;
      case 'appearance':
        PetEditDialogs.showEditAppearanceDialog(
          context,
          pet.additionalInfo?['appearance'] ?? '',
          (newAppearance) {
            ref
                .read(petProfileUnifiedControllerProvider.notifier)
                .updateFormData('appearance', newAppearance);
          },
        );
        break;
      case 'microchip':
        PetEditDialogs.showEditMicrochipDialog(
          context,
          pet.additionalInfo?['microchipId'] ?? '',
          (newMicrochip) {
            ref
                .read(petProfileUnifiedControllerProvider.notifier)
                .updateFormData('microchipId', newMicrochip);
          },
        );
        break;
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context, WidgetRef ref) async {
    final imagePath = await ImageService.pickFromCamera(context);
    if (imagePath != null && context.mounted) {
      await _uploadImage(ref, imagePath);
    }
  }

  Future<void> _pickImageFromGallery(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final imagePath = await ImageService.pickFromGallery(context);
    if (imagePath != null && context.mounted) {
      await _uploadImage(ref, imagePath);
    }
  }

  Future<void> _uploadImage(WidgetRef ref, String imagePath) async {
    await ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .uploadPetImage(imagePath);
  }

  void _removeImage(WidgetRef ref) {
    // TODO: Implement image removal
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('imagePath', null);
  }

  Future<void> _saveChanges(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(petProfileUnifiedControllerProvider.notifier);

    // Validation
    final state = ref.read(petProfileUnifiedControllerProvider);
    final formData = state.editFormData;

    if ((formData['name'] as String?)?.trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(PetProfileConstants.nameRequiredMessage),
          backgroundColor: AppColors.pointRed,
        ),
      );
      return;
    }

    if (formData['weight'] != null && (formData['weight'] as double) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(PetProfileConstants.weightPositiveMessage),
          backgroundColor: AppColors.pointRed,
        ),
      );
      return;
    }

    await controller.savePetProfile();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(PetProfileConstants.saveSuccessMessage),
          backgroundColor: AppColors.pointGreen,
        ),
      );
    }
  }

  void _cancelEdit(WidgetRef ref) {
    ref.read(petProfileUnifiedControllerProvider.notifier).cancelEdit();
  }

  // Helper methods
  String _getPetTypeIcon(String petType) {
    return PetProfileConstants.petTypeIcons[petType.toLowerCase()] ??
        PetProfileConstants.petTypeIcons['default']!;
  }

  String _getPetTypeName(String petType) {
    return PetProfileConstants.petTypeNames[petType.toLowerCase()] ??
        PetProfileConstants.petTypeNames['default']!;
  }

  String _getGenderDisplayName(String gender) {
    return PetProfileConstants.genderDisplayNames[gender.toLowerCase()] ??
        PetProfileConstants.genderDisplayNames['default']!;
  }

  Color _getGenderColor(String gender) {
    final genderLower = gender.toLowerCase();
    if (genderLower == 'male' || genderLower == 'オス') {
      return AppColors.pointBlue;
    } else if (genderLower == 'female' || genderLower == 'メス') {
      return AppColors.pointPink;
    }
    return AppColors.pointGray;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
