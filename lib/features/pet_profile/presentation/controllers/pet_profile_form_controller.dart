import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_form_controller.g.dart';

/// Pet Profile Form 상태
class PetProfileFormState {
  final bool isEditMode;
  final bool isLoading;
  final String? errorMessage;

  // Form Controllers
  final TextEditingController nameController;
  final TextEditingController breedController;
  final TextEditingController weightController;

  // Editable Values
  final String? editingGender;
  final String? editingType;
  final double? editingWeight;
  final String? selectedImagePath;
  final DateTime? editingBirthDate;

  const PetProfileFormState({
    required this.isEditMode,
    required this.isLoading,
    this.errorMessage,
    required this.nameController,
    required this.breedController,
    required this.weightController,
    this.editingGender,
    this.editingType,
    this.editingWeight,
    this.selectedImagePath,
    this.editingBirthDate,
  });

  PetProfileFormState copyWith({
    bool? isEditMode,
    bool? isLoading,
    String? errorMessage,
    TextEditingController? nameController,
    TextEditingController? breedController,
    TextEditingController? weightController,
    String? editingGender,
    String? editingType,
    double? editingWeight,
    String? selectedImagePath,
    DateTime? editingBirthDate,
  }) {
    return PetProfileFormState(
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      nameController: nameController ?? this.nameController,
      breedController: breedController ?? this.breedController,
      weightController: weightController ?? this.weightController,
      editingGender: editingGender ?? this.editingGender,
      editingType: editingType ?? this.editingType,
      editingWeight: editingWeight ?? this.editingWeight,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      editingBirthDate: editingBirthDate ?? this.editingBirthDate,
    );
  }
}

/// Pet Profile Form Controller
@riverpod
class PetProfileFormController extends _$PetProfileFormController {
  @override
  PetProfileFormState build() {
    final nameController = TextEditingController();
    final breedController = TextEditingController();
    final weightController = TextEditingController();

    // Dispose controllers when provider is disposed
    ref.onDispose(() {
      nameController.dispose();
      breedController.dispose();
      weightController.dispose();
    });

    return PetProfileFormState(
      isEditMode: false,
      isLoading: false,
      nameController: nameController,
      breedController: breedController,
      weightController: weightController,
    );
  }

  /// 편집 모드 시작
  void startEdit(PetProfileEntity pet) {
    state = state.copyWith(isEditMode: true);

    // 현재 펫 정보로 컨트롤러 초기화
    state.nameController.text = pet.name;
    state.breedController.text = pet.breed ?? '';
    state.weightController.text = pet.weight.toString();

    state = state.copyWith(
      editingGender: pet.gender,
      editingType: pet.type,
      editingWeight: pet.weight,
      selectedImagePath: pet.imagePath,
      editingBirthDate: pet.birthDate,
    );
  }

  /// 편집 모드 취소
  void cancelEdit() {
    state = state.copyWith(
      isEditMode: false,
      editingGender: null,
      editingType: null,
      editingWeight: null,
      selectedImagePath: null,
      editingBirthDate: null,
    );

    // 컨트롤러 초기화
    state.nameController.clear();
    state.breedController.clear();
    state.weightController.clear();
  }

  /// 성별 변경
  void updateGender(String? gender) {
    state = state.copyWith(editingGender: gender);
  }

  /// 타입 변경
  void updateType(String? type) {
    state = state.copyWith(editingType: type);
  }

  /// 몸무게 변경
  void updateWeight(double? weight) {
    state = state.copyWith(editingWeight: weight);
    if (weight != null) {
      state.weightController.text = weight.toString();
    }
  }

  /// 이미지 경로 변경
  void updateImagePath(String? imagePath) {
    state = state.copyWith(selectedImagePath: imagePath);
  }

  /// 생년월일 변경
  void updateBirthDate(DateTime? birthDate) {
    state = state.copyWith(editingBirthDate: birthDate);
  }

  /// 변경사항 저장
  Future<void> saveChanges(PetProfileEntity originalPet) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Repository를 통해 실제 저장 로직 구현
      // 변경된 펫 정보 생성 및 저장
      // final updatedPet = originalPet.copyWith(...);
      // await repository.updatePet(updatedPet);

      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay

      // 편집 모드 종료
      state = state.copyWith(isEditMode: false, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  /// 폼 유효성 검사
  bool isFormValid() {
    return state.nameController.text.isNotEmpty;
  }

  /// 변경사항 확인
  bool hasChanges(PetProfileEntity originalPet) {
    return state.nameController.text != originalPet.name ||
        state.breedController.text != (originalPet.breed ?? '') ||
        state.weightController.text != originalPet.weight.toString() ||
        state.editingGender != originalPet.gender ||
        state.editingType != originalPet.type ||
        state.editingWeight != originalPet.weight ||
        state.selectedImagePath != originalPet.imagePath ||
        state.editingBirthDate != originalPet.birthDate;
  }
}
