import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Pet Registration Logic
///
/// **역할**: 펫 등록 화면의 UI 로직 및 헬퍼 함수 모음
/// - 폼 제출 및 검증 로직
/// - 등록 완료 후 네비게이션
/// - UI 상수 및 메시지
///
/// **특징**:
/// - 상태를 가지지 않는 순수 함수 중심
/// - UI 표시와 관련된 로직만 포함
/// - 비즈니스 로직은 PetRegistrationController에서 처리
///
/// **사용 위치**: DailyPetRegistrationScreen에서 사용
/// **관련 파일**: PetRegistrationController (상태 관리 및 비즈니스 로직)
class PetRegistrationLogic {
  PetRegistrationLogic();

  /// 펫 등록 폼 검증 및 제출
  Future<void> submitPetRegistration({
    required GlobalKey<FormState> formKey,
    required PetRegistrationController controller,
  }) async {
    // 폼 검증 전에 텍스트 컨트롤러와 state 동기화
    debugPrint(
      '🔄 Synchronizing text controllers with state before validation',
    );
    controller.updatePetName(controller.petNameController.text);
    controller.updateWeight(controller.weightController.text);
    controller.updateGuardianName(controller.guardianNameController.text);
    controller.updateInstitutionName(controller.institutionNameController.text);
    controller.updateRegistrationNumber(
      controller.registrationNumberController.text,
    );

    // 폼 데이터 상태 디버깅
    final formData = controller.formData;
    debugPrint('🔍 Form validation check:');
    debugPrint(
      '  - petName: "${formData.petName}" (empty: ${formData.petName.isEmpty})',
    );
    debugPrint('  - birthDate: ${formData.birthDate}');
    debugPrint('  - weight: ${formData.weight}');
    debugPrint(
      '  - breed: "${formData.breed}" (empty: ${formData.breed.isEmpty})',
    );
    debugPrint(
      '  - gender: "${formData.gender}" (empty: ${formData.gender.isEmpty})',
    );
    debugPrint('  - petType: "${formData.petType}"');

    // 폼 기본 검증
    if (!formKey.currentState!.validate()) {
      debugPrint('❌ Form validation failed - basic form validation');

      // 구체적인 에러 메시지 생성
      final errors = <String>[];
      if (formData.petName.isEmpty) errors.add('ペットの名前');
      if (formData.birthDate == null) errors.add('生年月日');
      if (formData.weight == null) errors.add('体重');
      if (formData.breed.isEmpty) errors.add('品種');
      if (formData.gender.isEmpty) errors.add('性別');

      final errorMessage = errors.isNotEmpty
          ? '必須項目を入力してください:\n• ${errors.join('\n• ')}'
          : 'フォーム検証に失敗しました';

      throw PetRegistrationException(errorMessage);
    }

    // 품종 검증
    final breedValidation = controller.validateBreed();
    if (breedValidation != null) {
      debugPrint('❌ Breed validation failed: $breedValidation');
      throw PetRegistrationException(breedValidation);
    }

    // 성별 검증
    final genderValidation = controller.validateGender();
    if (genderValidation != null) {
      debugPrint('❌ Gender validation failed: $genderValidation');
      throw PetRegistrationException(genderValidation);
    }

    debugPrint('✅ All validations passed, proceeding with registration');
    // 실제 등록 처리
    await controller.submitForm();
  }

  /// 생년월일 선택 로직
  Future<DateTime?> selectBirthDate({
    required BuildContext context,
    DateTime? currentDate,
  }) async {
    // showDatePickerを使用、localeパラメータを削除してアプリのデフォルトlocaleを使用
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: '生年月日選択',
      cancelText: 'キャンセル',
      confirmText: '確認',
      fieldLabelText: '日付入力',
      fieldHintText: 'yyyy/mm/dd',
      errorFormatText: '正しい日付形式ではありません',
      errorInvalidText: '無効な日付です',
    );
    return picked;
  }

  /// 집에 온 날 선택 로직
  Future<DateTime?> selectAdoptionDate({
    required BuildContext context,
    DateTime? currentDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: '家にきた日を選択',
      cancelText: 'キャンセル',
      confirmText: '確認',
      fieldLabelText: '日付入力',
      fieldHintText: 'yyyy/mm/dd',
      errorFormatText: '正しい日付形式ではありません',
      errorInvalidText: '無効な日付です',
    );
    return picked;
  }

  /// ペット画像選択ロジック
  Future<String?> selectPetImage({
    required BuildContext context,
    String? currentImagePath,
  }) async {
    try {
      debugPrint(
        '🎯 PetRegistrationLogic: selectPetImage called with currentImagePath: $currentImagePath',
      );
      debugPrint(
        '🎯 PetRegistrationLogic: context.mounted: ${context.mounted}',
      );

      final result = await ImageService.showImagePickerOptions(
        context,
        allowRemoval: currentImagePath != null,
        currentImagePath: currentImagePath,
      );

      debugPrint('🎯 PetRegistrationLogic: ImageService returned: $result');

      if (result == null) {
        debugPrint('🎯 PetRegistrationLogic: Result is null, returning null');
        return null;
      }
      if (result == 'REMOVE') {
        debugPrint(
          '🎯 PetRegistrationLogic: Result is REMOVE, returning REMOVE',
        );
        return 'REMOVE';
      }

      debugPrint(
        '🎯 PetRegistrationLogic: Result is valid image path, returning: $result',
      );
      return result;
    } catch (e, stackTrace) {
      debugPrint('🎯 PetRegistrationLogic: Exception in selectPetImage: $e');
      debugPrint('🎯 PetRegistrationLogic: Stack trace: $stackTrace');
      return null;
    }
  }

  /// 成功メッセージ生成
  String getSuccessMessage() => 'ペット登録が完了しました！';

  /// エラーメッセージ生成
  String getErrorMessage(dynamic error) {
    if (error is PetRegistrationException) {
      return error.message;
    }
    return 'エラーが発生しました: $error';
  }

  /// ダイアログメッセージ
  static const String registrationImageMessage = '登録証写真アップロード機能は近日実装予定';
  static const String ingredientsMessage = '原料登録画面は近日実装予定';
  static const String bodyPartsMessage = '身体部位登録画面は近日実装予定';
}

/// Pet Registration関連カスタム例外
class PetRegistrationException implements Exception {
  final String message;

  const PetRegistrationException(this.message);

  @override
  String toString() => 'PetRegistrationException: $message';
}
