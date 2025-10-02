import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🎯 Start Walk Dialog Form State Provider
final startWalkDialogFormProvider =
    StateNotifierProvider<
      StartWalkDialogFormController,
      StartWalkDialogFormState
    >((ref) => StartWalkDialogFormController());

class StartWalkDialogFormController
    extends StateNotifier<StartWalkDialogFormState> {
  StartWalkDialogFormController()
    : super(const StartWalkDialogFormState(title: '', selectedPetId: 'pet1'));

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void selectPet(String petId) {
    state = state.copyWith(selectedPetId: petId);
  }

  bool isFormValid() {
    return state.title.trim().isNotEmpty;
  }
}

/// Start Walk Dialog Form 상태
class StartWalkDialogFormState {
  final String title;
  final String selectedPetId;

  const StartWalkDialogFormState({
    required this.title,
    required this.selectedPetId,
  });

  StartWalkDialogFormState copyWith({String? title, String? selectedPetId}) {
    return StartWalkDialogFormState(
      title: title ?? this.title,
      selectedPetId: selectedPetId ?? this.selectedPetId,
    );
  }
}

class StartWalkDialog extends ConsumerWidget {
  final WalkController controller;

  const StartWalkDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(startWalkDialogFormProvider);
    final formController = ref.read(startWalkDialogFormProvider.notifier);

    return AlertDialog(
      title: Text(
        '新しい散歩を始める',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: formState.title,
            decoration: const InputDecoration(
              labelText: '散歩のタイトル',
              border: OutlineInputBorder(),
            ),
            onChanged: formController.updateTitle,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'タイトルを入力してください。';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: formState.selectedPetId,
            decoration: const InputDecoration(
              labelText: 'ペット',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'pet1', child: Text('Maxi')),
              DropdownMenuItem(value: 'pet2', child: Text('Luna')),
            ],
            onChanged: (value) {
              if (value != null) {
                formController.selectPet(value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('キャンセル')),
        ElevatedButton(
          onPressed: formController.isFormValid()
              ? () => _startWalk(context, formState)
              : null,
          child: const Text('はじめ'),
        ),
      ],
    );
  }

  void _startWalk(
    BuildContext context,
    StartWalkDialogFormState formState,
  ) async {
    if (formState.title.trim().isEmpty) return;

    final result = await controller.startNewWalk(
      title: formState.title,
      petId: formState.selectedPetId,
      petName: formState.selectedPetId == 'pet1' ? 'Maxi' : 'Luna',
      petImage: 'assets/images/dogs/shiba.png',
    );

    if (result.isSuccess && context.mounted) {
      context.pop();
      UiService.showSuccess(context, result.message);
    } else if (context.mounted) {
      UiService.showError(context, result.message);
    }
  }
}
