import 'result.dart';

/// UseCase 기본 클래스 - 공통 패턴 제공
abstract class BaseUseCase<T, P> {
  Future<Result<T>> call(P params);
}

/// 파라미터가 없는 UseCase 기본 클래스
abstract class BaseUseCaseNoParams<T> {
  Future<Result<T>> call();
}

/// UseCase 구현을 위한 믹스인
mixin UseCaseMixin<T, P> {
  /// 공통 에러 처리
  Result<T> handleError(dynamic error, String operation) {
    final errorMessage = _getErrorMessage(error, operation);
    return Result.failure(errorMessage, error is Exception ? error : Exception(error.toString()));
  }

  /// 에러 메시지 생성
  String _getErrorMessage(dynamic error, String operation) {
    if (error is Exception) {
      final errorMessage = error.toString();

      // 네트워크 관련 에러
      if (errorMessage.contains('SocketException') || errorMessage.contains('HandshakeException')) {
        return 'ネットワーク接続エラーが発生しました';
      }

      if (errorMessage.contains('TimeoutException')) {
        return 'タイムアウトが発生しました';
      }

      // HTTP 관련 에러
      if (errorMessage.contains('404')) {
        return 'データが見つかりませんでした';
      }

      if (errorMessage.contains('401')) {
        return '認証が必要です';
      }

      if (errorMessage.contains('403')) {
        return 'アクセスが拒否されました';
      }

      if (errorMessage.contains('500')) {
        return 'サーバーエラーが発生しました';
      }
    }

    return '$operationに失敗しました: ${error.toString()}';
  }
}

/// Repository를 사용하는 UseCase 기본 클래스
abstract class RepositoryUseCase<T, P, R> extends BaseUseCase<T, P> with UseCaseMixin<T, P> {
  final R repository;

  RepositoryUseCase(this.repository);

  @override
  Future<Result<T>> call(P params) async {
    try {
      return await execute(params);
    } catch (error) {
      return handleError(error, operationName);
    }
  }

  /// 실제 비즈니스 로직 실행
  Future<Result<T>> execute(P params);

  /// 작업 이름 (에러 메시지용)
  String get operationName;
}

/// 파라미터가 없는 Repository UseCase
abstract class RepositoryUseCaseNoParams<T, R> extends BaseUseCaseNoParams<T>
    with UseCaseMixin<T, void> {
  final R repository;

  RepositoryUseCaseNoParams(this.repository);

  @override
  Future<Result<T>> call() async {
    try {
      return await execute();
    } catch (error) {
      return handleError(error, operationName);
    }
  }

  /// 실제 비즈니스 로직 실행
  Future<Result<T>> execute();

  /// 작업 이름 (에러 메시지용)
  String get operationName;
}
