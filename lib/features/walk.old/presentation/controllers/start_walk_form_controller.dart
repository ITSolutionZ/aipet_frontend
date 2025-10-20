import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'start_walk_form_controller.g.dart';

/// 🎯 Start Walk Form Controller
@riverpod
class StartWalkFormController extends _$StartWalkFormController {
  @override
  StartWalkFormState build() {
    return const StartWalkFormState(title: '', selectedPetId: 'pet1');
  }

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
