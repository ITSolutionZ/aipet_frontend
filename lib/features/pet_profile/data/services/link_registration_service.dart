
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

    // Mock 데이터 반환
    return {
      'success': true,
      'message': 'リンクが正常に登録されました',
      'linkId': 'link-${DateTime.now().millisecondsSinceEpoch}',
      'registeredLink': link,
      'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    };
  }

  /// 링크 유효성 검증
  static bool isValidLink(String link) {
    // 기본적인 URL 유효성 검증
    return Uri.tryParse(link) != null &&
           (link.startsWith('http://') || link.startsWith('https://'));
  }
}
