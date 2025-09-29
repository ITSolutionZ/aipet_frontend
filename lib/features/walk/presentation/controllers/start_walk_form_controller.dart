import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Start Walk Form State Provider
final startWalkFormProvider =
    StateNotifierProvider<StartWalkFormController, StartWalkFormState>(
      (ref) => StartWalkFormController(),
    );

class StartWalkFormController extends StateNotifier<StartWalkFormState> {
  StartWalkFormController()
    : super(const StartWalkFormState(title: '', selectedPetId: 'pet1'));

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

/// Start Walk Form 상태
class StartWalkFormState {
  final String title;
  final String selectedPetId;

  const StartWalkFormState({required this.title, required this.selectedPetId});

  StartWalkFormState copyWith({String? title, String? selectedPetId}) {
    return StartWalkFormState(
      title: title ?? this.title,
      selectedPetId: selectedPetId ?? this.selectedPetId,
    );
  }
}
