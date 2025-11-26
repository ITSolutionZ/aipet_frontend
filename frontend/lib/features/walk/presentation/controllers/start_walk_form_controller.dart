import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'start_walk_form_controller.g.dart';

/// 🎯 Start Walk Form Controller (Firebase 연동)
@riverpod
class StartWalkFormController extends _$StartWalkFormController {
  @override
  StartWalkFormState build() {
    // ✅ Firebase에서 첫 번째 펫을 기본값으로 사용
    final petsAsync = ref.watch(petProfilesProvider);
    final firstPetId = petsAsync.when(
      data: (pets) => pets.isNotEmpty ? pets.first.id : '',
      loading: () => '',
      error: (_, __) => '',
    );

    return StartWalkFormState(title: '', selectedPetId: firstPetId);
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
