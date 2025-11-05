import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';


import '../../../../../../shared/shared.dart';
/// 달력 UI 헬퍼
class WalkCalendarUiHelper {
  /// 달력 포맷에 따른 높이 계산
  static double calculateCalendarHeight(
    BuildContext context,
    CalendarFormat format,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - 
        MediaQuery.of(context).padding.top - 
        MediaQuery.of(context).padding.bottom - 
        200; // 앱바, 하단 네비게이션, 여백 고려

    switch (format) {
      case CalendarFormat.month:
        return (availableHeight * 0.4).clamp(300.0, 400.0); // 월간: 40%, 최소 300, 최대 400
      case CalendarFormat.twoWeeks:
        return (availableHeight * 0.3).clamp(250.0, 350.0); // 2주: 30%, 최소 250, 최대 350
      case CalendarFormat.week:
        return (availableHeight * 0.2).clamp(200.0, 300.0); // 1주: 20%, 최소 200, 최대 300
    }
  }

  /// 포맷 버튼 텍스트
  static String getFormatButtonText(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return '月';
      case CalendarFormat.twoWeeks:
        return '2週';
      case CalendarFormat.week:
        return '週';
    }
  }

  /// 마커 색상 (산책 개수에 따라)
  static Color getMarkerColor(int count) {
    if (count >= 3) return AppColors.pointPink;
    if (count >= 2) return AppColors.pointBrown;
    return AppColors.pointGreen;
  }

  /// 달성률에 따른 색상
  static Color getAchievementColor(int rate) {
    if (rate >= 100) return AppColors.pointGreen;
    if (rate >= 70) return AppColors.pointBrown;
    return AppColors.pointPink;
  }

  /// 통계 아이템 빌드
  static Widget buildStatItem(String value, IconData icon, {Color? color}) {
    final itemColor = color ?? AppColors.pointBrown;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: itemColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: itemColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  /// Empty 상태 위젯
  static Widget buildEmptyState(DateTime selectedDate) {
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: AppColors.pointGray.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isToday
                ? '今日の散歩記録がありません'
                : '${selectedDate.month}月${selectedDate.day}日の散歩記録がありません',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '散歩を記録してみましょう',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 비교
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
