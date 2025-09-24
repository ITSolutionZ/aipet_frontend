import 'dart:math';

import 'package:aipet_frontend/shared/testing/mock_data/features/ai/ai_mock_data.dart';

/// Mock 데이터 호출을 위한 헬퍼 유틸리티
class MockHelper {
  /// API 호출 시뮬레이션
  static Future<void> simulateApiCall() async {
    await AiMockDataService.simulateApiDelay();
  }

  /// Mock 데이터 서비스 클래스
  static AiMockDataService get mockDataService => AiMockDataService();

  /// 랜덤 ID 생성
  static String generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(10000).toString().padLeft(4, '0');
  }
}
