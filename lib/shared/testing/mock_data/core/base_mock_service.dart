/// 기본 Mock 서비스 인터페이스
///
/// 모든 feature별 mock 서비스가 구현해야 할 기본 인터페이스
abstract class BaseMockService {
  /// Mock 데이터 로딩 지연 시간 시뮬레이션
  static const Duration defaultDelay = Duration(milliseconds: 300);

  /// API 지연 시뮬레이션
  ///
  /// [seconds] 지연 시간 (기본값: 0.3초)
  static Future<void> simulateApiDelay({int milliseconds = 300}) async {
    await Future.delayed(const Duration(milliseconds: milliseconds));
  }

  /// 랜덤 성공/실패 시뮬레이션
  ///
  /// [successRate] 성공률 (0.0 ~ 1.0, 기본값: 0.9)
  static bool simulateSuccess({double successRate = 0.9}) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return (random / 100.0) < successRate;
  }

  /// Mock API 에러 시뮬레이션
  static Exception simulateApiError([String? message]) {
    return Exception(message ?? 'Mock API Error - Network connection failed');
  }
}

/// Mock 데이터 헬퍼 클래스
class MockHelper {
  /// 표준 API 지연 시뮬레이션
  static Future<void> simulateApiCall() async {
    await BaseMockService.simulateApiDelay();
  }

  /// 긴 API 호출 시뮬레이션
  static Future<void> simulateLongApiCall() async {
    await BaseMockService.simulateApiDelay(milliseconds: 1000);
  }

  /// ID 생성
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_${timestamp}_${timestamp % 9999}';
  }

  /// 현재 시간 문자열 생성
  static String getCurrentTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
