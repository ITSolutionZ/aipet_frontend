/// AI 기능에서 사용하는 상수들
class AiConstants {
  /// API 에러 메시지
  static const String apiErrorMessage =
      '申し訳ございません。現在サービスに一時的な問題が発生しています。しばらくしてから再度お試しください。\n\nエラー: ';

  /// API 호출 시작 로그 메시지
  static const String apiCallStartMessage = '🔄 API 호출 시작';

  /// API 응답 성공 로그 메시지
  static const String apiResponseSuccessMessage = '✅ API 응답 성공';

  /// API 호출 실패 로그 메시지
  static const String apiCallFailureMessage = '❌ API 호출 실패';

  /// 펫 컨텍스트 로그 메시지
  static const String petContextMessage = '펫 정보: ';

  /// 응답 길이 제한 (로그용)
  static const int maxResponseLengthForLog = 50;
}
