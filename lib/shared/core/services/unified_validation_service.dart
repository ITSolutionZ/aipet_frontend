import 'package:aipet_frontend/shared/services/base_logging_service.dart';

/// 🎯 통합 유효성 검사 서비스
///
/// AI와 Auth 기능에서 공통으로 사용하는 유효성 검사 로직을 제공합니다.
class UnifiedValidationService extends BaseLoggingService {
  static final UnifiedValidationService _instance =
      UnifiedValidationService._internal();
  factory UnifiedValidationService() => _instance;
  UnifiedValidationService._internal() : super('unified_validation');

  /// 이메일 유효성 검사
  UnifiedValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return UnifiedValidationFailure('メールアドレスを入力してください');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return UnifiedValidationFailure('有効なメールアドレスを入力してください');
    }

    return UnifiedValidationResult.success();
  }

  /// 비밀번호 유효성 검사
  UnifiedValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return UnifiedValidationFailure('パスワードを入力してください');
    }

    if (password.length < 6) {
      return UnifiedValidationFailure('パスワードは6文字以上で入力してください');
    }

    if (password.length > 128) {
      return UnifiedValidationFailure('パスワードは128文字以内で入力してください');
    }

    return UnifiedValidationResult.success();
  }

  /// 사용자명 유효성 검사
  UnifiedValidationResult validateUsername(String username) {
    if (username.isEmpty) {
      return UnifiedValidationFailure('ユーザー名を入力してください');
    }

    if (username.length < 2) {
      return UnifiedValidationFailure('ユーザー名は2文字以上で入力してください');
    }

    if (username.length > 50) {
      return UnifiedValidationFailure('ユーザー名は50文字以内で入力してください');
    }

    // 특수문자 검사
    final usernameRegex = RegExp(
      r'^[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+$',
    );
    if (!usernameRegex.hasMatch(username)) {
      return UnifiedValidationFailure(
        'ユーザー名は英数字、ひらがな、カタカナ、漢字、アンダースコアのみ使用できます',
      );
    }

    return UnifiedValidationResult.success();
  }

  /// 메시지 유효성 검사 (AI 채팅용)
  UnifiedValidationResult validateMessage(String message) {
    if (message.isEmpty) {
      return UnifiedValidationFailure('メッセージを入力してください');
    }

    if (message.length > 2000) {
      return UnifiedValidationFailure('メッセージは2000文字以内で入力してください');
    }

    return UnifiedValidationResult.success();
  }

  /// 펫 이름 유효성 검사
  UnifiedValidationResult validatePetName(String petName) {
    if (petName.isEmpty) {
      return UnifiedValidationFailure('ペットの名前を入力してください');
    }

    if (petName.length > 50) {
      return UnifiedValidationFailure('ペットの名前は50文字以内で入力してください');
    }

    return UnifiedValidationResult.success();
  }

  /// 전화번호 유효성 검사
  UnifiedValidationResult validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return UnifiedValidationFailure('電話番号を入力してください');
    }

    // 일본 전화번호 형식 검사
    final phoneRegex = RegExp(r'^(\+81|0)[0-9]{1,4}[0-9]{1,4}[0-9]{4}$');
    if (!phoneRegex.hasMatch(phoneNumber.replaceAll('-', ''))) {
      return UnifiedValidationFailure('有効な電話番号を入力してください');
    }

    return UnifiedValidationResult.success();
  }

  /// 복합 유효성 검사 (여러 필드 동시 검사)
  UnifiedValidationResult validateMultiple(Map<String, String> fields) {
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      UnifiedValidationResult result;
      switch (fieldName.toLowerCase()) {
        case 'email':
          result = validateEmail(value);
          break;
        case 'password':
          result = validatePassword(value);
          break;
        case 'username':
          result = validateUsername(value);
          break;
        case 'message':
          result = validateMessage(value);
          break;
        case 'petname':
          result = validatePetName(value);
          break;
        case 'phone':
          result = validatePhoneNumber(value);
          break;
        default:
          result = UnifiedValidationFailure('未知のフィールド: $fieldName');
      }

      if (!result.isValid) {
        return result;
      }
    }

    return UnifiedValidationResult.success();
  }
}

/// 유효성 검사 결과 클래스
class UnifiedValidationResult {
  final bool isValid;
  final String? errorMessage;

  const UnifiedValidationResult._(this.isValid, this.errorMessage);

  factory UnifiedValidationResult.success() =>
      const UnifiedValidationResult._(true, null);
  factory UnifiedValidationFailure(String message) =>
      UnifiedValidationResult._(false, message);

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}
