import 'package:flutter/material.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/data/providers/usecase_providers.dart';
import '../../../../../features/pet_profile/domain/usecases/update_pet_usecase.dart';

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
  UpdatePetUseCase get _updateUseCase => ref.read(updatePetUseCaseProvider);

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
  Future<Result<bool>> saveChanges(PetProfileEntity originalPet) async {
    // 입력 유효성 검증
    final validationError = _validateInput();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return Result.failure(validationError);
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 변경된 펫 엔티티 생성
      final updatedPet = _createUpdatedPetEntity(originalPet);

      // UseCase를 통한 업데이트 실행
      final result = await _updateUseCase.call(updatedPet);

      if (result.isSuccess) {
        // 편집 모드 종료
        state = state.copyWith(isEditMode: false, isLoading: false);
        return Result.success('ペットプロフィールを保存しました', true);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
        return Result.failure(result.message);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save pet profile: $error',
      );
      return Result.failure('Failed to save pet profile: $error');
    }
  }

  /// 입력 유효성 검증
  String? _validateInput() {
    final name = state.nameController.text.trim();
    final weightStr = state.weightController.text.trim();

    // 이름 검증
    if (name.isEmpty) {
      return '名前は必須です';
    }
    if (name.length > 50) {
      return '名前は50文字以内で入力してください';
    }

    // 체중 검증 (입력된 경우)
    if (weightStr.isNotEmpty) {
      final weight = double.tryParse(weightStr);
      if (weight == null || weight < 0.1 || weight > 200.0) {
        return '体重は0.1kgから200.0kgの間で入力してください';
      }
    }

    // 생년월일 검증
    if (state.editingBirthDate != null &&
        state.editingBirthDate!.isAfter(DateTime.now())) {
      return '生年月日は未来の日付にできません';
    }

    return null;
  }

  /// 업데이트된 펫 엔티티 생성
  PetProfileEntity _createUpdatedPetEntity(PetProfileEntity originalPet) {
    final weightStr = state.weightController.text.trim();
    final weight = weightStr.isNotEmpty ? double.tryParse(weightStr) : null;

    return originalPet.copyWith(
      name: state.nameController.text.trim(),
      breed: state.breedController.text.trim().isNotEmpty
          ? state.breedController.text.trim()
          : null,
      birthDate: state.editingBirthDate ?? originalPet.birthDate,
      imagePath: state.selectedImagePath,
      weight: weight ?? originalPet.weight,
      gender: state.editingGender ?? originalPet.gender,
      type: state.editingType ?? originalPet.type,
      updatedAt: DateTime.now(),
    );
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
