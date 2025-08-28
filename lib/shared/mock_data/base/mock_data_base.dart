/// Mock Data 기본 설정 및 공통 기능
///
/// 모든 Mock Data 서비스의 기본이 되는 설정과 공통 기능을 제공합니다.
abstract class MockDataBase {
  /// Mock 데이터 사용 플래그
  /// false로 설정하면 실제 API 호출로 전환됩니다.
  static const bool isEnabled = true;

  /// API 지연 시뮬레이션
  static Future<void> simulateApiDelay({int milliseconds = 300}) async {
    if (isEnabled) {
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
  }

  /// 에러 시뮬레이션 (테스트용)
  static Future<void> simulateError({String message = 'Mock Error'}) async {
    if (isEnabled) {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception(message);
    }
  }

  /// 랜덤 ID 생성
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 랜덤 날짜 생성 (최근 N일 내)
  static DateTime generateRandomDate({int daysAgo = 30}) {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch % daysAgo;
    return now.subtract(Duration(days: random));
  }

  /// 랜덤 평점 생성 (1.0 ~ 5.0)
  static double generateRandomRating() {
    final random = DateTime.now().millisecondsSinceEpoch % 50;
    return 1.0 + (random / 10);
  }

  /// 랜덤 리뷰 수 생성
  static int generateRandomReviewCount() {
    final random = DateTime.now().millisecondsSinceEpoch % 500;
    return 10 + random;
  }
}
