import '../mock_data/features/ai/ai_mock_data.dart';

/// Mock 데이터 호출을 위한 헬퍼 유틸리티
class MockHelper {
  /// API 호출 시뮬레이션
  static Future<void> simulateApiCall() async {
    await AiMockDataService.simulateApiDelay();
  }

  /// Mock 데이터 서비스 클래스
  static AiMockDataService get mockDataService => AiMockDataService();
}
