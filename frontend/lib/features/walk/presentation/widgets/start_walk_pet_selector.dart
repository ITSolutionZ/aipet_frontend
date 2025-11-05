import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 산책 시작 시 펫 선택 위젯
class StartWalkPetSelector extends StatelessWidget {
  final String selectedPetId;
  final Function(String) onSelectPet;

  const StartWalkPetSelector({
    super.key,
    required this.selectedPetId,
    required this.onSelectPet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildPetOption(
            'pet1',
            'Maxi',
            Icons.pets,
            '元気な柴犬',
            selectedPetId,
            onSelectPet,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPetOption(
            'pet2',
            'Luna',
            Icons.pets,
            '優しいゴールデン',
            selectedPetId,
            onSelectPet,
          ),
        ],
      ),
    );
  }

  Widget _buildPetOption(
    String petId,
    String name,
    IconData icon,
    String description,
    String selectedPetId,
    Function(String) onSelectPet,
  ) {
    final isSelected = selectedPetId == petId;

    return GestureDetector(
      onTap: () => onSelectPet(petId),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBlue.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pointBlue : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.baseSize,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.pointBlue
                          : Colors.grey[800],
                    ),
                  ),
                  Text(
                    description,
                    style: AppFonts.base(
                      fontSize: AppFonts.sm,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pointBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
