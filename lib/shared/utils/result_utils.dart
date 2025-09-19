import '../domain/result.dart';

/// Result 패턴을 위한 공통 유틸리티
///
/// Result 클래스는 domain/result.dart에서 import하여 사용합니다.

/// Result 생성 헬퍼 함수들
class ResultHelper {
  ResultHelper._();

  /// 비동기 작업을 Result로 래핑
  static Future<Result<T>> wrapAsync<T>(
    Future<T> Function() asyncFunction, {
    String? successMessage,
    String? failureMessage,
  }) async {
    try {
      final data = await asyncFunction();
      return Result.success(successMessage ?? '操作が完了しました', data);
    } catch (e) {
      return Result.failure(
        failureMessage ?? '操作に失敗しました: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 동기 작업을 Result로 래핑
  static Result<T> wrapSync<T>(
    T Function() syncFunction, {
    String? successMessage,
    String? failureMessage,
  }) {
    try {
      final data = syncFunction();
      return Result.success(successMessage ?? '操作が完了しました', data);
    } catch (e) {
      return Result.failure(
        failureMessage ?? '操作に失敗しました: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 조건부 성공/실패 Result 생성
  static Result<T> conditional<T>(
    bool condition,
    T data, {
    String? successMessage,
    String? failureMessage,
  }) {
    if (condition) {
      return Result.success(successMessage ?? '操作が完了しました', data);
    } else {
      return Result.failure(failureMessage ?? '条件が満たされていません');
    }
  }

  /// null 체크 후 Result 생성
  static Result<T> fromNullable<T>(
    T? data, {
    String? successMessage,
    String? failureMessage,
  }) {
    if (data != null) {
      return Result.success(successMessage ?? 'データが見つかりました', data);
    } else {
      return Result.failure(failureMessage ?? 'データが見つかりませんでした');
    }
  }
}
