import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 재시도 정책 인터셉터
///
/// 네트워크 오류나 일시적 서버 오류 시 exponential backoff로 재시도합니다.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final List<int> retryDelays;
  final List<int> retryStatusCodes;

  const RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelays = const [1000, 2000, 4000], // ms
    this.retryStatusCodes = const [500, 502, 503, 504], // 재시도할 HTTP 상태코드
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (shouldRetry && retryCount < maxRetries) {
      try {
        // 재시도 횟수 증가
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Exponential backoff 계산
        final delayMs = _calculateDelay(retryCount);

        if (kDebugMode) {
          debugPrint(
            '🔄 재시도 ${retryCount + 1}/$maxRetries after ${delayMs}ms - ${err.requestOptions.path}',
          );
        }

        // 지연 시간 대기
        await Future.delayed(const Duration(milliseconds: delayMs));

        // 재시도 실행
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ 재시도 실패: $e');
        }
        // 재시도도 실패하면 원래 에러 전달
      }
    }

    handler.next(err);
  }

  /// 재시도 여부 판단
  bool _shouldRetry(DioException err) {
    // 네트워크 연결 오류
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // 특정 HTTP 상태 코드
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  /// Exponential backoff 지연 시간 계산
  int _calculateDelay(int retryCount) {
    if (retryCount < retryDelays.length) {
      return retryDelays[retryCount];
    }

    // 기본 exponential backoff: 2^retryCount * 1000ms (최대 30초)
    final delay = pow(2, retryCount) * 1000;
    return min(delay.toInt(), 30000);
  }
}
