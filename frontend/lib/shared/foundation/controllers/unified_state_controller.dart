import '../../../shared/shared.dart';

/// 🎯 통합 상태 관리 컨트롤러
///
/// AI와 Auth 기능에서 공통으로 사용하는 상태 관리 패턴을 제공합니다.
/// 로깅, 에러 처리, 폼 검증 등의 공통 기능을 포함합니다.
abstract class UnifiedStateController<T> extends FormController<T> {
  late final BaseLoggingService _loggingService;

  UnifiedStateController(super.ref, String serviceName) {
    _loggingService = _LoggingService(serviceName);
  }

  /// 공통 에러 처리
  void handleCommonError(dynamic error, [StackTrace? stackTrace]) {
    _loggingService.logError('Controller error: $error', error, stackTrace);
    // 통합 에러 핸들러로 에러 전송
    // UnifiedErrorHandler.handleUnifiedError(error, context: {'controller': serviceName});
  }

  /// 공통 로딩 상태 관리
  void setLoading(bool isLoading) {
    // 하위 클래스에서 구현
  }

  /// 공통 에러 상태 관리
  void setError(String? error) {
    // 하위 클래스에서 구현
  }

  /// 공통 성공 상태 관리
  void setSuccess(String? message) {
    _loggingService.logInfo('Operation successful: $message');
    // 하위 클래스에서 구현
  }

  /// 폼 유효성 검사 (공통 패턴)
  bool validateCommonFields(Map<String, String> fields) {
    for (final entry in fields.entries) {
      if (entry.value.isEmpty) {
        setError('${entry.key}は必須項目です');
        return false;
      }
    }
    return true;
  }

  /// 이메일 유효성 검사 (공통)
  @override
  Result<void> validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      setError('有効なメールアドレスを入力してください');
      return Result.failure('有効なメールアドレスを入力してください');
    }
    return Result.success('', null);
  }

  /// 비밀번호 유효성 검사 (공통)
  @override
  Result<void> validatePassword(String password) {
    if (password.length < 6) {
      setError('パスワードは6文字以上で入力してください');
      return Result.failure('パスワードは6文字以上で入力してください');
    }
    return Result.success('', null);
  }

  /// 사용자명 유효성 검사 (공통)
  @override
  Result<void> validateUsername(String username) {
    if (username.length < 2) {
      setError('ユーザー名は2文字以上で入力してください');
      return Result.failure('ユーザー名は2文字以上で入力してください');
    }
    return Result.success('', null);
  }
}

/// BaseLoggingService의 구체적인 구현체
class _LoggingService extends BaseLoggingService {
  _LoggingService(super.serviceName);
}
