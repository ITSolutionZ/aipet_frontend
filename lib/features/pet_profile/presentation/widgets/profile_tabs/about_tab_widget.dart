import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import '../../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../../controllers/pet_profile_controllers.dart';
import '../profile_cards/caretaker_card.dart';
import '../profile_cards/date_card.dart';
import '../profile_cards/editable_attribute_card.dart';
import '../profile_cards/microchip_card.dart';

class AboutTabWidget extends ConsumerStatefulWidget {
  final bool isEditMode;
  final TextEditingController nameController;
  final TextEditingController appearanceController;
  final TextEditingController? microchipController;
  final TextEditingController? weightController;
  final String? selectedImagePath;
  final String? editingGender;
  final String? editingSize;
  final double? editingWeight;
  final VoidCallback onImageSourceSelection;
  final Function(String?)? onGenderChanged;
  final Function(String?)? onSizeChanged;
  final Function(double?)? onWeightChanged;

  const AboutTabWidget({
    super.key,
    required this.isEditMode,
    required this.nameController,
    required this.appearanceController,
    this.microchipController,
    this.weightController,
    this.selectedImagePath,
    this.editingGender,
    this.editingSize,
    this.editingWeight,
    required this.onImageSourceSelection,
    this.onGenderChanged,
    this.onSizeChanged,
    this.onWeightChanged,
  });

  @override
  ConsumerState<AboutTabWidget> createState() => _AboutTabWidgetState();
}

class _AboutTabWidgetState extends ConsumerState<AboutTabWidget> {
  String _getGenderString(dynamic gender) {
    if (gender == null) return '未設定';
    return gender == 'male' ? 'オス' : 'メス';
  }

  String _getSizeString(dynamic size) {
    if (size == null) return '未設定';
    switch (size) {
      case 'small':
        return '小型';
      case 'medium':
        return '中型';
      case 'large':
        return '大型';
      default:
        return size.toString();
    }
  }

  String _getWeightString(dynamic weight) {
    if (weight == null) return '未設定';
    return '${weight}kg';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(petProfileNotifierProvider);
        final pet = state.selectedPet;

        if (pet == null) {
          return const Center(child: Text('Pet data not available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ペット基本情報
              _buildPetBasicInfo(pet),
              const SizedBox(height: AppSpacing.xl),

              // 外見と特徴
              _buildAppearanceSection(pet),
              const SizedBox(height: AppSpacing.xl),

              // 主要属性
              _buildMainAttributesSection(pet),
              const SizedBox(height: AppSpacing.xl),

              // マイクロチップ情報
              _buildMicrochipSection(pet),
              const SizedBox(height: AppSpacing.xl),

              // 記念日情報
              _buildAnniversarySection(pet),
              const SizedBox(height: AppSpacing.xl),

              // 保護者情報
              _buildCaretakerSection(pet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPetBasicInfo(PetProfileEntity pet) {
    return Row(
      children: [
        // プロフィール写真
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              backgroundImage: (widget.selectedImagePath ?? pet.imagePath) != null
                  ? AssetImage(widget.selectedImagePath ?? pet.imagePath!)
                  : null,
              child: (widget.selectedImagePath ?? pet.imagePath) == null
                  ? const Icon(
                      Icons.pets,
                      size: 50,
                      color: AppColors.pointBrown,
                    )
                  : null,
            ),
            if (widget.isEditMode)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: widget.onImageSourceSelection,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.pointBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),

        // 名前と種類
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.isEditMode)
                    Expanded(
                      child: TextField(
                        controller: widget.nameController,
                        style: AppFonts.titleLarge.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      pet.name,
                      style: AppFonts.titleLarge.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.pointBlue,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${pet.type == 'dog' ? '犬' : pet.type == 'cat' ? '猫' : pet.type} | ${pet.breed}',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(PetProfileEntity pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '外観と特徴的な特徴',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (widget.isEditMode)
          TextField(
            controller: widget.appearanceController,
            maxLines: 3,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.8),
            ),
            decoration: InputDecoration(
              hintText: 'ペットの外観や特徴を入力してください',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          )
        else
          Text(
            pet.additionalInfo?['appearance'] ?? 'No appearance description available',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildMainAttributesSection(PetProfileEntity pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '重要な属性',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        EditableAttributeCard(
          label: '性別',
          value: _getGenderString(widget.isEditMode ? widget.editingGender : pet.additionalInfo?['gender']),
          type: 'gender',
          isEditMode: widget.isEditMode,
          onGenderChanged: widget.onGenderChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        EditableAttributeCard(
          label: 'サイズ',
          value: _getSizeString(widget.isEditMode ? widget.editingSize : pet.additionalInfo?['size']),
          type: 'size',
          isEditMode: widget.isEditMode,
          onSizeChanged: widget.onSizeChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        EditableAttributeCard(
          label: '体重',
          value: _getWeightString(widget.isEditMode ? widget.editingWeight : pet.additionalInfo?['weight']),
          type: 'weight',
          isEditMode: widget.isEditMode,
          onWeightChanged: widget.onWeightChanged,
          weightController: widget.weightController,
        ),
      ],
    );
  }

  Widget _buildMicrochipSection(PetProfileEntity pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'マイクロチップ情報',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        MicrochipCard(
          pet: pet,
          isEditMode: widget.isEditMode,
          microchipController: widget.microchipController,
        ),
      ],
    );
  }

  Widget _buildAnniversarySection(PetProfileEntity pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記念日',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DateCard(
          title: '誕生日',
          date: pet.birthDate,
          icon: Icons.cake,
          color: AppColors.pointPink,
        ),
        const SizedBox(height: AppSpacing.sm),
        DateCard(
          title: '家に来た日',
          date: pet.additionalInfo?['arrivalDate'] as DateTime?,
          icon: Icons.home,
          color: AppColors.pointBlue,
        ),
      ],
    );
  }

  Widget _buildCaretakerSection(PetProfileEntity pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '保護者',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CaretakerCard(
          ownerId: pet.ownerId,
          email: 'owner@example.com',
          name: pet.ownerId,
        ),
      ],
    );
  }
}