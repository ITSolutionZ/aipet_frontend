import '../../../../shared/testing/mock_data/features/ai/ai_keywords_mock_data.dart';

/// AI 키워드 데이터 관리 서비스
///
/// 펫 관련 키워드와 제외 키워드를 중앙에서 관리하며, 향후 설정 파일에서 로드할 수 있도록 설계
class AiKeywordService {
  /// 펫 관련 키워드 목록 (일본어)
  static List<String> getPetKeywords() {
    return AiKeywordsMockData.getPetKeywords();
  }

  /// 제외할 키워드 (펫과 무관한 주제) - 일본어
  static List<String> getExcludeKeywords() {
    return AiKeywordsMockData.getExcludeKeywords();
  }

  /// 키워드 검색 (펫 관련 키워드인지 확인)
  static bool isPetRelatedKeyword(String text) {
    return AiKeywordsMockData.isPetRelatedKeyword(text);
  }
}