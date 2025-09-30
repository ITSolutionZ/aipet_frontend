import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:dio/dio.dart';

/// 🎯 AI 공통 Dio 서비스
///
/// AI 관련 서비스들이 공통으로 사용하는 Dio 인스턴스를 관리합니다.
///
/// ## 주요 기능
/// - 중앙화된 HTTP 클라이언트 관리
/// - 공통 인터셉터 및 에러 처리
/// - 환경별 설정 관리
/// - 로깅 및 모니터링
class AiDioService extends BaseLoggingService {
  static AiDioService? _instance;
  late final Dio _dio;

  // API 설정 상수
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 60);
  static const int _maxRetries = 3;

  AiDioService._() : super('ai_dio_service') {
    _initializeDio();
  }

  /// 싱글톤 인스턴스 반환
  static AiDioService get instance {
    _instance ??= AiDioService._();
    return _instance!;
  }

  /// Dio 인스턴스 반환
  Dio get dio => _dio;

  /// OpenAI 전용 Dio 인스턴스 생성
  Dio createOpenAIDio() {
    final dio = Dio();
    dio.options.baseUrl = 'https://api.openai.com/v1';
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.connectTimeout = _connectTimeout;
    dio.options.receiveTimeout = _receiveTimeout;

    // OpenAI 전용 인터셉터 추가
    dio.interceptors.add(
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

    return dio;
  }

  /// 일반 API 전용 Dio 인스턴스 생성
  Dio createApiDio() {
    final dio = Dio();
    dio.options.baseUrl = AppConfig.current.apiBaseUrl;
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.connectTimeout = _connectTimeout;
    dio.options.receiveTimeout = _receiveTimeout;

    // 일반 API 전용 인터셉터 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logInfo('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          logError('API Error: ${error.message}', error);
          if (error.response != null) {
            logWarning('Status: ${error.response?.statusCode}');
            logDebug('Response Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Dio 인스턴스 초기화
  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConfig.current.apiBaseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = _connectTimeout;
    _dio.options.receiveTimeout = _receiveTimeout;

    // 공통 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logInfo('HTTP Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          logError('HTTP Error: ${error.message}', error);
          if (error.response != null) {
            logWarning('Status: ${error.response?.statusCode}');
            logDebug('Response Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 재시도 로직이 포함된 API 호출 실행 (공통 HttpClientService 사용)
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall, {int? maxRetries}) async {
    // 공통 HttpClientService의 재시도 로직을 사용
    // 이 메서드는 하위 호환성을 위해 유지하지만,
    // 새로운 코드에서는 AiHttpClientService를 직접 사용하는 것을 권장
    logWarning('executeWithRetry is deprecated. Use AiHttpClientService instead.');

    // 임시로 기본 재시도 로직 구현
    final retries = maxRetries ?? _maxRetries;
    int retryCount = 0;
    late Exception lastException;

    while (retryCount < retries) {
      try {
        return await apiCall();
      } on DioException catch (e) {
        lastException = _handleDioException(e);

        // 재시도하지 않을 에러들
        if (e.response?.statusCode == 401 || // Unauthorized
            e.response?.statusCode == 403 || // Forbidden
            e.response?.statusCode == 400) {
          // Bad request
          throw lastException;
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

        throw lastException;
      } catch (e) {
        lastException = Exception('Unexpected error: $e');
        retryCount++;
        if (retryCount < retries) {
          final delay = Duration(seconds: retryCount * 2);
          logInfo(
            'Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$retries)',
          );
          await Future.delayed(delay);
          continue;
        }
        throw lastException;
      }
    }

    throw lastException;
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

  /// 인스턴스 초기화 (테스트용)
  static void resetInstance() {
    _instance = null;
  }
}
