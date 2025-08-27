import '../mock_data/mock_data_service.dart';

/// 링크 등록 서비스
///
/// 펫 프로필 링크를 등록하는 서비스입니다.
class LinkRegistrationService {
  /// 링크 등록
  ///
  /// [link] 등록할 링크
  static Future<Map<String, dynamic>> registerLink(String link) async {
    // 실제로는 API 호출을 통해 링크를 등록합니다
    await Future.delayed(const Duration(seconds: 2)); // API 호출 시뮬레이션

    // MockDataService를 사용하여 목업 데이터 반환
    return MockDataService.getMockLinkRegistrationResult(link);
  }

  /// 링크 유효성 검증
  static bool isValidLink(String link) {
    return MockDataService.isValidLink(link);
  }
}
