import 'dart:math';

/// Mock 데이터 호출을 위한 헬퍼 유틸리티
class MockHelper {
  /// API 호출 시뮬레이션 (기본 지연 시간: 500ms)
  static Future<void> simulateApiCall({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// 랜덤 ID 생성
  static String generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(10000).toString().padLeft(4, '0');
  }

  /// 랜덤 날짜 생성 (현재부터 과거 daysBack일 이내)
  static DateTime generateRandomDate({int daysBack = 30}) {
    final random = Random();
    final now = DateTime.now();
    final randomDays = random.nextInt(daysBack);
    return now.subtract(Duration(days: randomDays));
  }

  /// 랜덤 불린 값 생성
  static bool generateRandomBool() {
    return Random().nextBool();
  }

  /// 랜덤 정수 생성 (min ~ max 범위)
  static int generateRandomInt({int min = 0, int max = 100}) {
    return min + Random().nextInt(max - min + 1);
  }

  /// 랜덤 실수 생성 (min ~ max 범위)
  static double generateRandomDouble({double min = 0.0, double max = 100.0}) {
    return min + Random().nextDouble() * (max - min);
  }
}
