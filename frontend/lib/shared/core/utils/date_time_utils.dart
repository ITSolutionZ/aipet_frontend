/// 날짜/시간 관련 공통 유틸리티 함수들
class DateTimeUtils {
  DateTimeUtils._();

  /// 시간을 HH:mm 형식으로 포맷팅
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 날짜를 dd.mm.yyyy 형식으로 포맷팅
  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day.$month.$year';
  }

  /// 날짜와 시간을 dd.mm.yyyy | HH:mm 형식으로 포맷팅
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} | ${formatTime(dateTime)}';
  }

  /// Duration을 시간:분 형식으로 포맷팅 (예: 1h 30m, 45m)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Duration을 --:-- 형식으로 포맷팅 (null 안전)
  static String formatDurationSafe(Duration? duration) {
    if (duration == null) return '--:--';
    return formatDuration(duration);
  }

  /// 거리를 km 단위로 포맷팅 (소수점 1자리)
  static String formatDistance(double? distance) {
    if (distance == null) return '-- km';
    return '${distance.toStringAsFixed(1)} km';
  }

  // ========================================
  // 날짜/시간 포맷팅 확장 메서드 (padLeft 패턴 완전 제거)
  // ========================================

  /// 날짜를 YYYY-MM-DD 형식으로 포맷팅
  static String formatDateKey(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 날짜를 YYYY/MM/DD 형식으로 포맷팅
  static String formatDateSlash(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }

  /// 경과 시간을 HH:MM:SS 형식으로 포맷팅 (타이머용)
  static String formatElapsedTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 경과 시간을 MM:SS 형식으로 포맷팅
  static String formatElapsedShort(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 경과 시간을 HH:SS 형식으로 포맷팅 (분 생략)
  static String formatElapsedHourSecond(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final seconds = totalSeconds % 60;
    return '$hours:${seconds.toString().padLeft(2, '0')}';
  }

  /// Duration을 HH:MM:SS 형식으로 포맷팅 (타이머용)
  static String formatDurationTimer(Duration duration) {
    return formatElapsedTime(duration.inSeconds);
  }

  /// Duration을 MM:SS 형식으로 포맷팅
  static String formatDurationShortTimer(Duration duration) {
    return formatElapsedShort(duration.inSeconds);
  }

  /// 숫자를 2자리 문자열로 포맷팅 (입력 필드용)
  static String formatTwoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  /// 오늘인지 확인
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 내일인지 확인
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  /// 이번 주인지 확인
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 다음 실행 시간 계산 (오늘 시간이 지났으면 내일 같은 시간)
  static DateTime getNextExecutionTime(int hour, int minute) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour, minute);

    if (today.isAfter(now)) {
      return today;
    } else {
      return today.add(const Duration(days: 1));
    }
  }

  /// 현재 시간으로 NotificationTimeOfDay 생성
  static NotificationTimeOfDay now() {
    final now = DateTime.now();
    return NotificationTimeOfDay(hour: now.hour, minute: now.minute);
  }

  /// 시간 문자열을 파싱하여 시간과 분 추출
  static Map<String, int> parseTimeString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return {'hour': hour, 'minute': minute};
  }

  /// 시간 차이를 사용자 친화적인 문자열로 변환
  static String formatTimeDifference(DateTime targetTime) {
    final now = DateTime.now();
    final difference = targetTime.difference(now);

    if (difference.inMinutes <= 0) {
      return '時間です！';
    } else if (difference.inMinutes <= 15) {
      return '${difference.inMinutes}分後';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分後';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '$hours時間$minutes分後';
    } else {
      return '明日 ${formatTime(targetTime)}';
    }
  }
}

/// 알림 시간 클래스 (기존 NotificationTimeOfDay와 호환)
class NotificationTimeOfDay {
  final int hour;
  final int minute;

  const NotificationTimeOfDay({required this.hour, required this.minute});

  /// 현재 시간으로 생성
  factory NotificationTimeOfDay.now() {
    return DateTimeUtils.now();
  }

  /// 문자열로 변환 (HH:mm 형식)
  String toTimeString() {
    return DateTimeUtils.formatTime(DateTime(2024, 1, 1, hour, minute));
  }

  /// DateTime으로 변환 (오늘 날짜 기준)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 다음 실행 시간 계산
  DateTime getNextExecutionTime() {
    return DateTimeUtils.getNextExecutionTime(hour, minute);
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'hour': hour, 'minute': minute};
  }

  /// JSON에서 생성
  factory NotificationTimeOfDay.fromJson(Map<String, dynamic> json) {
    return NotificationTimeOfDay(
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
    );
  }

  @override
  String toString() {
    return toTimeString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTimeOfDay &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
