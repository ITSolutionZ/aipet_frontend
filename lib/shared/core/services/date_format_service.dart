/// 날짜 형식화 서비스
class DateFormatService {
  /// 상대적 시간 형식화 (UI 전용 로직)
  static String formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  /// 시간 형식화 (HH:MM)
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 형식화 (YYYY/MM/DD)
  static String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜와 시간 형식화 (YYYY/MM/DD HH:MM)
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// 일본어 날짜 형식화 (YYYY年MM月DD日)
  static String formatDateJapanese(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 일본어 요일 이름 가져오기
  static String getWeekdayNameJapanese(int weekday) {
    const weekdays = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    return weekdays[weekday - 1];
  }
}
