import '../../../../app/config/app_config.dart';
import '../../../../shared/mock_data/features/ai/ai_config_mock_data.dart';
import '../../domain/domain.dart';

/// AI 기능 환경별 설정 서비스
///
/// Mock 모드와 실제 API 모드를 구분하여 적절한 데이터 소스를 선택합니다.
class AiConfigService {
  /// 현재 Mock 모드 여부
  static bool get isMockMode => AppConfig.current.isMockMode;

  /// AI 카테고리 데이터 가져오기
  static Future<List<AiCategoryEntity>> getCategories() async {
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      return _getMockCategories();
    } else {
      // 실제 API 모드: API에서 데이터 로드 (향후 구현)
      return _loadCategoriesFromApi();
    }
  }

  /// AI 추천 질문 가져오기
  static Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      return _getMockSuggestedQuestions();
    } else {
      // 실제 API 모드: API에서 데이터 로드 (향후 구현)
      return _loadSuggestedQuestionsFromApi();
    }
  }

  /// AI 응답 템플릿 가져오기
  static Future<Map<String, String>> getResponseTemplates() async {
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      return _getMockResponseTemplates();
    } else {
      // 실제 API 모드: API에서 데이터 로드 (향후 구현)
      return _loadResponseTemplatesFromApi();
    }
  }

  /// 키워드 매핑 가져오기
  static Future<Map<String, List<String>>> getKeywordMapping() async {
    if (isMockMode) {
      // Mock 모드: 정적 데이터 반환
      return _getMockKeywordMapping();
    } else {
      // 실제 API 모드: API에서 데이터 로드 (향후 구현)
      return _loadKeywordMappingFromApi();
    }
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

  // Private methods for API calls (향후 구현)
  static Future<List<AiCategoryEntity>> _loadCategoriesFromApi() async {
    // TODO: 실제 API 호출 구현
    throw UnimplementedError('API 연동 후 구현 예정');
  }

  static Future<List<AiSuggestedQuestionEntity>>
  _loadSuggestedQuestionsFromApi() async {
    // TODO: 실제 API 호출 구현
    throw UnimplementedError('API 연동 후 구현 예정');
  }

  static Future<Map<String, String>> _loadResponseTemplatesFromApi() async {
    // TODO: 실제 API 호출 구현
    throw UnimplementedError('API 연동 후 구현 예정');
  }

  static Future<Map<String, List<String>>> _loadKeywordMappingFromApi() async {
    // TODO: 실제 API 호출 구현
    throw UnimplementedError('API 연동 후 구현 예정');
  }
}
