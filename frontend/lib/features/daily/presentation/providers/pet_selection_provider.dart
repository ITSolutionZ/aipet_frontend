import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/pet_profile.dart';

part 'pet_selection_provider.g.dart';

/// 펫 선택 상태 관리
class PetSelectionState {
  final String? selectedPetId;
  final List<PetProfileEntity> availablePets;
  final bool isLoading;

  const PetSelectionState({
    this.selectedPetId,
    this.availablePets = const [],
    this.isLoading = false,
  });

  PetSelectionState copyWith({
    String? selectedPetId,
    List<PetProfileEntity>? availablePets,
    bool? isLoading,
  }) {
    return PetSelectionState(
      selectedPetId: selectedPetId ?? this.selectedPetId,
      availablePets: availablePets ?? this.availablePets,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  PetProfileEntity? get selectedPet {
    if (selectedPetId == null) return null;
    try {
      return availablePets.firstWhere((pet) => pet.id == selectedPetId);
    } catch (e) {
      return null;
    }
  }
}

/// 펫 선택 Notifier
@riverpod
class PetSelectionNotifier extends _$PetSelectionNotifier {
  @override
  PetSelectionState build() {
    return const PetSelectionState();
  }

  /// 펫 목록 로드
  Future<void> loadPets() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await ref.read(petProfileRepositoryProvider).getAllPets();
      if (result.isSuccess) {
        // 타입 안전성을 위해 명시적 변환
        final pets = <PetProfileEntity>[];
        if (result.dataOrNull != null) {
          for (final pet in result.dataOrNull!) {
            pets.add(pet);
          }
        }
        state = state.copyWith(availablePets: pets, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 펫 선택
  void selectPet(String petId) {
    state = state.copyWith(selectedPetId: petId);
  }

  /// 전체 펫 선택 (필터 해제)
  void selectAllPets() {
    state = state.copyWith(selectedPetId: null);
  }

  /// 선택된 펫 이름 반환
  String getSelectedPetName() {
    final selectedPet = state.selectedPet;
    if (selectedPet != null) {
      return selectedPet.name;
    }
    return '全体';
  }
}
