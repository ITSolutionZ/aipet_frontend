/// 조용한 시간 설정
class QuietTimeSettings {
  /// 조용한 시간 활성화
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
  final bool enabled;

  /// 시작 시간 (HH:mm)
  final String startTime;

  /// 종료 시간 (HH:mm)
  final String endTime;

  /// 요일별 설정 (0=일요일, 6=토요일)
  final List<int> days;

  const QuietTimeSettings({
    this.enabled = false,
    this.startTime = '22:00',
    this.endTime = '08:00',
    this.days = const [0, 1, 2, 3, 4, 5, 6], // 모든 요일
  });

  /// JSON에서 QuietTimeSettings 생성
  factory QuietTimeSettings.fromJson(Map<String, dynamic> json) {
    return QuietTimeSettings(
      enabled: json['enabled'] as bool? ?? false,
      startTime: json['startTime'] as String? ?? '22:00',
      endTime: json['endTime'] as String? ?? '08:00',
      days: (json['days'] as List<dynamic>? ?? [0, 1, 2, 3, 4, 5, 6])
          .map((day) => day as int)
          .toList(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
    };
  }

  /// 현재 조용한 시간인지 확인
  bool isCurrentlyQuietTime() {
    if (!enabled) return false;

    final now = DateTime.now();
    final currentDay = now.weekday % 7; // 0=일요일, 6=토요일
    final currentTime =
        DateTimeUtils.formatTime(now);

    // 요일 확인
    if (!days.contains(currentDay)) return false;

    // 시간 확인
    if (startTime.compareTo(endTime) <= 0) {
      // 같은 날 내의 시간 범위 (예: 08:00-22:00)
      return currentTime.compareTo(startTime) >= 0 &&
          currentTime.compareTo(endTime) <= 0;
    } else {
      // 자정을 걸치는 시간 범위 (예: 22:00-08:00)
      return currentTime.compareTo(startTime) >= 0 ||
          currentTime.compareTo(endTime) <= 0;
    }
  }

  @override
  String toString() {
    return 'QuietTimeSettings(isEnabled: $enabled, startTime: $startTime, endTime: $endTime, days: $days)';
  }
}
