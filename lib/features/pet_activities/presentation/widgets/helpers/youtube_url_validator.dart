/// YouTube URL 검증 헬퍼
class YouTubeUrlValidator {
  /// YouTube URL 유효성 검사
  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;

    // YouTube URL 패턴들
    final patterns = [
      RegExp(r'^https?://(www\.)?youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?://youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?://(www\.)?youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?://(www\.)?youtube\.com/v/([a-zA-Z0-9_-]{11})'),
    ];

    return patterns.any((pattern) => pattern.hasMatch(url));
  }

  /// YouTube 비디오 ID 추출
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;

    // 다양한 YouTube URL 패턴에서 비디오 ID 추출
    final patterns = [
      RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'embed/([a-zA-Z0-9_-]{11})'),
      RegExp(r'v/([a-zA-Z0-9_-]{11})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  /// URL 정규화 (표준 YouTube URL로 변환)
  static String normalizeUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) return url;

    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// URL 검증 에러 메시지
  static String getValidationErrorMessage(String url) {
    if (url.isEmpty) {
      return 'URLを入力してください';
    }

    if (!isValidYouTubeUrl(url)) {
      return '有効なYouTube URLを入力してください';
    }

    return '';
  }

  /// URL 미리보기 정보 생성
  static Map<String, String> getUrlPreviewInfo(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) {
      return {'thumbnail': '', 'title': '', 'isValid': 'false'};
    }

    return {
      'thumbnail': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      'title': 'YouTube Video',
      'isValid': 'true',
    };
  }
}
