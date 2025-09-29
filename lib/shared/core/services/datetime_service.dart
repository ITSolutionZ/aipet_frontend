import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

/// 날짜/시간 관련 유틸리티 서비스
///
/// 앱 전체에서 일관된 날짜/시간 포맷팅을 제공하며,
/// 10+개의 중복된 날짜 포맷팅 함수를 통합합니다.
/// 기존 DateTimeUtils를 확장하여 추가 기능을 제공합니다.
class DateTimeService {
  DateTimeService._();

  // 한국어 요일 배열
  static const List<String> _weekdaysKorean = [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일',
  ];

  // 한국어 월 배열
  static const List<String> _monthsKorean = [
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월',
  ];

  /// 상대적 시간 표시 (예: "방금 전", "3분 전", "2시간 전")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    }
  }

  /// 한국어 날짜 포맷 (yyyy년 MM월 dd일)
  static String formatKoreanDate(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month;
    final day = dateTime.day;
    return '$year년 $month월 $day일';
  }

  /// 한국어 월일 포맷 (MM월 dd일)
  static String formatKoreanMonthDay(DateTime dateTime) {
    final month = dateTime.month;
    final day = dateTime.day;
    return '$month월 $day일';
  }

  /// 한국어 요일 포맷 (월요일, 화요일 등)
  static String formatKoreanWeekday(DateTime dateTime) {
    return _weekdaysKorean[dateTime.weekday - 1];
  }

  /// 스케줄용 시간 포맷 (오전/오후 표시)
  static String formatScheduleTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (hour == 0) {
      return '오전 12:$minute';
    } else if (hour < 12) {
      return '오전 $hour:$minute';
    } else if (hour == 12) {
      return '오후 12:$minute';
    } else {
      return '오후 ${hour - 12}:$minute';
    }
  }

  /// 피드 기록용 시간 포맷 (MM/dd HH:mm)
  static String formatFeedTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  /// 나이 계산 (생년월일로부터)
  static String calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);

    if (difference.inDays < 30) {
      return '${difference.inDays}일';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();

      if (remainingMonths == 0) {
        return '$years살';
      } else {
        return '$years살 $remainingMonths개월';
      }
    }
  }

  /// D-Day 계산 (목표 날짜까지 남은 일수)
  static String calculateDDay(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'D-Day';
    } else if (difference > 0) {
      return 'D-$difference';
    } else {
      return 'D+${difference.abs()}';
    }
  }

  /// 일정 표시용 날짜 포맷 (오늘/내일/날짜)
  static String formatScheduleDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '내일';
    } else if (difference == -1) {
      return '어제';
    } else if (difference > 1 && difference <= 7) {
      return formatKoreanWeekday(dateTime);
    } else {
      return formatKoreanMonthDay(dateTime);
    }
  }

  /// 백신 접종 기록용 날짜 포맷
  static String formatVaccineDate(DateTime dateTime) {
    return '${formatKoreanDate(dateTime)} (${formatKoreanWeekday(dateTime)})';
  }

  /// 운동 기록용 시간 포맷 (시간:분:초)
  static String formatExerciseDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 $seconds초';
    } else if (minutes > 0) {
      return '$minutes분 $seconds초';
    } else {
      return '$seconds초';
    }
  }

  /// 간단한 기간 표시 (예: "30분", "2시간", "3일")
  static String formatSimpleDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '${duration.inSeconds}초';
    }
  }

  /// 날짜 범위 포맷 (시작일 ~ 종료일)
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    final start = formatKoreanDate(startDate);
    final end = formatKoreanDate(endDate);

    // 같은 날인 경우
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return start;
    }

    // 같은 달인 경우
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      final startDay = '${startDate.day}일';
      final endDay = '${endDate.day}일';
      return '${startDate.year}년 ${startDate.month}월 $startDay ~ $endDay';
    }

    return '$start ~ $end';
  }

  /// 시간대별 인사말 (아침, 오후, 저녁)
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return '새벽';
    } else if (hour < 12) {
      return '아침';
    } else if (hour < 18) {
      return '오후';
    } else {
      return '저녁';
    }
  }

  /// 이번 달인지 확인
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// 날짜 문자열 파싱 (다양한 형식 지원)
  static DateTime? parseDate(String dateString) {
    try {
      // ISO 형식 (yyyy-MM-dd)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        return DateTime.parse(dateString);
      }

      // 슬래시 형식 (yyyy/MM/dd)
      if (RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(dateString)) {
        final parts = dateString.split('/');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }

      // 점 형식 (dd.MM.yyyy) - 기존 formatDate와 호환
      if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(dateString)) {
        final parts = dateString.split('.');
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }

      return null;
    } catch (e) {
      debugPrint('날짜 파싱 실패: $dateString, 에러: $e');
      return null;
    }
  }

  /// 현재 시간 (getter)
  static DateTime get now => DateTime.now();

  /// 오늘 날짜 (시간 제외)
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 어제 날짜
  static DateTime get yesterday => today.subtract(Duration(days: 1));

  /// 내일 날짜
  static DateTime get tomorrow => today.add(Duration(days: 1));

  /// 이번 주 시작일 (월요일)
  static DateTime get thisWeekStart {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  /// 이번 주 종료일 (일요일)
  static DateTime get thisWeekEnd {
    return thisWeekStart.add(Duration(days: 6));
  }

  /// 이번 달 시작일
  static DateTime get thisMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// 이번 달 종료일
  static DateTime get thisMonthEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  /// 개발자용 디버그 포맷 (상세한 시간 정보)
  static String formatDebug(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}'
        '.${dateTime.millisecond.toString().padLeft(3, '0')}';
  }

  // 기존 DateTimeUtils 메서드들을 재사용하기 위한 delegation

  /// 시간을 HH:mm 형식으로 포맷팅 (기존 DateTimeUtils 사용)
  static String formatTime(DateTime dateTime) =>
      DateTimeUtils.formatTime(dateTime);

  /// 날짜를 dd.mm.yyyy 형식으로 포맷팅 (기존 DateTimeUtils 사용)
  static String formatDate(DateTime dateTime) =>
      DateTimeUtils.formatDate(dateTime);

  /// 날짜와 시간을 dd.mm.yyyy | HH:mm 형식으로 포맷팅 (기존 DateTimeUtils 사용)
  static String formatDateTime(DateTime dateTime) =>
      DateTimeUtils.formatDateTime(dateTime);

  /// Duration을 시간:분 형식으로 포맷팅 (기존 DateTimeUtils 사용)
  static String formatDuration(Duration duration) =>
      DateTimeUtils.formatDuration(duration);

  /// Duration을 --:-- 형식으로 포맷팅 (기존 DateTimeUtils 사용)
  static String formatDurationSafe(Duration? duration) =>
      DateTimeUtils.formatDurationSafe(duration);

  /// 거리를 km 단위로 포맷팅 (기존 DateTimeUtils 사용)
  static String formatDistance(double? distance) =>
      DateTimeUtils.formatDistance(distance);

  /// 오늘인지 확인 (기존 DateTimeUtils 사용)
  static bool isToday(DateTime dateTime) => DateTimeUtils.isToday(dateTime);

  /// 내일인지 확인 (기존 DateTimeUtils 사용)
  static bool isTomorrow(DateTime dateTime) =>
      DateTimeUtils.isTomorrow(dateTime);

  /// 이번 주인지 확인 (기존 DateTimeUtils 사용)
  static bool isThisWeek(DateTime dateTime) =>
      DateTimeUtils.isThisWeek(dateTime);
}
