import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';
import '../../data/walk_providers.dart';

class PetSelectorWidget extends StatelessWidget {
  final PetInfo? selectedPet;
  final Function(PetInfo) onPetSelected;

  const PetSelectorWidget({
    super.key,
    this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPetSelector(context),
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
            // 반려동물 이미지
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.pointBrown.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  selectedPet?.imagePath ?? 'assets/images/dogs/shiba.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.pets,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // 반려동물 이름
            Text(
              selectedPet?.name ?? 'Maxi',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // 드롭다운 아이콘
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.pointGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPetSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PetSelectorBottomSheet(
        selectedPet: selectedPet,
        onPetSelected: onPetSelected,
      ),
    );
  }
}

class _PetSelectorBottomSheet extends StatelessWidget {
  final PetInfo? selectedPet;
  final Function(PetInfo) onPetSelected;

  const _PetSelectorBottomSheet({
    this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final pets = [
      const PetInfo(
        id: 'pet1',
        name: 'Maxi',
        imagePath: 'assets/images/dogs/shiba.png',
      ),
      const PetInfo(
        id: 'pet2',
        name: 'Luna',
        imagePath: 'assets/images/dogs/poodle.jpg',
      ),
      const PetInfo(
        id: 'pet3',
        name: 'Buddy',
        imagePath: 'assets/images/dogs/chiwawa.png',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '반려동물 선택',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...pets.map((pet) => _buildPetOption(context, pet)),
        ],
      ),
    );
  }

  Widget _buildPetOption(BuildContext context, PetInfo pet) {
    final isSelected = selectedPet?.id == pet.id;

    return GestureDetector(
      onTap: () {
        onPetSelected(pet);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointBrown : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 반려동물 이미지
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.pointBrown : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  pet.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.pets,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // 반려동물 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppFonts.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.pointBrown
                          : AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '산책 기록 보기',
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
}
