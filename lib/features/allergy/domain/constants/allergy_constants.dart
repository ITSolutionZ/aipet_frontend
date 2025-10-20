/// 알레르기 기능 관련 상수
class AllergyConstants {
  // Private constructor to prevent instantiation
  AllergyConstants._();

  // ========== UI 관련 상수 ==========

  /// 제품 리스트 컨테이너 높이
  static const double productListHeight = 350.0;

  /// 제품 이미지 크기
  static const double productImageSize = 60.0;

  /// 카테고리 탭 수
  static const int categoryTabCount = 4;

  /// 메인 탭 수 (발생/미발생)
  static const int mainTabCount = 2;

  // ========== 카테고리 관련 상수 ==========

  /// 프리푸드 카테고리 키워드
  static const List<String> foodCategoryKeywords = [
    'フード',
    'ドッグフード',
    'キャットフード',
    'うさぎフード',
    '鳥フード',
    'ハムスターフード',
  ];

  /// 서플리먼트 카테고리 키워드
  static const List<String> supplementCategoryKeywords = [
    'サプリメント',
    'ドッグサプリメント',
    'キャットサプリメント',
    'うさぎサプリメント',
    '鳥サプリメント',
    'ハムスターサプリメント',
  ];

  /// 스낵 카테고리 키워드
  static const List<String> snackCategoryKeywords = [
    'おやつ',
    'ドッグおやつ',
    'キャットおやつ',
    'うさぎおやつ',
    '鳥おやつ',
    'ハムスターおやつ',
  ];

  /// 생식 카테고리 키워드
  static const List<String> rawFoodCategoryKeywords = [
    '生食',
    'ドッグ生食',
    'キャット生食',
    'うさぎ生食',
    '鳥生食',
    'ハムスター生食',
  ];

  // ========== 카테고리 표시명 ==========

  /// 카테고리 표시명
  static const String foodCategoryLabel = 'フード';
  static const String supplementCategoryLabel = 'サプリメント';
  static const String snackCategoryLabel = 'おやつ';
  static const String rawFoodCategoryLabel = '生食';

  /// 카테고리 약칭
  static const String supplementCategoryShortLabel = 'サプリ';

  // ========== 에러 메시지 (일본어) ==========

  /// 제품 선택 없음 에러
  static const String noProductsSelectedError = '選択された商品がありません';

  /// 알레르기 제품 없음 에러
  static const String noAllergyProductsError = 'アレルギー反応があった商品を最低1つ以上選択してください';

  /// 비알레르기 제품 없음 에러
  static const String noNonAllergyProductsError =
      'アレルギー反応がなかった商品を最低1つ以上選択してください';

  /// 분석 에러 메시지
  static const String analysisErrorMessage = 'アレルギー分析中にエラーが発生しました。もう一度お試しください。';

  // ========== API 관련 상수 ==========

  /// OpenAI API 타임아웃 (초)
  static const int openAiTimeoutSeconds = 30;

  /// OpenAI 모델명
  static const String openAiModel = 'gpt-4o';

  /// OpenAI 온도 설정
  static const double openAiTemperature = 0.7;

  /// OpenAI 최대 토큰
  static const int openAiMaxTokens = 1500;

  // ========== 분석 관련 상수 ==========

  /// 기본 신뢰도
  static const double defaultConfidence = 0.7;

  /// 폴백 신뢰도
  static const double fallbackConfidence = 0.5;

  /// 최소 알레르기 제품 수
  static const int minimumAllergyProducts = 1;

  /// 최소 비알레르기 제품 수
  static const int minimumNonAllergyProducts = 1;

  /// 추천 제품 최대 수
  static const int maxRecommendedProducts = 20;

  /// 추천 대체 성분 최대 수
  static const int maxRecommendedIngredients = 10;
}
