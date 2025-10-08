import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Pet Registration画面のビジネスロジックを担当するクラス
class PetRegistrationLogic {
  PetRegistrationLogic();

  /// ペット登録フォーム検証および提出
  Future<void> submitPetRegistration({
    required GlobalKey<FormState> formKey,
    required PetRegistrationController controller,
  }) async {
    // 폼 검증 전에 텍스트 컨트롤러와 state 동기화
    print('🔄 Synchronizing text controllers with state before validation');
    controller.updatePetName(controller.petNameController.text);
    controller.updateWeight(controller.weightController.text);
    controller.updateGuardianName(controller.guardianNameController.text);
    controller.updateInstitutionName(controller.institutionNameController.text);
    controller.updateRegistrationNumber(
      controller.registrationNumberController.text,
    );

    // 폼 데이터 상태 디버깅
    final formData = controller.formData;
    print('🔍 Form validation check:');
    print(
      '  - petName: "${formData.petName}" (empty: ${formData.petName.isEmpty})',
    );
    print('  - birthDate: ${formData.birthDate}');
    print('  - weight: ${formData.weight}');
    print('  - breed: "${formData.breed}" (empty: ${formData.breed.isEmpty})');
    print(
      '  - gender: "${formData.gender}" (empty: ${formData.gender.isEmpty})',
    );
    print('  - petType: "${formData.petType}"');

    // フォーム基本検証
    if (!formKey.currentState!.validate()) {
      print('❌ Form validation failed - basic form validation');

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

    // 品種検証
    final breedValidation = controller.validateBreed();
    if (breedValidation != null) {
      print('❌ Breed validation failed: $breedValidation');
      throw PetRegistrationException(breedValidation);
    }

    // 性別検証
    final genderValidation = controller.validateGender();
    if (genderValidation != null) {
      print('❌ Gender validation failed: $genderValidation');
      throw PetRegistrationException(genderValidation);
    }

    print('✅ All validations passed, proceeding with registration');
    // 実際の登録処理
    await controller.submitForm();
  }

  /// 生年月日選択ロジック
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
      print(
        '🎯 PetRegistrationLogic: selectPetImage called with currentImagePath: $currentImagePath',
      );
      print('🎯 PetRegistrationLogic: context.mounted: ${context.mounted}');

      final result = await ImageService.showImagePickerOptions(
        context,
        allowRemoval: currentImagePath != null,
        currentImagePath: currentImagePath,
      );

      print('🎯 PetRegistrationLogic: ImageService returned: $result');

      if (result == null) {
        print('🎯 PetRegistrationLogic: Result is null, returning null');
        return null;
      }
      if (result == 'REMOVE') {
        print('🎯 PetRegistrationLogic: Result is REMOVE, returning REMOVE');
        return 'REMOVE';
      }

      print(
        '🎯 PetRegistrationLogic: Result is valid image path, returning: $result',
      );
      return result;
    } catch (e, stackTrace) {
      print('🎯 PetRegistrationLogic: Exception in selectPetImage: $e');
      print('🎯 PetRegistrationLogic: Stack trace: $stackTrace');
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
