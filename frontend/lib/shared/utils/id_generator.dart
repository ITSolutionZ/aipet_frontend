import 'dart:math';

/// 🆔 ID 생성 유틸리티
///
/// 고유한 ID를 생성하기 위한 공통 유틸리티입니다.
/// 타임스탬프와 랜덤 값을 조합하여 중복 가능성을 최소화합니다.
class IdGenerator {
  /// 생성자 비활성화 (Utility 클래스)
  const IdGenerator._();

  /// 기본 ID 생성
  ///
  /// [prefix] ID 접두사 (기본값: 'id')
  ///
  /// 예시:
  /// ```dart
  /// final id = IdGenerator.generate(); // 'id_1234567890_1234'
  /// final messageId = IdGenerator.generate(prefix: 'msg'); // 'msg_1234567890_1234'
  /// ```
  static String generate({String prefix = 'id'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${prefix}_${timestamp}_$random';
  }

  /// 메시지 ID 생성
  static String generateMessageId() => generate(prefix: 'msg');

  /// 세션 ID 생성
  static String generateSessionId() => generate(prefix: 'session');

  /// 채팅 히스토리 ID 생성
  static String generateHistoryId() => generate(prefix: 'history');

  /// 분석 ID 생성
  static String generateAnalysisId() => generate(prefix: 'analysis');

  /// 타임스탬프만 반환
  static String generateTimestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// UUID 스타일 ID 생성 (더 복잡한 랜덤)
  static String generateUuid({String prefix = 'uuid'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random1 = Random().nextInt(99999);
    final random2 = Random().nextInt(99999);
    return '${prefix}_${timestamp}_${random1}_$random2';
  }
}
