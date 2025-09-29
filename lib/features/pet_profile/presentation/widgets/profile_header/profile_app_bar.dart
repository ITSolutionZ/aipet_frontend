import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_selection_modal.dart';
import 'pet_selection_widget.dart';

class ProfileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final PetProfileEntity pet;

  const ProfileAppBar({super.key, required this.pet});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftGradientDrawerAppBar(
      title: 'ペットのプロフィール',
      selectedPetInfo: PetSelectionWidget(
        pet: pet,
        onTap: () => _showPetSelectionModal(context, ref),
      ),
    );
  }

  void _showPetSelectionModal(BuildContext context, WidgetRef ref) {
    final petsAsyncValue = ref.read(petsNotifierProvider);

    petsAsyncValue.whenData((pets) {
      if (pets.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No pets available')));
        return;
      }

      showModalBottomSheet(
        context: context,
        builder: (context) => PetSelectionModal(pets: pets),
      );
    });
  }
}
