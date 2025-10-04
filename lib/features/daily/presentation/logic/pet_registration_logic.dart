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
    // フォーム基本検証
    if (!formKey.currentState!.validate()) {
      throw const PetRegistrationException('フォーム検証に失敗しました');
    }

    // 品種検証
    final breedValidation = controller.validateBreed();
    if (breedValidation != null) {
      throw PetRegistrationException(breedValidation);
    }

    // 性別検証
    final genderValidation = controller.validateGender();
    if (genderValidation != null) {
      throw PetRegistrationException(genderValidation);
    }

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
      helpText: '집에 온 날 선택',
      cancelText: '취소',
      confirmText: '확인',
      fieldLabelText: '날짜 입력',
      fieldHintText: 'yyyy/mm/dd',
      errorFormatText: '올바른 날짜 형식이 아닙니다',
      errorInvalidText: '유효하지 않은 날짜입니다',
    );
    return picked;
  }

  /// ペット画像選択ロジック
  Future<String?> selectPetImage({
    required BuildContext context,
    String? currentImagePath,
  }) async {
    final result = await ImageService.showImagePickerOptions(
      context,
      allowRemoval: currentImagePath != null,
      currentImagePath: currentImagePath,
    );

    if (result == null) return null;
    if (result == 'REMOVE') return 'REMOVE';

    return result;
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
