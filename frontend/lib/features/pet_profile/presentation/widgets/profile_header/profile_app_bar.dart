import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
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
    // Mock 데이터 사용
    const petsAsyncValue = AsyncValue.data(<PetProfileEntity>[]);

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
