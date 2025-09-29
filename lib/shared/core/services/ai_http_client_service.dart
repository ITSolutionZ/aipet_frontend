import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/http_client_service.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:dio/dio.dart';

/// 🎯 AI 전용 HTTP 클라이언트 서비스
///
/// AI 기능에서 사용하는 HTTP 통신을 공통 HttpClientService로 통합합니다.
/// OpenAI API와 일반 API를 모두 지원합니다.
class AiHttpClientService extends BaseLoggingService {
  final HttpClientService _httpClient;
  late final Dio _openAIDio;

  AiHttpClientService({HttpClientService? httpClient})
    : _httpClient = httpClient ?? HttpClientService.instance,
      super('ai_http_client') {
    _initializeOpenAIDio();
  }

  /// OpenAI 전용 Dio 인스턴스 초기화
  void _initializeOpenAIDio() {
    _openAIDio = Dio();
    _openAIDio.options.baseUrl = 'https://api.openai.com/v1';
    _openAIDio.options.headers['Content-Type'] = 'application/json';
    _openAIDio.options.connectTimeout = const Duration(seconds: 30);
    _openAIDio.options.receiveTimeout = const Duration(seconds: 60);

    // OpenAI 전용 인터셉터 추가
    _openAIDio.interceptors.add(
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

  /// OpenAI API 호출 (재시도 로직 포함)
  Future<Result<T>> callOpenAI<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return trackApiPerformance('openai_$endpoint', () async {
      try {
        final response = await _openAIDio.post(endpoint, data: data);

        if (response.statusCode == 200 && response.data != null) {
          final responseData = response.data as Map<String, dynamic>;
          T result;
          if (fromJson != null) {
            result = fromJson(responseData);
          } else {
            result = responseData as T;
          }
          return Result.success('OpenAI API 호출이 성공했습니다', result);
        } else {
          return Result.failure('OpenAI API 응답 오류: ${response.statusCode}');
        }
      } catch (e) {
        logError('OpenAI API 호출 실패: $e');
        return Result.failure('OpenAI API 호출 실패: $e');
      }
    });
  }

  /// 일반 API 호출 (공통 HttpClientService 사용)
  Future<Result<T>> callApi<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return trackApiPerformance('api_$endpoint', () async {
      try {
        final response = await _httpClient.post<T>(
          endpoint,
          data: data,
          fromJson: fromJson,
        );

        if (response.isSuccess) {
          return Result.success('API 호출이 성공했습니다', response.data as T);
        } else {
          return Result.failure('API 호출 실패: ${response.message}');
        }
      } catch (e) {
        logError('API 호출 실패: $e');
        return Result.failure('API 호출 실패: $e');
      }
    });
  }

  /// GET 요청
  Future<Result<T>> getApi<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return trackApiPerformance('get_$endpoint', () async {
      try {
        final response = await _httpClient.get<T>(
          endpoint,
          queryParameters: queryParameters,
          fromJson: fromJson,
        );

        if (response.isSuccess) {
          return Result.success('GET 요청이 성공했습니다', response.data as T);
        } else {
          return Result.failure('GET 요청 실패: ${response.message}');
        }
      } catch (e) {
        logError('GET 요청 실패: $e');
        return Result.failure('GET 요청 실패: $e');
      }
    });
  }

  /// PUT 요청
  Future<Result<T>> putApi<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return trackApiPerformance('put_$endpoint', () async {
      try {
        final response = await _httpClient.put<T>(
          endpoint,
          data: data,
          fromJson: fromJson,
        );

        if (response.isSuccess) {
          return Result.success('PUT 요청이 성공했습니다', response.data as T);
        } else {
          return Result.failure('PUT 요청 실패: ${response.message}');
        }
      } catch (e) {
        logError('PUT 요청 실패: $e');
        return Result.failure('PUT 요청 실패: $e');
      }
    });
  }

  /// DELETE 요청
  Future<Result<T>> deleteApi<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return trackApiPerformance('delete_$endpoint', () async {
      try {
        final response = await _httpClient.delete<T>(
          endpoint,
          fromJson: fromJson,
        );

        if (response.isSuccess) {
          return Result.success('DELETE 요청이 성공했습니다', response.data as T);
        } else {
          return Result.failure('DELETE 요청 실패: ${response.message}');
        }
      } catch (e) {
        logError('DELETE 요청 실패: $e');
        return Result.failure('DELETE 요청 실패: $e');
      }
    });
  }

  /// 재시도 로직이 포함된 API 호출 실행
  Future<Result<T>> executeWithRetry<T>(
    Future<Result<T>> Function() apiCall, {
    int? maxRetries,
  }) async {
    final retries = maxRetries ?? 3;
    int retryCount = 0;
    late Result<T> lastResult;

    while (retryCount < retries) {
      try {
        final result = await apiCall();
        if (result.isSuccess) {
          return result;
        }

        // 실패한 경우 재시도 여부 확인
        if (retryCount < retries - 1) {
          retryCount++;
          final delay = Duration(seconds: retryCount * 2); // 지수 백오프
          logInfo(
            'Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
          );
          await Future.delayed(delay);
          lastResult = result;
          continue;
        }

        return result;
      } on DioException catch (e) {
        final exception = _handleDioException(e);

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
            final delay = Duration(seconds: retryCount * 2); // 지수 백오프
            logInfo(
              'Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
            );
            await Future.delayed(delay);
            continue;
          }
        }

        return Result.failure(exception.toString());
      } catch (e) {
        retryCount++;
        if (retryCount < retries) {
          final delay = Duration(seconds: retryCount * 2);
          logInfo(
            'Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
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
