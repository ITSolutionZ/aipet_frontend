import 'package:aipet_frontend/features/pet_profile/data/providers/usecase_providers.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/update_pet_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    return copyWith(errorMessage: null, successMessage: null);
  }
}

/// 펫 편집 컨트롤러
@riverpod
class PetEditNotifier extends _$PetEditNotifier {
  UpdatePetUseCase get _updateUseCase => ref.read(updatePetUseCaseProvider);

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
        'weight': pet.weight.toString(),
        'gender': pet.gender,
        'neutered': pet.neutered ?? false,
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

    state = state.copyWith(editingValues: updatedValues, errorMessage: null);
  }

  /// 이미지 선택
  void selectImage(String imagePath) {
    state = state.copyWith(selectedImagePath: imagePath, errorMessage: null);
  }

  /// 변경사항 저장
  Future<Result<bool>> saveChanges(PetProfileEntity originalPet, String currentUserId) async {
    // 입력 유효성 검증
    final validationError = _validateInput();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return Result.failure(validationError);
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 편집된 엔티티 생성
      final updatedPet = _createUpdatedPetEntity(originalPet);

      // UseCase를 통한 업데이트 실행
      final result = await _updateUseCase.call(updatedPet);

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isEditMode: false,
          successMessage: 'ペットプロフィールを保存しました',
        );
        return Result.success('ペットプロフィールを保存しました', true);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
        return Result.failure(result.message);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to save pet profile: $error');
      return Result.failure('Failed to save pet profile: $error');
    }
  }

  /// 입력 유효성 검증
  String? _validateInput() {
    final name = state.editingValues['name'] as String? ?? '';
    final weightStr = state.editingValues['weight'] as String? ?? '';
    final birthDate = state.editingValues['birthDate'] as DateTime?;

    // 이름 검증
    if (name.trim().isEmpty) {
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
    if (birthDate != null && birthDate.isAfter(DateTime.now())) {
      return '生年月日は未来の日付にできません';
    }

    return null;
  }

  /// 업데이트된 펫 엔티티 생성
  PetProfileEntity _createUpdatedPetEntity(PetProfileEntity originalPet) {
    final values = state.editingValues;
    final weightStr = values['weight'] as String? ?? '';
    final weight = weightStr.isNotEmpty ? double.tryParse(weightStr) : null;

    return originalPet.copyWith(
      name: values['name'] as String,
      breed: values['breed'] as String?,
      birthDate: values['birthDate'] as DateTime? ?? originalPet.birthDate,
      imagePath: state.selectedImagePath,
      weight: weight ?? originalPet.weight,
      gender: values['gender'] as String? ?? originalPet.gender,
      neutered: values['neutered'] as bool?,
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
