import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../app/config/app_config.dart';
import '../../../../shared/services/base_logging_service.dart';
import '../../../../shared/testing/mock_data/features/ai/ai_config_mock_data.dart';
import '../../domain/domain.dart';
import 'ai_cache_service.dart';
import 'ai_dio_service.dart';

/// 🎯 AI 데이터 서비스
///
/// AI 관련 데이터의 로딩과 관리를 담당
class AiDataService extends BaseLoggingService {
  final AiCacheService _cacheService;
  final AiDioService _dioService;

  AiDataService(this._cacheService, this._dioService) : super('ai_data');

  /// Dio 인스턴스 가져오기
  Dio get _dio => _dioService.createApiDio();

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
    return _dioService.executeWithRetry(apiCall);
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
