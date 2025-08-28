/// 스플래시 기능 공통 결과 클래스
class SplashResult<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final Exception? error;

  const SplashResult._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.error,
  });

  factory SplashResult.success(String message, [T? data]) => SplashResult._(
        isSuccess: true,
        message: message,
        data: data,
      );

  factory SplashResult.failure(String message, [Exception? error]) =>
      SplashResult._(
        isSuccess: false,
        message: message,
        error: error,
      );

  @override
  String toString() => 'SplashResult(isSuccess: $isSuccess, message: $message)';
}