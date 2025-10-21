import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 데일리 헬스 화면용 날짜 헤더 위젯
///
/// 날짜 정보와 상태(신규/편집)를 표시하는 공통 위젯
class DailyDateHeaderWidget extends StatelessWidget {
  final DateTime date;
  final bool isEditing;
  final String? customTitle;

  const DailyDateHeaderWidget({
    super.key,
    required this.date,
    this.isEditing = false,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customTitle ?? _formatDate(date),
                style: AppFonts.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getWeekdayName(date.weekday),
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '週 : ${_getWeekOfYear(date)}週目',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              isEditing ? '編集' : '新規',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅 (shared 서비스 사용)
  String _formatDate(DateTime date) {
    return DateFormatService.formatDateJapanese(date);
  }

  /// 요일 이름 가져오기 (shared 서비스 사용)
  String _getWeekdayName(int weekday) {
    return DateFormatService.getWeekdayNameJapanese(weekday);
  }

  /// 해당 날짜가 그 해의 몇 번째 주인지 계산
  int _getWeekOfYear(DateTime date) {
    // 해당 연도의 1월 1일
    final firstDayOfYear = DateTime(date.year, 1, 1);

    // 1월 1일부터 현재 날짜까지의 일수
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;

    // 1월 1일의 요일 (월요일=1, 일요일=7)
    final firstDayWeekday = firstDayOfYear.weekday;

    // 첫 주의 일수 계산 (월요일 시작 기준)
    final daysInFirstWeek = 8 - firstDayWeekday;

    // 주차 계산
    if (daysSinceFirstDay < daysInFirstWeek) {
      return 1;
    } else {
      return ((daysSinceFirstDay - daysInFirstWeek) / 7).ceil() + 1;
    }
  }
}
