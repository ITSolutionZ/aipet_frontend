import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/pet_profile_providers.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/usecases/update_pet_profile_usecase.dart';
import '../constants/pet_profile_constants.dart';

part 'pet_edit_controller.g.dart';

/// 펫 편집 상태
class PetEditState {
  final bool isEditMode;
  final String? selectedImagePath;
  final Map<String, dynamic> editingValues;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PetEditState({
    this.isEditMode = false,
    this.selectedImagePath,
    this.editingValues = const {},
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  PetEditState copyWith({
    bool? isEditMode,
    String? selectedImagePath,
    Map<String, dynamic>? editingValues,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return PetEditState(
      isEditMode: isEditMode ?? this.isEditMode,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      editingValues: editingValues ?? this.editingValues,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// 에러/성공 메시지 클리어
  PetEditState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}

/// 펫 편집 컨트롤러
@riverpod
class PetEditNotifier extends _$PetEditNotifier {
  UpdatePetProfileUseCase get _updateUseCase => ref.read(updatePetProfileUseCaseProvider);

  @override
  PetEditState build() => const PetEditState();

  /// 편집 모드 시작
  void startEdit(PetProfileEntity pet) {
    state = state.copyWith(
      isEditMode: true,
      editingValues: {
        'name': pet.name,
        'breed': pet.breed ?? '',
        'birthDate': pet.birthDate,
        'weight': pet.healthInfo?.weight?.toString() ?? '',
        'currentMedication': pet.healthInfo?.currentMedication ?? '',
        'veterinarianNotes': pet.healthInfo?.veterinarianNotes ?? '',
      },
      selectedImagePath: pet.imagePath,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// 편집 모드 종료
  void cancelEdit() {
    state = const PetEditState();
  }

  /// 편집 값 업데이트
  void updateEditingValue(String key, dynamic value) {
    final updatedValues = Map<String, dynamic>.from(state.editingValues);
    updatedValues[key] = value;

    state = state.copyWith(
      editingValues: updatedValues,
      errorMessage: null,
    );
  }

  /// 이미지 선택
  void selectImage(String imagePath) {
    state = state.copyWith(
      selectedImagePath: imagePath,
      errorMessage: null,
    );
  }

  /// 변경사항 저장
  Future<bool> saveChanges(PetProfileEntity originalPet, String currentUserId) async {
    // 입력 유효성 검증
    final validationError = _validateInput();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 편집된 엔티티 생성
      final updatedPet = _createUpdatedPetEntity(originalPet);

      // UseCase를 통한 업데이트 실행
      final result = await _updateUseCase.execute(
        profile: updatedPet,
        userId: currentUserId,
      );

      // 결과 처리
      switch (result) {
        case UpdatePetProfileSuccess():
          state = state.copyWith(
            isLoading: false,
            isEditMode: false,
            successMessage: PetProfileConstants.saveSuccess,
          );
          return true;

        case UpdatePetProfileAccessDenied():
          state = state.copyWith(
            isLoading: false,
            errorMessage: PetProfileConstants.accessDeniedMessage,
          );
          return false;

        case UpdatePetProfileValidationError():
          state = state.copyWith(
            isLoading: false,
            errorMessage: result.message,
          );
          return false;

        case UpdatePetProfileNotFound():
        case UpdatePetProfileError():
          state = state.copyWith(
            isLoading: false,
            errorMessage: PetProfileConstants.saveError,
          );
          return false;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${PetProfileConstants.saveError}: $error',
      );
      return false;
    }
  }

  /// 입력 유효성 검증
  String? _validateInput() {
    final name = state.editingValues['name'] as String? ?? '';
    final weightStr = state.editingValues['weight'] as String? ?? '';
    final birthDate = state.editingValues['birthDate'] as DateTime?;

    // 이름 검증
    if (name.trim().isEmpty) {
      return PetProfileConstants.nameRequiredMessage;
    }
    if (name.length > PetProfileConstants.maxNameLength) {
      return PetProfileConstants.nameTooLongMessage;
    }

    // 체중 검증 (입력된 경우)
    if (weightStr.isNotEmpty) {
      final weight = double.tryParse(weightStr);
      if (weight == null ||
          weight < PetProfileConstants.minWeight ||
          weight > PetProfileConstants.maxWeight) {
        return PetProfileConstants.invalidWeightMessage;
      }
    }

    // 생년월일 검증
    if (birthDate != null && birthDate.isAfter(DateTime.now())) {
      return PetProfileConstants.futureBirthDateMessage;
    }

    return null;
  }

  /// 업데이트된 펫 엔티티 생성
  PetProfileEntity _createUpdatedPetEntity(PetProfileEntity originalPet) {
    final values = state.editingValues;
    final weightStr = values['weight'] as String? ?? '';
    final weight = weightStr.isNotEmpty ? double.tryParse(weightStr) : null;

    // 건강 정보 업데이트
    final updatedHealthInfo = originalPet.healthInfo?.copyWith(
      weight: weight,
      currentMedication: values['currentMedication'] as String?,
      veterinarianNotes: values['veterinarianNotes'] as String?,
    ) ?? HealthInfo(
      weight: weight,
      currentMedication: values['currentMedication'] as String?,
      veterinarianNotes: values['veterinarianNotes'] as String?,
    );

    return originalPet.copyWith(
      name: values['name'] as String,
      breed: values['breed'] as String?,
      birthDate: values['birthDate'] as DateTime? ?? originalPet.birthDate,
      imagePath: state.selectedImagePath,
      healthInfo: updatedHealthInfo,
      updatedAt: DateTime.now(),
    );
  }

  /// 메시지 클리어
  void clearMessages() {
    state = state.clearMessages();
  }

  /// 편집된 값이 있는지 확인
  bool get hasUnsavedChanges => state.editingValues.isNotEmpty && state.isEditMode;

  /// 현재 편집 중인 이름
  String get editingName => state.editingValues['name'] as String? ?? '';

  /// 현재 편집 중인 품종
  String get editingBreed => state.editingValues['breed'] as String? ?? '';

  /// 현재 편집 중인 체중
  String get editingWeight => state.editingValues['weight'] as String? ?? '';
}