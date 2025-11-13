import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:dio/dio.dart';

/// 🎯 기본 OpenAI HTTP 클라이언트
///
/// OpenAI API와의 기본적인 HTTP 통신을 담당합니다.
/// 각 기능별 서비스에서 이 클라이언트를 사용하여 구체적인 비즈니스 로직을 구현합니다.
class OpenAiHttpClient extends BaseLoggingService {
  late final Dio _dio;

  OpenAiHttpClient() : super('openai_http_client') {
    _initializeDio();
  }

  /// Dio 인스턴스 초기화
  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

    // OpenAI 전용 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // API 키 자동 추가
          final apiKey = AppConfig.current.openaiApiKey;
          if (apiKey.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $apiKey';
          }
          logInfo('OpenAI API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          logError('OpenAI API Error: ${error.message}', error);
          if (error.response != null) {
            logWarning('Status: ${error.response?.statusCode}');
            logDebug('Response Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// OpenAI API 호출 (기본 메서드)
  Future<Result<Map<String, dynamic>>> callOpenAI(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success('OpenAI API 호출이 성공했습니다', responseData);
      } else {
        return Result.failure('OpenAI API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      logError('OpenAI API 호출 실패: $e');
      return Result.failure('OpenAI API 호출 실패: $e');
    }
  }

  /// 재시도 로직이 포함된 OpenAI API 호출
  Future<Result<Map<String, dynamic>>> callOpenAIWithRetry(
    String endpoint, {
    Map<String, dynamic>? data,
    int? maxRetries,
  }) async {
    final retries = maxRetries ?? 5;
    int retryCount = 0;
    late Result<Map<String, dynamic>> lastResult;

    while (retryCount < retries) {
      try {
        final result = await callOpenAI(endpoint, data: data);
        if (result.isSuccess) {
          return result;
        }

        // 실패한 경우 재시도 여부 확인
        if (retryCount < retries - 1) {
          retryCount++;
          final delay = Duration(seconds: retryCount * 2);
          logInfo(
            'Retrying OpenAI API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
          );
          await Future.delayed(delay);
          lastResult = result;
          continue;
        }

        return result;
      } on DioException catch (e) {
        final exception = _handleDioException(e);

        // ✅ OpenAI 에러 코드별 처리 (재시도 불가 에러들)
        final responseData = e.response?.data;
        if (responseData is Map && responseData['error'] != null) {
          final errorMap = responseData['error'];
          if (errorMap is Map) {
            final errorCode = errorMap['code'];
            final errorMessage = errorMap['message'];

            switch (errorCode) {
              case 'insufficient_quota':
                logError('OpenAI API quota 초과: $errorMessage');
                return Result.failure(
                  'OpenAI APIの利用枠を超過しました。\n'
                  'プランと請求情報を確認してください。',
                );
              case 'invalid_api_key':
              case 'invalid_request_error':
                logError('OpenAI API 키 오류: $errorMessage');
                return Result.failure(
                  'API設定に問題があります。\n'
                  '管理者にお問い合わせください。',
                );
              case 'model_not_found':
                logError('OpenAI 모델 오류: $errorMessage');
                return Result.failure('指定されたAIモデルが見つかりません。');
            }
          }
        }

        // 재시도하지 않을 에러들
        if (e.response?.statusCode == 401 || // Unauthorized
            e.response?.statusCode == 403 || // Forbidden
            e.response?.statusCode == 400) {
          // Bad request
          return Result.failure(exception.toString());
        }

        // 429(Rate limit) 또는 5xx 서버 에러의 경우 재시도
        final statusCode = e.response?.statusCode;
        if (statusCode == 429 || (statusCode != null && statusCode >= 500)) {
          retryCount++;
          if (retryCount < retries) {
            // 429 에러의 경우 Retry-After 헤더 확인 및 더 긴 딜레이 적용
            Duration delay;
            if (statusCode == 429) {
              // Retry-After 헤더 확인
              final retryAfter = e.response?.headers['retry-after']?.first;
              if (retryAfter != null) {
                final seconds = int.tryParse(retryAfter) ?? (retryCount * 5);
                delay = Duration(seconds: seconds);
                logInfo('Retry-After 헤더 감지: $seconds초 대기');
              } else {
                // OpenAI Rate Limit을 위한 더 긴 딜레이 (5초, 10초, 15초, 20초, 25초)
                delay = Duration(seconds: retryCount * 5);
              }
              logWarning(
                'Rate limit 초과 감지. ${delay.inSeconds}초 후 재시도... (attempt $retryCount/$retries)',
              );
            } else {
              // 5xx 에러는 기존 지수 백오프 유지
              delay = Duration(seconds: retryCount * 2);
              logInfo(
                'Retrying OpenAI API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
              );
            }
            await Future.delayed(delay);
            continue;
          } else {
            // 최대 재시도 횟수 초과 시 더 명확한 메시지
            if (statusCode == 429) {
              logError('Rate limit 초과로 최대 재시도 횟수($retries회)에 도달했습니다.');
              return Result.failure('API リクエスト制限を超えました。数分後に再試行してください。');
            }
          }
        }

        return Result.failure(exception.toString());
      } catch (e) {
        retryCount++;
        if (retryCount < retries) {
          final delay = Duration(seconds: retryCount * 2);
          logInfo(
            'Retrying OpenAI API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
          );
          await Future.delayed(delay);
          continue;
        }
        return Result.failure('Unexpected error: $e');
      }
    }

    return lastResult;
  }

  /// Dio 예외를 사용자 친화적인 메시지로 변환
  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('認証が必要です。ログインを確認してください。');
      case 403:
        return Exception('アクセス権限がありません。');
      case 404:
        return Exception('リクエストされたリソースが見つかりません。');
      case 429:
        return Exception('API リクエスト制限を超えました。しばらくしてから再試行してください。');
      case 500:
      case 502:
      case 503:
      case 504:
        return Exception('サーバーに一時的な問題が発生しています。しばらくしてから再試行してください。');
      case null:
        if (e.type == DioExceptionType.connectionTimeout) {
          return Exception('接続時間がタイムアウトしました。ネットワーク接続を確認してください。');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return Exception('応答時間がタイムアウトしました。しばらくしてから再試行してください。');
        } else if (e.type == DioExceptionType.connectionError) {
          return Exception('ネットワーク接続に問題があります。インターネット接続を確認してください。');
        }
        return Exception('ネットワークエラーが発生しました: ${e.message}');
      default:
        return Exception('API エラー (${e.response?.statusCode}): ${e.message}');
    }
  }
}
