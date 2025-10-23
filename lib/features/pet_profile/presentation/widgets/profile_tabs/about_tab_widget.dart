import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_controller.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String _getWeightString(dynamic weight) {
    if (weight == null) return '未設定';
    return '${weight}kg';
  }

  /// 背景画像を取得 - 강화된 로컬 저장 지원
  ImageProvider? _getBackgroundImage(String? imagePath) {
    if (imagePath == null) return null;

    LoggerService.debug('🖼️ AboutTabWidget - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    LoggerService.debug('🖼️ AboutTabWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ AboutTabWidget - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ AboutTabWidget - File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug('❌ AboutTabWidget - File does not exist: $absolutePath');
          return null;
        }

        return FileImage(file);
      case ImageType.network:
        return NetworkImage(absolutePath);
      case ImageType.asset:
        return AssetImage(absolutePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(petProfileProvider);
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
              backgroundImage: _getBackgroundImage(
                widget.selectedImagePath ?? pet.imagePath,
              ),
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
                '${pet.type == 'dog'
                    ? '犬'
                    : pet.type == 'cat'
                    ? '猫'
                    : pet.type} | ${pet.breed}',
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
            pet.additionalInfo?['appearance'] ??
                'No appearance description available',
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
        _buildAttributeCard(
          '性別',
          _getGenderString(
            widget.isEditMode ? widget.editingGender : pet.gender,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildAttributeCard('サイズ', pet.size ?? '未設定'),
        const SizedBox(height: AppSpacing.sm),
        _buildAttributeCard(
          '体重',
          _getWeightString(
            widget.isEditMode ? widget.editingWeight : pet.weight,
          ),
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
        _buildAttributeCard('マイクロチップ番号', pet.microchipNumber ?? '未登録'),
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
        _buildDateCard('誕生日', pet.birthDate, Icons.cake, AppColors.pointPink),
        const SizedBox(height: AppSpacing.sm),
        _buildDateCard(
          '家に来た日',
          pet.arrivalDate,
          Icons.home,
          AppColors.pointBlue,
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
        _buildAttributeCard('保護者ID', pet.ownerId),
      ],
    );
  }

  Widget _buildAttributeCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.pointDark.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
    String title,
    DateTime? date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.pointDark.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            date != null ? '${date.year}/${date.month}/${date.day}' : '未設定',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
          ),
        ],
      ),
    );
  }
}
