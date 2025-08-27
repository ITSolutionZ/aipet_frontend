import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import 'pet_selection_card.dart';

/// 펫 선택 그리드 위젯
class PetSelectionGrid extends StatelessWidget {
  final String selectedPetId;
  final List<String> selectedStatuses;
  final ValueChanged<String> onPetSelected;
  final Function(String, Map<String, dynamic>) onPetStatusDialog;

  const PetSelectionGrid({
    super.key,
    required this.selectedPetId,
    required this.selectedStatuses,
    required this.onPetSelected,
    required this.onPetStatusDialog,
  });

  @override
  Widget build(BuildContext context) {
    final petSizes = MockDataService.getMockPetSizesAndFeedingAmounts();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペット選択',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: petSizes.entries.map((entry) {
                final petId = entry.key;
                final petInfo = entry.value;
                final isSelected = petId == selectedPetId;

                return PetSelectionCard(
                  petId: petId,
                  petInfo: petInfo,
                  isSelected: isSelected,
                  selectedStatuses: isSelected ? selectedStatuses : [],
                  onTap: () => onPetSelected(petId),
                  onLongPress: () => onPetStatusDialog(petId, petInfo),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
