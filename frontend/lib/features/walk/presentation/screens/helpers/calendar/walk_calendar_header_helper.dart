import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 달력 헤더 헬퍼
class WalkCalendarHeaderHelper {
  /// 커스텀 헤더 빌드
  static Widget buildCustomHeader({
    required DateTime focusedDay,
    required VoidCallback onPreviousMonth,
    required VoidCallback onNextMonth,
    required VoidCallback onToday,
    required VoidCallback onFormatToggle,
    required CalendarFormat calendarFormat,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 이전 달 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: onPreviousMonth,
          ),

          // 날짜 표시 (yyyy年m月)
          Expanded(
            child: Center(
              child: Text(
                '${focusedDay.year}年${focusedDay.month}月',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 다음 달 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: onNextMonth,
          ),

          const SizedBox(width: 8),

          // 오늘로 이동 버튼
          Container(
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton.icon(
              onPressed: onToday,
              icon: const Icon(
                Icons.today,
                size: 18,
                color: AppColors.pointBrown,
              ),
              label: Text(
                '今日',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 포맷 변경 버튼
          Container(
            decoration: BoxDecoration(
              color: AppColors.pointBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: onFormatToggle,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _getFormatText(calendarFormat),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _getFormatText(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return '月';
      case CalendarFormat.twoWeeks:
        return '2週';
      case CalendarFormat.week:
        return '週';
    }
  }
}
