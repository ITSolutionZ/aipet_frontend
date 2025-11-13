import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알레르기 화면용 펫 선택 위젯
class AllergyPetSelector extends StatelessWidget {
  final PetProfileEntity? selectedPet;
  final List<PetProfileEntity> pets;
  final ValueChanged<PetProfileEntity> onPetSelected;

  const AllergyPetSelector({
    super.key,
    required this.selectedPet,
    required this.pets,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayPet = selectedPet ?? pets.first;

    return GestureDetector(
      onTap: () => _showPetSelectionModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: AppColors.pointBrown.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 펫 이미지
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.pureWhite,
              backgroundImage: displayPet.imagePath != null
                  ? AssetImage(displayPet.imagePath!)
                  : const AssetImage('assets/icons/aipet_logo.png'),
            ),
            const SizedBox(width: AppSpacing.xs),
            // 펫 이름
            Text(
              displayPet.name,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            // 드롭다운 아이콘
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.pointGray,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showPetSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PetSelectionBottomSheet(
        pets: pets,
        selectedPet: selectedPet,
        onPetSelected: (pet) {
          onPetSelected(pet);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// 펫 선택 바텀시트
class _PetSelectionBottomSheet extends StatelessWidget {
  final List<PetProfileEntity> pets;
  final PetProfileEntity? selectedPet;
  final ValueChanged<PetProfileEntity> onPetSelected;

  const _PetSelectionBottomSheet({
    required this.pets,
    required this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // 화면 높이의 70%로 제한
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'ペットを選択',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 펫 목록 (스크롤 가능)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  ...pets.map((pet) => _buildPetOption(pet)),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetOption(PetProfileEntity pet) {
    final isSelected = selectedPet?.id == pet.id;

    return InkWell(
      onTap: () => onPetSelected(pet),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 펫 이미지
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.pureWhite,
              backgroundImage: pet.imagePath != null
                  ? AssetImage(pet.imagePath!)
                  : const AssetImage('assets/icons/aipet_logo.png'),
            ),
            const SizedBox(width: AppSpacing.md),
            // 펫 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppFonts.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                  Text(
                    '${pet.breed ?? '品種不明'} • ${_formatAge(pet.birthDate)}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            // 선택 표시
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pointBrown,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime? birthDate) {
    if (birthDate == null) return '年齢不明';

    final now = DateTime.now();
    final age = now.year - birthDate.year;
    final months = now.month - birthDate.month;

    if (age == 0) {
      return '$monthsヶ月';
    } else if (months < 0) {
      return '${age - 1}歳';
    } else {
      return '$age歳';
    }
  }
}
