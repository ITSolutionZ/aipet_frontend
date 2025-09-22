import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../app/config/app_config.dart';
import '../../../../shared/testing/mock_data/features/ai/ai_config_mock_data.dart';
import '../../domain/domain.dart';

/// 로깅 레벨 열거형
enum _LogLevel { debug, info, warning, error }

/// AI 기능 환경별 설정 서비스
///
/// Mock 모드와 실제 API 모드를 구분하여 적절한 데이터 소스를 선택합니다.
class AiConfigService {
  static late final Dio _dio;
  static late final Logger _logger;

  // API 설정
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 60);
  static const int _maxRetries = 3;
  static const Duration _cacheTimeout = Duration(minutes: 30);

  // 캐시 저장소
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// 현재 Mock 모드 여부
  static bool get isMockMode => AppConfig.current.isMockMode;

  /// 서비스 초기화
  static Future<void> initialize() async {
    try {
      _initializeLogger();
      _initializeDio();
      _logInfo('AiConfigService initialized successfully');
    } catch (e) {
      // Logger가 아직 초기화되지 않은 경우 print 사용
      // ignore: avoid_print
      print('[AI_CONFIG_ERROR] Failed to initialize service: $e');
      rethrow;
    }
  }

  /// Logger 초기화
  static void _initializeLogger() {
    _logger = Logger(
      filter: AppConfig.current.isDebugMode
          ? DevelopmentFilter()
          : ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: AppConfig.current.isDebugMode ? 2 : 0,
        errorMethodCount: 3,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );
  }

  /// Logger 인스턴스 가져오기 (지연 초기화)
  static Logger get _loggerInstance {
    try {
      return _logger;
    } catch (e) {
      _initializeLogger();
      return _logger;
    }
  }

  /// Dio 인스턴스 초기화
  static void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConfig.current.apiBaseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = _connectTimeout;
    _dio.options.receiveTimeout = _receiveTimeout;

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logInfo('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          _logError('API Error: ${error.message}', error);
          if (error.response != null) {
            _logWarning('Status: ${error.response?.statusCode}');
            _logDebug('Response Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Dio 인스턴스 가져오기 (지연 초기화)
  static Dio get _dioInstance {
    try {
      return _dio;
    } catch (e) {
      _initializeDio();
      return _dio;
    }
  }

  /// AI 카테고리 데이터 가져오기
  static Future<List<AiCategoryEntity>> getCategories() async {
    const cacheKey = 'ai_categories';

    // 캐시에서 먼저 확인
    final cachedData = _getFromCache<List<AiCategoryEntity>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    List<AiCategoryEntity> result;
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockCategories();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadCategoriesFromApi();
    }

    // 캐시에 저장
    _setCache(cacheKey, result);
    return result;
  }

  /// AI 추천 질문 가져오기
  static Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    const cacheKey = 'ai_suggested_questions';

    // 캐시에서 먼저 확인
    final cachedData = _getFromCache<List<AiSuggestedQuestionEntity>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    List<AiSuggestedQuestionEntity> result;
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockSuggestedQuestions();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadSuggestedQuestionsFromApi();
    }

    // 캐시에 저장
    _setCache(cacheKey, result);
    return result;
  }

  /// AI 응답 템플릿 가져오기
  static Future<Map<String, String>> getResponseTemplates() async {
    const cacheKey = 'ai_response_templates';

    // 캐시에서 먼저 확인
    final cachedData = _getFromCache<Map<String, String>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    Map<String, String> result;
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockResponseTemplates();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadResponseTemplatesFromApi();
    }

    // 캐시에 저장
    _setCache(cacheKey, result);
    return result;
  }

  /// 키워드 매핑 가져오기
  static Future<Map<String, List<String>>> getKeywordMapping() async {
    const cacheKey = 'ai_keyword_mapping';

    // 캐시에서 먼저 확인
    final cachedData = _getFromCache<Map<String, List<String>>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    Map<String, List<String>> result;
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockKeywordMapping();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadKeywordMappingFromApi();
    }

    // 캐시에 저장
    _setCache(cacheKey, result);
    return result;
  }

  // Private methods for Mock data
  static List<AiCategoryEntity> _getMockCategories() {
    return AiConfigMockData.getMockCategories();
  }

  static List<AiSuggestedQuestionEntity> _getMockSuggestedQuestions() {
    return AiConfigMockData.getMockSuggestedQuestions();
  }

  static Map<String, String> _getMockResponseTemplates() {
    return AiConfigMockData.getMockResponseTemplates();
  }

  static Map<String, List<String>> _getMockKeywordMapping() {
    return AiConfigMockData.getMockKeywordMapping();
  }

  // Private methods for API calls
  static Future<List<AiCategoryEntity>> _loadCategoriesFromApi() async {
    return _trackApiPerformance('load_categories', () async {
      return _executeWithRetry(() async {
        final response = await _dioInstance.get('/ai/categories');

        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> data = response.data['data'] ?? response.data;
          return data.map((json) => _mapToAiCategoryEntity(json)).toList();
        } else {
          throw Exception('AIカテゴリデータの取得に失敗しました');
        }
      });
    });
  }

  static Future<List<AiSuggestedQuestionEntity>>
  _loadSuggestedQuestionsFromApi() async {
    return _executeWithRetry(() async {
      final response = await _dioInstance.get('/ai/suggested-questions');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data
            .map((json) => _mapToAiSuggestedQuestionEntity(json))
            .toList();
      } else {
        throw Exception('AI推奨質問データの取得に失敗しました');
      }
    });
  }

  static Future<Map<String, String>> _loadResponseTemplatesFromApi() async {
    return _executeWithRetry(() async {
      final response = await _dioInstance.get('/ai/response-templates');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data['data'] ?? response.data;
        return data.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('AI応答テンプレートデータの取得に失敗しました');
      }
    });
  }

  static Future<Map<String, List<String>>> _loadKeywordMappingFromApi() async {
    return _executeWithRetry(() async {
      final response = await _dioInstance.get('/ai/keyword-mapping');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data['data'] ?? response.data;
        return data.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.map((e) => e.toString()).toList());
          } else {
            return MapEntry(key, <String>[]);
          }
        });
      } else {
        throw Exception('AIキーワードマッピングデータの取得に失敗しました');
      }
    });
  }

  /// 재시도 로직이 포함된 API 호출 실행
  static Future<T> _executeWithRetry<T>(Future<T> Function() apiCall) async {
    int retryCount = 0;
    late Exception lastException;

    while (retryCount < _maxRetries) {
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
          if (retryCount < _maxRetries) {
            final delay = Duration(seconds: retryCount * 2); // 지수 백오프
            _logInfo(
              'Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$_maxRetries)',
            );
            await Future.delayed(delay);
            continue;
          }
        }

        throw lastException;
      } catch (e) {
        lastException = Exception('Unexpected error: $e');
        retryCount++;
        if (retryCount < _maxRetries) {
          final delay = Duration(seconds: retryCount * 2);
          _logInfo(
            'Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$_maxRetries)',
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
  static Exception _handleDioException(DioException e) {
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

  /// 현재 로깅 레벨 (개발 중에는 debug, 프로덕션에서는 info)
  static _LogLevel get _currentLogLevel {
    return AppConfig.current.isDebugMode ? _LogLevel.debug : _LogLevel.info;
  }

  /// 에러 로깅
  static void _logError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (_currentLogLevel.index <= _LogLevel.error.index) {
      // Logger를 사용한 로깅
      _loggerInstance.e(message, error: error, stackTrace: stackTrace);

      // Sentry를 사용한 에러 추적
      if (error != null) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('service', 'ai_config');
            scope.setExtra('ai_config_error', {
              'message': message,
              'timestamp': DateTime.now().toIso8601String(),
            });
          },
        );
      } else {
        // 에러 객체가 없는 경우 메시지만 Sentry에 전송
        Sentry.captureMessage(
          message,
          level: SentryLevel.error,
          withScope: (scope) {
            scope.setTag('service', 'ai_config');
            scope.setExtra('ai_config_error', {
              'timestamp': DateTime.now().toIso8601String(),
            });
          },
        );
      }
    }
  }

  /// 정보 로깅
  static void _logInfo(String message) {
    if (_currentLogLevel.index <= _LogLevel.info.index) {
      _loggerInstance.i(message);
    }
  }

  /// 경고 로깅
  static void _logWarning(String message) {
    if (_currentLogLevel.index <= _LogLevel.warning.index) {
      _loggerInstance.w(message);

      // 경고도 Sentry에 전송 (선택적)
      if (AppConfig.current.isDebugMode) {
        Sentry.captureMessage(
          message,
          level: SentryLevel.warning,
          withScope: (scope) {
            scope.setTag('service', 'ai_config');
            scope.setTag('type', 'warning');
          },
        );
      }
    }
  }

  /// 디버그 로깅
  static void _logDebug(String message) {
    if (_currentLogLevel.index <= _LogLevel.debug.index &&
        AppConfig.current.isDebugMode) {
      _loggerInstance.d(message);
    }
  }

  /// 캐시에서 데이터 가져오기
  static T? _getFromCache<T>(String key) {
    if (_cache.containsKey(key) && _cacheTimestamps.containsKey(key)) {
      final cacheTime = _cacheTimestamps[key]!;
      if (DateTime.now().difference(cacheTime) < _cacheTimeout) {
        _logDebug('Cache hit for key: $key');
        return _cache[key] as T?;
      } else {
        _logDebug('Cache expired for key: $key');
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  /// 캐시에 데이터 저장하기
  static void _setCache<T>(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    _logDebug('Data cached for key: $key');
  }

  /// 캐시 초기화
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _logInfo('Cache cleared');
  }

  /// 특정 키의 캐시 제거
  static void clearCacheForKey(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _logInfo('Cache cleared for key: $key');
  }

  /// 캐시 상태 정보 가져오기
  static Map<String, dynamic> getCacheStatus() {
    final now = DateTime.now();
    final status = <String, dynamic>{
      'totalKeys': _cache.length,
      'keys': <String>[],
      'expiredKeys': <String>[],
    };

    for (final key in _cache.keys) {
      status['keys'].add(key);
      if (_cacheTimestamps.containsKey(key)) {
        final cacheTime = _cacheTimestamps[key]!;
        if (now.difference(cacheTime) >= _cacheTimeout) {
          status['expiredKeys'].add(key);
        }
      }
    }

    return status;
  }

  /// 캐시 만료된 항목들 자동 정리
  static void cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheTimeout) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logInfo('Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }

  /// 서비스 상태 확인
  static Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      // 기본 상태 정보
      final status = {
        'isMockMode': isMockMode,
        'cacheStatus': getCacheStatus(),
        'lastCheck': DateTime.now().toIso8601String(),
      };

      // Mock 모드가 아닌 경우 API 연결 상태 확인
      if (!isMockMode) {
        try {
          final response = await _dioInstance.get(
            '/health',
            options: Options(receiveTimeout: const Duration(seconds: 5)),
          );
          status['apiStatus'] = response.statusCode == 200
              ? 'healthy'
              : 'unhealthy';
        } catch (e) {
          status['apiStatus'] = 'unreachable';
          status['apiError'] = e.toString();

          // API 상태 에러를 Sentry에 전송
          Sentry.captureException(
            e,
            withScope: (scope) {
              scope.setTag('service', 'ai_config');
              scope.setTag('type', 'health_check_failed');
              scope.setExtra('health_check', {
                'api_status': 'unreachable',
                'timestamp': DateTime.now().toIso8601String(),
              });
            },
          );
        }
      }

      return status;
    } catch (e) {
      _logError('Failed to get service status', e);
      return {
        'error': e.toString(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 성능 메트릭 기록
  static void _recordPerformanceMetric(String operation, Duration duration) {
    _logDebug('Performance: $operation took ${duration.inMilliseconds}ms');

    // Sentry에 성능 메트릭 전송
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'Performance metric: $operation',
        data: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
        category: 'performance',
        level: SentryLevel.info,
      ),
    );
  }

  /// API 호출 성능 추적
  static Future<T> _trackApiPerformance<T>(
    String operation,
    Future<T> Function() apiCall,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await apiCall();
      stopwatch.stop();
      _recordPerformanceMetric(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordPerformanceMetric('${operation}_error', stopwatch.elapsed);
      rethrow;
    }
  }

  /// JSON을 AiCategoryEntity로 매핑
  static AiCategoryEntity _mapToAiCategoryEntity(Map<String, dynamic> json) {
    return AiCategoryEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: Icons.pets, // 기본 아이콘 사용
      color: Colors.blue, // 기본 색상 사용
    );
  }

  /// JSON을 AiSuggestedQuestionEntity로 매핑
  static AiSuggestedQuestionEntity _mapToAiSuggestedQuestionEntity(
    Map<String, dynamic> json,
  ) {
    return AiSuggestedQuestionEntity(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      icon: Icons.help_outline, // 기본 아이콘 사용
    );
  }
}
