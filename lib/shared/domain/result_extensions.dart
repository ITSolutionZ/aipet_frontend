import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// Result 타입 확장 메서드들
///
/// 기존 Result 타입에 누락된 메서드들을 추가합니다.
extension ResultExtensions<T> on Result<T> {
  // 확장 메서드들은 여기에 추가할 수 있습니다
}

/// Result 유틸리티 클래스
class ResultUtils {
  /// 성공 결과 생성 (유틸리티 메서드)
  static Result<T> createSuccess<T>(T data, [String? message]) {
    return ResultFactory.success(data, message ?? 'Success');
  }

  /// 실패 결과 생성 (유틸리티 메서드)
  static Result<T> createFailure<T>(String error) {
    return ResultFactory.failure<T>(error);
  }
}
