import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/pet_registor.dart';

/// AI 상담을 위한 펫 선택 위젯
class AiPetSelection extends StatelessWidget {
  final List<PetProfileEntity> pets;
  final PetProfileEntity? selectedPet;
  final Function(PetProfileEntity?) onPetSelected;
  final VoidCallback? onAddPet;

  const AiPetSelection({
    super.key,
    required this.pets,
    this.selectedPet,
    required this.onPetSelected,
    this.onAddPet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'どのペットについて相談しますか？',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (pets.isEmpty) _buildNoPetsCard() else _buildPetSelectionGrid(),

          const SizedBox(height: AppSpacing.sm),
          _buildGeneralConsultationOption(),
        ],
      ),
    );
  }

  Widget _buildNoPetsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets_outlined,
            size: 48,
            color: AppColors.pointBrown.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '登録されたペットがありません',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ペットを登録すると、より具体的な\nアドバイスが受けられます',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          if (onAddPet != null)
            ElevatedButton.icon(
              onPressed: onAddPet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ペットを登録する'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionGrid() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: pets.map((pet) => _buildPetChip(pet)).toList(),
    );
  }

  Widget _buildPetChip(PetProfileEntity pet) {
    final isSelected = selectedPet?.id == pet.id;

    return GestureDetector(
      onTap: () => onPetSelected(isSelected ? null : pet),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pointBrown : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AiColors.selectedBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AiColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pet.imagePath != null && pet.imagePath!.isNotEmpty)
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(pet.imagePath!),
              )
            else
              Icon(
                pet.type == 'dog' ? Icons.pets : Icons.pets_outlined,
                size: 20,
                color: isSelected ? AppColors.pureWhite : AppColors.pointBrown,
              ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pet.name,
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pureWhite
                        : AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${pet.typeName} • ${pet.age}歳',
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pureWhite.withValues(alpha: 0.9)
                        : AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralConsultationOption() {
    final isGeneralSelected = selectedPet == null;

    return GestureDetector(
      onTap: () => onPetSelected(null),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isGeneralSelected
              ? AiColors.petSelectionBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isGeneralSelected
                ? AppColors.pointBrown
                : AiColors.unselectedBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.help_outline,
              size: 20,
              color: isGeneralSelected
                  ? AppColors.pointBrown
                  : AppColors.pointDark.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '一般的なペット相談',
              style: AppFonts.bodySmall.copyWith(
                color: isGeneralSelected
                    ? AppColors.pointBrown
                    : AppColors.pointDark.withValues(alpha: 0.8),
                fontWeight: isGeneralSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
