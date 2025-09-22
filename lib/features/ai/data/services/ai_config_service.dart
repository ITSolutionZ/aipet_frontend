import '../../../../app/app.dart';
import '../../domain/domain.dart';
import 'ai_cache_service.dart';
import 'ai_data_service.dart';

/// 🎯 AI 설정 서비스 (리팩토링됨)
///
/// 기존의 거대한 AiConfigService를 여러 서비스로 분리한 후
/// 이 서비스는 단순히 다른 서비스들을 조합하는 역할만 담당
class AiConfigService {
  static late final AiDataService _dataService;
  static late final AiCacheService _cacheService;

  /// 현재 Mock 모드 여부
  static bool get isMockMode => AppConfig.current.isMockMode;

  /// 서비스 초기화
  static Future<void> initialize() async {
    try {
      _cacheService = AiCacheService();
      _dataService = AiDataService(_cacheService);
      _dataService.logInfo('AiConfigService initialized successfully');
    } catch (e) {
      // ignore: avoid_print
      print('[AI_CONFIG_ERROR] Failed to initialize service: $e');
      rethrow;
    }
  }

  /// AI 카테고리 데이터 가져오기
  static Future<List<AiCategoryEntity>> getCategories() async {
    return _dataService.getCategories();
  }

  /// AI 추천 질문 가져오기
  static Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    return _dataService.getSuggestedQuestions();
  }

  /// AI 응답 템플릿 가져오기
  static Future<Map<String, String>> getResponseTemplates() async {
    return _dataService.getResponseTemplates();
  }

  /// 키워드 매핑 가져오기
  static Future<Map<String, List<String>>> getKeywordMapping() async {
    return _dataService.getKeywordMapping();
  }

  /// 캐시 관리 메서드들
  static void clearCache() {
    _cacheService.clearCache();
  }

  static void clearCacheForKey(String key) {
    _cacheService.clearCacheForKey(key);
  }

  static Map<String, dynamic> getCacheStatus() {
    return _cacheService.getCacheStatus();
  }

  static void cleanupExpiredCache() {
    _cacheService.cleanupExpiredCache();
  }

  /// 서비스 상태 확인
  static Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      return {
        'isMockMode': isMockMode,
        'cacheStatus': _cacheService.getCacheStatus(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _dataService.logError('Failed to get service status', e);
      return {
        'error': e.toString(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    }
  }
}
