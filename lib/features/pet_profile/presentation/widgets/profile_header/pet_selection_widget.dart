import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetSelectionWidget extends StatelessWidget {
  final PetProfileEntity pet;
  final VoidCallback onTap;

  const PetSelectionWidget({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              backgroundImage: pet.imagePath != null ? AssetImage(pet.imagePath!) : null,
              child: pet.imagePath == null
                  ? const Icon(Icons.pets, size: 16, color: AppColors.pointBrown)
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(pet.name, style: AppFonts.bodyMedium.copyWith(color: const Color(0xFF5B4034))),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5B4034), size: 20),
          ],
        ),
      ),
    );
  }
}
