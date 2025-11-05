import '../../../shared/shared.dart';

/// 🎯 통합 유효성 검사 서비스
///
/// AI와 Auth 기능에서 공통으로 사용하는 유효성 검사 로직을 제공합니다.
class UnifiedValidationService extends BaseLoggingService {
  static final UnifiedValidationService _instance =
      UnifiedValidationService._internal();
  factory UnifiedValidationService() => _instance;
  UnifiedValidationService._internal() : super('unified_validation');

  /// 이메일 유효성 검사
  Result<bool> validateEmail(String email) {
    if (email.isEmpty) {
      return Result.failure('メールアドレスを入力してください');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return Result.failure('有効なメールアドレスを入力してください');
    }

    return Result.success('유효한 이메일입니다', true);
  }

  /// 비밀번호 유효성 검사
  Result<bool> validatePassword(String password) {
    if (password.isEmpty) {
      return Result.failure('パスワードを入力してください');
    }

    if (password.length < 6) {
      return Result.failure('パスワードは6文字以上で入力してください');
    }

    if (password.length > 128) {
      return Result.failure('パスワードは128文字以内で入力してください');
    }

    return Result.success('유효한 비밀번호입니다', true);
  }

  /// 사용자명 유효성 검사
  Result<bool> validateUsername(String username) {
    if (username.isEmpty) {
      return Result.failure('ユーザー名を入力してください');
    }

    if (username.length < 2) {
      return Result.failure('ユーザー名は2文字以上で入力してください');
    }

    if (username.length > 50) {
      return Result.failure('ユーザー名は50文字以内で入力してください');
    }

    // 특수문자 검사
    final usernameRegex = RegExp(
      r'^[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+$',
    );
    if (!usernameRegex.hasMatch(username)) {
      return Result.failure('ユーザー名は英数字、ひらがな、カタカナ、漢字、アンダースコアのみ使用できます');
    }

    return Result.success('유효한 사용자명입니다', true);
  }

  /// 메시지 유효성 검사 (AI 채팅용)
  Result<bool> validateMessage(String message) {
    if (message.isEmpty) {
      return Result.failure('メッセージを入力してください');
    }

    if (message.length > 2000) {
      return Result.failure('メッセージは2000文字以内で入力してください');
    }

    return Result.success('유효한 메시지입니다', true);
  }

  /// 펫 이름 유효성 검사
  Result<bool> validatePetName(String petName) {
    if (petName.isEmpty) {
      return Result.failure('ペットの名前を入力してください');
    }

    if (petName.length > 50) {
      return Result.failure('ペットの名前は50文字以内で入力してください');
    }

    return Result.success('유효한 펫 이름입니다', true);
  }

  /// 전화번호 유효성 검사
  Result<bool> validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return Result.failure('電話番号を入力してください');
    }

    // 일본 전화번호 형식 검사
    final phoneRegex = RegExp(r'^(\+81|0)[0-9]{1,4}[0-9]{1,4}[0-9]{4}$');
    if (!phoneRegex.hasMatch(phoneNumber.replaceAll('-', ''))) {
      return Result.failure('有効な電話番号を入力してください');
    }

    return Result.success('유효한 전화번호입니다', true);
  }

  /// 복합 유효성 검사 (여러 필드 동시 검사)
  Result<bool> validateMultiple(Map<String, String> fields) {
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      Result<bool> result;
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
          result = Result.failure('未知のフィールド: $fieldName');
      }

      if (!result.isSuccess) {
        return result;
      }
    }

    return Result.success('모든 필드가 유효합니다', true);
  }
}
