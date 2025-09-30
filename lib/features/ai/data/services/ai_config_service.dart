import '../../../../app/app.dart';
import '../../domain/domain.dart';
import 'ai_cache_service.dart';
import 'ai_data_service.dart';
import 'ai_dio_service.dart';

/// 🎯 AI 설정 서비스 (의존성 주입 패턴으로 리팩토링됨)
///
/// 기존의 static 패턴을 의존성 주입 패턴으로 변경하여
/// 테스트 가능하고 유연한 구조로 개선했습니다.
class AiConfigService {
  final AiDataService _dataService;
  final AiCacheService _cacheService;

  /// 생성자 - 의존성 주입
  const AiConfigService({required AiDataService dataService, required AiCacheService cacheService})
    : _dataService = dataService,
      _cacheService = cacheService;

  /// 팩토리 생성자 - 기본 설정으로 인스턴스 생성
  factory AiConfigService.createDefault() {
    final dioService = AiDioService.instance;
    final cacheService = AiCacheService();
    final dataService = AiDataService(cacheService, dioService);

    return AiConfigService(dataService: dataService, cacheService: cacheService);
  }

  /// 현재 Mock 모드 여부
  bool get isMockMode => AppConfig.current.isMockMode;

  /// AI 카테고리 데이터 가져오기
  Future<List<AiCategoryEntity>> getCategories() async {
    try {
      return await _dataService.getCategories();
    } catch (e) {
      throw AiConfigException(AiErrorKeys.configError, configKey: 'categories', originalError: e);
    }
  }

  /// AI 추천 질문 가져오기
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    try {
      return await _dataService.getSuggestedQuestions();
    } catch (e) {
      throw AiConfigException(
        AiErrorKeys.configError,
        configKey: 'suggested_questions',
        originalError: e,
      );
    }
  }

  /// AI 응답 템플릿 가져오기
  Future<Map<String, String>> getResponseTemplates() async {
    try {
      return await _dataService.getResponseTemplates();
    } catch (e) {
      throw AiConfigException(
        AiErrorKeys.configError,
        configKey: 'response_templates',
        originalError: e,
      );
    }
  }

  /// 키워드 매핑 가져오기
  Future<Map<String, List<String>>> getKeywordMapping() async {
    try {
      return await _dataService.getKeywordMapping();
    } catch (e) {
      throw AiConfigException(
        AiErrorKeys.configError,
        configKey: 'keyword_mapping',
        originalError: e,
      );
    }
  }

  /// 캐시 관리 메서드들
  void clearCache() {
    _cacheService.clearCache();
  }

  void clearCacheForKey(String key) {
    _cacheService.clearCacheForKey(key);
  }

  Map<String, dynamic> getCacheStatus() {
    return _cacheService.getCacheStatus();
  }

  void cleanupExpiredCache() {
    _cacheService.cleanupExpiredCache();
  }

  /// 서비스 상태 확인
  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      return {
        'isMockMode': isMockMode,
        'cacheStatus': _cacheService.getCacheStatus(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw AiConfigException('Failed to get service status', originalError: e);
    }
  }
}
