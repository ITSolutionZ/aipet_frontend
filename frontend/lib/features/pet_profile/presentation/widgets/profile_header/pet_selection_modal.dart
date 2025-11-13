import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PetSelectionModal extends StatelessWidget {
  final List<PetProfileEntity> pets;

  const PetSelectionModal({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ペットを選択',
            style: AppFonts.titleLarge.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...pets.map(
            (pet) => ListTile(
              leading: CircleAvatar(
                backgroundImage: pet.imagePath != null
                    ? AssetImage(pet.imagePath!)
                    : null,
                child: pet.imagePath == null ? const Icon(Icons.pets) : null,
              ),
              title: Text(pet.name),
              subtitle: Text(pet.breed ?? 'Unknown breed'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/pet-profile/${pet.id}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
