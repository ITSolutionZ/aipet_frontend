import 'package:aipet_frontend/features/pet_registor/presentation/widgets/cards/pet_size_selection_card.dart';
import 'package:flutter/material.dart';

class PetSizeSelectionGroupWidget extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;

  const PetSizeSelectionGroupWidget({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PetSizeSelectionCard(
          size: 'small',
          label: 'Small',
          weightRange: '14kg以下',
          icon: Icons.pets,
          isSelected: selectedSize == 'small',
          onTap: () => onSizeSelected('small'),
        ),
        PetSizeSelectionCard(
          size: 'medium',
          label: 'Medium',
          weightRange: '14-25kg',
          icon: Icons.pets,
          isSelected: selectedSize == 'medium',
          onTap: () => onSizeSelected('medium'),
        ),
        PetSizeSelectionCard(
          size: 'large',
          label: 'Large',
          weightRange: '25kg以上',
          icon: Icons.pets,
          isSelected: selectedSize == 'large',
          onTap: () => onSizeSelected('large'),
        ),
      ],
    );
  }
}
