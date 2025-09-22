import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../app/config/app_config.dart';
import '../../../../shared/services/base_logging_service.dart';
import '../../../../shared/testing/mock_data/features/ai/ai_config_mock_data.dart';
import '../../domain/domain.dart';
import 'ai_cache_service.dart';

/// 🎯 AI 데이터 서비스
///
/// AI 관련 데이터의 로딩과 관리를 담당
class AiDataService extends BaseLoggingService {
  late final Dio _dio;
  final AiCacheService _cacheService;

  // API 설정
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 60);
  static const int _maxRetries = 3;

  AiDataService(this._cacheService) : super('ai_data') {
    _initializeDio();
  }

  /// Dio 인스턴스 초기화
  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConfig.current.apiBaseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = _connectTimeout;
    _dio.options.receiveTimeout = _receiveTimeout;

    // 인터셉터 추가
    _dio.interceptors.add(
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
  }

  /// AI 카테고리 데이터 가져오기
  Future<List<AiCategoryEntity>> getCategories() async {
    const cacheKey = 'ai_categories';

    // 캐시에서 먼저 확인
    final cachedData = _cacheService.getFromCache<List<AiCategoryEntity>>(
      cacheKey,
    );
    if (cachedData != null) {
      return cachedData;
    }

    List<AiCategoryEntity> result;
    if (AppConfig.current.isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockCategories();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadCategoriesFromApi();
    }

    // 캐시에 저장
    _cacheService.setCache(cacheKey, result);
    return result;
  }

  /// AI 추천 질문 가져오기
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    const cacheKey = 'ai_suggested_questions';

    // 캐시에서 먼저 확인
    final cachedData = _cacheService
        .getFromCache<List<AiSuggestedQuestionEntity>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    List<AiSuggestedQuestionEntity> result;
    if (AppConfig.current.isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockSuggestedQuestions();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadSuggestedQuestionsFromApi();
    }

    // 캐시에 저장
    _cacheService.setCache(cacheKey, result);
    return result;
  }

  /// AI 응답 템플릿 가져오기
  Future<Map<String, String>> getResponseTemplates() async {
    const cacheKey = 'ai_response_templates';

    // 캐시에서 먼저 확인
    final cachedData = _cacheService.getFromCache<Map<String, String>>(
      cacheKey,
    );
    if (cachedData != null) {
      return cachedData;
    }

    Map<String, String> result;
    if (AppConfig.current.isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockResponseTemplates();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadResponseTemplatesFromApi();
    }

    // 캐시에 저장
    _cacheService.setCache(cacheKey, result);
    return result;
  }

  /// 키워드 매핑 가져오기
  Future<Map<String, List<String>>> getKeywordMapping() async {
    const cacheKey = 'ai_keyword_mapping';

    // 캐시에서 먼저 확인
    final cachedData = _cacheService.getFromCache<Map<String, List<String>>>(
      cacheKey,
    );
    if (cachedData != null) {
      return cachedData;
    }

    Map<String, List<String>> result;
    if (AppConfig.current.isMockMode) {
      // Mock 모드: 정적 데이터 반환
      result = _getMockKeywordMapping();
    } else {
      // 실제 API 모드: API에서 데이터 로드
      result = await _loadKeywordMappingFromApi();
    }

    // 캐시에 저장
    _cacheService.setCache(cacheKey, result);
    return result;
  }

  // Private methods for Mock data
  List<AiCategoryEntity> _getMockCategories() {
    return AiConfigMockData.getMockCategories();
  }

  List<AiSuggestedQuestionEntity> _getMockSuggestedQuestions() {
    return AiConfigMockData.getMockSuggestedQuestions();
  }

  Map<String, String> _getMockResponseTemplates() {
    return AiConfigMockData.getMockResponseTemplates();
  }

  Map<String, List<String>> _getMockKeywordMapping() {
    return AiConfigMockData.getMockKeywordMapping();
  }

  // Private methods for API calls
  Future<List<AiCategoryEntity>> _loadCategoriesFromApi() async {
    return trackApiPerformance('load_categories', () async {
      return _executeWithRetry(() async {
        final response = await _dio.get('/ai/categories');

        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> data = response.data['data'] ?? response.data;
          return data.map((json) => _mapToAiCategoryEntity(json)).toList();
        } else {
          throw Exception('AIカテゴリデータの取得に失敗しました');
        }
      });
    });
  }

  Future<List<AiSuggestedQuestionEntity>>
  _loadSuggestedQuestionsFromApi() async {
    return _executeWithRetry(() async {
      final response = await _dio.get('/ai/suggested-questions');

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

  Future<Map<String, String>> _loadResponseTemplatesFromApi() async {
    return _executeWithRetry(() async {
      final response = await _dio.get('/ai/response-templates');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data['data'] ?? response.data;
        return data.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('AI応答テンプレートデータの取得に失敗しました');
      }
    });
  }

  Future<Map<String, List<String>>> _loadKeywordMappingFromApi() async {
    return _executeWithRetry(() async {
      final response = await _dio.get('/ai/keyword-mapping');

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
  Future<T> _executeWithRetry<T>(Future<T> Function() apiCall) async {
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
            logInfo(
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
          logInfo(
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

  /// JSON을 AiCategoryEntity로 매핑
  AiCategoryEntity _mapToAiCategoryEntity(Map<String, dynamic> json) {
    return AiCategoryEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: Icons.pets, // 기본 아이콘 사용
      color: Colors.blue, // 기본 색상 사용
    );
  }

  /// JSON을 AiSuggestedQuestionEntity로 매핑
  AiSuggestedQuestionEntity _mapToAiSuggestedQuestionEntity(
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
