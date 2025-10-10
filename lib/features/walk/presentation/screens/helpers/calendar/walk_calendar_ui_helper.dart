import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 달력 UI 헬퍼
class WalkCalendarUiHelper {
  /// 달력 포맷에 따른 높이 계산
  static double calculateCalendarHeight(
    BuildContext context,
    CalendarFormat format,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    switch (format) {
      case CalendarFormat.month:
        return screenHeight * 0.45; // 월간: 45%
      case CalendarFormat.twoWeeks:
        return screenHeight * 0.35; // 2주: 35%
      case CalendarFormat.week:
        return screenHeight * 0.25; // 1주: 25%
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
