import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/services/error_service.dart';
import '../../data/providers/providers.dart';

part 'pet_name_input_controller.g.dart';

/// 펫 이름 입력 화면 상태
class PetNameInputState {
  final String petName;
  final String? selectedGender;
  final bool isNeutered;
  final String? selectedImagePath;
  final String microchipNumber;
  final bool isNameValid;
  final bool canProceedToNext;
  final String? errorMessage;
  final bool isLoading;

  const PetNameInputState({
    this.petName = '',
    this.selectedGender,
    this.isNeutered = false,
    this.selectedImagePath,
    this.microchipNumber = '',
    this.isNameValid = false,
    this.canProceedToNext = false,
    this.errorMessage,
    this.isLoading = false,
  });

  PetNameInputState copyWith({
    String? petName,
    String? selectedGender,
    bool? isNeutered,
    String? selectedImagePath,
    String? microchipNumber,
    bool? isNameValid,
    bool? canProceedToNext,
    String? errorMessage,
    bool? isLoading,
  }) {
    return PetNameInputState(
      petName: petName ?? this.petName,
      selectedGender: selectedGender ?? this.selectedGender,
      isNeutered: isNeutered ?? this.isNeutered,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      isNameValid: isNameValid ?? this.isNameValid,
      canProceedToNext: canProceedToNext ?? this.canProceedToNext,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 펫 이름 입력 화면 컨트롤러
@Riverpod(keepAlive: true)
class PetNameInputController extends _$PetNameInputController {
  @override
  PetNameInputState build() {
    // 글로벌 상태에서 초기값 복원
    final globalState = ref.watch(petRegistrationStateProvider);
    return PetNameInputState(
      petName: globalState.petName ?? '',
      selectedGender: globalState.petGender,
      isNeutered: globalState.isNeutered ?? false,
      selectedImagePath: globalState.petImagePath,
      microchipNumber: globalState.microchipNumber ?? '',
      isNameValid: _validateName(globalState.petName ?? ''),
      canProceedToNext: _canProceedToNext(
        globalState.petName ?? '',
        globalState.petGender,
      ),
    );
  }

  /// 펫 이름 업데이트
  void updatePetName(String name) {
    final isValid = _validateName(name);
    final canProceed = _canProceedToNext(name, state.selectedGender);

    state = state.copyWith(
      petName: name,
      isNameValid: isValid,
      canProceedToNext: canProceed,
      errorMessage: null,
    );

    // 글로벌 상태 동기화
    _syncToGlobalState();
  }

  /// 성별 업데이트
  void updateGender(String? gender) {
    final canProceed = _canProceedToNext(state.petName, gender);

    state = state.copyWith(
      selectedGender: gender,
      canProceedToNext: canProceed,
    );

    // 글로벌 상태 동기화
    _syncToGlobalState();
  }

  /// 중성화 상태 업데이트
  void updateNeuteredStatus(bool isNeutered) {
    state = state.copyWith(isNeutered: isNeutered);

    // 글로벌 상태 동기화
    _syncToGlobalState();
  }

  /// 이미지 경로 업데이트
  void updateImagePath(String? imagePath) {
    state = state.copyWith(selectedImagePath: imagePath);

    // 글로벌 상태 동기화
    _syncToGlobalState();
  }

  /// 마이크로칩 번호 업데이트
  void updateMicrochipNumber(String number) {
    state = state.copyWith(microchipNumber: number);

    // 글로벌 상태 동기화
    _syncToGlobalState();
  }

  /// 에러 메시지 설정
  void setError(String? errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 모든 입력값 검증
  bool validateAll() {
    final nameValid = _validateName(state.petName);
    final genderSelected = state.selectedGender != null;

    if (!nameValid) {
      state = state.copyWith(
        errorMessage: 'ペットの名前を2文字以上20文字以内で入力してください',
        isNameValid: false,
        canProceedToNext: false,
      );
      return false;
    }

    if (!genderSelected) {
      state = state.copyWith(
        errorMessage: 'ペットの性別を選択してください',
        canProceedToNext: false,
      );
      return false;
    }

    state = state.copyWith(
      errorMessage: null,
      isNameValid: true,
      canProceedToNext: true,
    );
    return true;
  }

  /// 데이터 저장 및 다음 단계 진행
  Future<bool> saveAndProceed() async {
    if (!validateAll()) {
      return false;
    }

    try {
      state = state.copyWith(isLoading: true);

      // 글로벌 상태에 최종 저장
      _syncToGlobalState();

      // 잠시 대기 (실제 저장 로직이 있다면 여기에 구현)
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      final errorMessage = ErrorService().getUserFriendlyMessage(error);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    }
  }

  /// 이름 검증
  bool _validateName(String name) {
    final trimmed = name.trim();
    return trimmed.length >= 2 && trimmed.length <= 20;
  }

  /// 다음 단계 진행 가능 여부 확인
  bool _canProceedToNext(String name, String? gender) {
    return _validateName(name) && gender != null;
  }

  /// 글로벌 상태와 동기화
  void _syncToGlobalState() {
    final notifier = ref.read(petRegistrationStateProvider.notifier);

    notifier.setPetName(state.petName);
    notifier.setPetGenderInfo(
      gender: state.selectedGender,
      isNeutered: state.isNeutered,
    );
    notifier.setPetImagePath(state.selectedImagePath);
    notifier.setMicrochipNumber(state.microchipNumber);
  }

  /// 상태 초기화
  void reset() {
    state = const PetNameInputState();
  }
}
