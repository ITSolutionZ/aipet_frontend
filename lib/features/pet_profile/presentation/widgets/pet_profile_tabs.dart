import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_edit_fields.dart';
import 'pet_profile_card.dart';

/// 기본 정보 탭
class AboutTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final Map<String, dynamic> editingValues;
  final String? selectedImagePath;
  final VoidCallback? onImageTap;
  final Function(String, dynamic)? onValueChanged;
  final Map<String, TextEditingController> controllers;

  const AboutTab({
    super.key,
    required this.pet,
    this.isEditMode = false,
    this.editingValues = const {},
    this.selectedImagePath,
    this.onImageTap,
    this.onValueChanged,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 펫 기본 정보
          PetProfileHeader(
            imagePath: pet.imagePath,
            selectedImagePath: selectedImagePath,
            name: pet.name,
            typeAndBreed: '${_getTypeString(pet.type)} | ${pet.breed}',
            isEditMode: isEditMode,
            onImageTap: onImageTap,
            nameWidget: isEditMode
                ? NameEditField(controller: controllers['name']!)
                : null,
          ),

          const SizedBox(height: AppSpacing.xl),

          // 외모 및 특징
          _buildSection(
            '外観と特徴的な特徴',
            isEditMode
                ? EditableTextField(
                    controller: controllers['appearance']!,
                    hintText: 'ペットの外観や特徴を入力してください',
                    maxLines: 3,
                    onChanged: (value) =>
                        onValueChanged?.call('appearance', value),
                  )
                : Text(
                    pet.customFields?['appearance']?.toString() ??
                        'No appearance description available',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.8),
                    ),
                  ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 주요 속성
          _buildSection('重要な属性', null),
          const SizedBox(height: AppSpacing.md),

          EditableAttributeCard(
            label: '性別',
            value: _getGenderString(
              isEditMode
                  ? editingValues['gender']
                  : pet.customFields?['gender'],
            ),
            isEditMode: isEditMode,
            editWidget: isEditMode
                ? GenderDropdown(
                    value: editingValues['gender'],
                    onChanged: (value) => onValueChanged?.call('gender', value),
                  )
                : null,
          ),

          const SizedBox(height: AppSpacing.sm),

          EditableAttributeCard(
            label: 'サイズ',
            value: _getSizeString(
              isEditMode ? editingValues['size'] : pet.customFields?['size'],
            ),
            isEditMode: isEditMode,
            editWidget: isEditMode
                ? SizeDropdown(
                    value: editingValues['size'],
                    onChanged: (value) => onValueChanged?.call('size', value),
                  )
                : null,
          ),

          const SizedBox(height: AppSpacing.sm),

          EditableAttributeCard(
            label: '体重',
            value: _getWeightString(
              isEditMode ? editingValues['weight'] : pet.healthInfo?.weight,
            ),
            isEditMode: isEditMode,
            editWidget: isEditMode
                ? WeightInputField(
                    controller: controllers['weight']!,
                    onChanged: (value) => onValueChanged?.call('weight', value),
                  )
                : null,
          ),

          const SizedBox(height: AppSpacing.xl),

          // 마이크로칩 정보
          _buildSection('マイクロチップ情報', null),
          const SizedBox(height: AppSpacing.md),

          PetProfileCard(
            label: 'マイクロチップ番号',
            value: isEditMode
                ? controllers['microchip']!.text.isEmpty
                      ? '未登録'
                      : controllers['microchip']!.text
                : pet.customFields?['microchipId']?.toString().isEmpty ?? true
                ? '未登録'
                : pet.customFields!['microchipId'].toString(),
            icon: Icons.memory,
            iconColor: AppColors.pointGreen,
            trailing: isEditMode
                ? SizedBox(
                    width: 150,
                    child: EditableTextField(
                      controller: controllers['microchip']!,
                      hintText: 'マイクロチップ番号を入力',
                      onChanged: (value) =>
                          onValueChanged?.call('microchipId', value),
                    ),
                  )
                : null,
          ),

          const SizedBox(height: AppSpacing.xl),

          // 중요 날짜
          _buildSection('重要な日付', null),
          const SizedBox(height: AppSpacing.md),

          DateInfoCard(
            icon: Icons.cake,
            label: '誕生日',
            date: _formatDate(pet.birthDate),
            additionalInfo: _calculateAge(pet.birthDate),
          ),

          const SizedBox(height: AppSpacing.sm),

          DateInfoCard(
            icon: Icons.home,
            label: '領養日',
            date: _getArrivalDateString(pet.customFields?['arrivalDate']),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 보호자
          _buildSection('飼い主', null),
          const SizedBox(height: AppSpacing.md),

          PetProfileCard(
            label: pet.ownerId,
            value: 'owner@example.com',
            icon: Icons.person,
            iconColor: AppColors.pointBrown,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (content != null) ...[
          const SizedBox(height: AppSpacing.sm),
          content,
        ],
      ],
    );
  }

  String _getTypeString(String type) {
    switch (type) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      default:
        return type;
    }
  }

  String _getGenderString(dynamic genderValue) {
    if (genderValue == null) return '未設定';
    if (genderValue == 'male') return 'オス';
    if (genderValue == 'female') return 'メス';
    return genderValue.toString();
  }

  String _getSizeString(dynamic sizeValue) {
    if (sizeValue == null) return '未設定';
    if (sizeValue == 'small') return '小型';
    if (sizeValue == 'medium') return '中型';
    if (sizeValue == 'large') return '大型';
    return sizeValue.toString();
  }

  String _getWeightString(dynamic weightValue) {
    if (weightValue == null) return '未設定';
    if (weightValue is num) return '${weightValue.toStringAsFixed(1)}kg';
    return weightValue.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return '$years歳';
  }

  String _getArrivalDateString(dynamic arrivalDateValue) {
    if (arrivalDateValue == null) return '未設定';

    try {
      if (arrivalDateValue is String) {
        final date = DateTime.parse(arrivalDateValue);
        return _formatDate(date);
      } else if (arrivalDateValue is DateTime) {
        return _formatDate(arrivalDateValue);
      }
      return arrivalDateValue.toString();
    } catch (e) {
      return '未設定';
    }
  }
}

/// 활동 탭
class ActivityTab extends ConsumerWidget {
  final String petId;

  const ActivityTab({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tricksState = ref.watch(allTricksProvider);

    return tricksState.when(
      data: (tricks) => _buildActivityContent(context, tricks),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('活動データの読み込み中にエラーが発生しました: $error')),
    );
  }

  Widget _buildActivityContent(BuildContext context, List<TrickEntity> tricks) {
    final learnedTricks = tricks
        .where((trick) => trick.progress != null)
        .toList();
    final availableTricks = tricks
        .where((trick) => trick.progress == null)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (learnedTricks.isNotEmpty) ...[
            Text(
              '習得したトリック',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...learnedTricks
                .take(3)
                .map((trick) => _buildTrickCard(trick, true)),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (availableTricks.isNotEmpty) ...[
            Text(
              '次に習得するトリック',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...availableTricks
                .take(2)
                .map((trick) => _buildTrickCard(trick, false)),
          ],

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 교육 영상 페이지로 이동
              },
              icon: const Icon(Icons.ondemand_video),
              label: const Text('教育動画を見る'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrickCard(TrickEntity trick, bool isLearned) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLearned
                ? AppColors.pointGreen.withValues(alpha: 0.1)
                : AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isLearned ? Icons.check : Icons.school,
            color: isLearned ? AppColors.pointGreen : AppColors.pointBlue,
            size: 20,
          ),
        ),
        title: Text(
          trick.name,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Text(
          isLearned
              ? '完了! (${trick.progress ?? 0}%)'
              : trick.description ?? '説明なし',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
        trailing: isLearned
            ? const Icon(Icons.check_circle, color: AppColors.pointGreen)
            : const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.pointGray,
                size: 16,
              ),
      ),
    );
  }
}
