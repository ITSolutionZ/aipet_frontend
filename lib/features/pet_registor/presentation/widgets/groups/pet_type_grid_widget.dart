import 'package:aipet_frontend/features/pet_registor/presentation/widgets/cards/pet_type_card.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetTypeGridWidget extends StatelessWidget {
  final String? selectedPetType;
  final ValueChanged<String> onPetTypeSelected;

  const PetTypeGridWidget({
    super.key,
    required this.selectedPetType,
    required this.onPetTypeSelected,
  });

  List<Map<String, dynamic>> _getPetTypesData() {
    return [
      {
        'type': 'dog',
        'imagePath': 'assets/images/pet_selector/dog.png',
        'color': const Color(0xFFE91E63),
        'isSpecial': true,
      },
      {
        'type': 'cat',
        'imagePath': 'assets/images/pet_selector/cat.png',
        'color': const Color(0xFF9C27B0),
        'isSpecial': true,
      },
      {
        'type': 'rabbit',
        'imagePath': 'assets/images/pet_selector/rabbit.png',
        'color': const Color(0xFF4CAF50),
        'isSpecial': false,
      },
      {
        'type': 'hamster',
        'imagePath': 'assets/images/pet_selector/hamster.png',
        'color': const Color(0xFFFF9800),
        'isSpecial': false,
      },
      {
        'type': 'bird',
        'imagePath': 'assets/images/pet_selector/bird.png',
        'color': const Color(0xFF2196F3),
        'isSpecial': false,
      },
      {
        'type': 'turtle',
        'imagePath': 'assets/images/pet_selector/turtle.png',
        'color': const Color(0xFF607D8B),
        'isSpecial': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final petTypes = _getPetTypesData();

    return Column(
      children: [
        SizedBox(
          height: 420,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.0,
            ),
            itemCount: petTypes.length,
            itemBuilder: (context, index) {
              final petType = petTypes[index];
              final isSelected = selectedPetType == petType['type'];

              return PetTypeCard(
                imagePath: petType['imagePath'],
                selectionColor: petType['color'],
                isSelected: isSelected,
                petType: petType['type'],
                onTap: () => onPetTypeSelected(petType['type']),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('カスタムペットタイプは近日公開予定です')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              side: BorderSide(
                color: AppColors.pointGray.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              '種類がない',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
