import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 시설 예약 캘린더 화면
class FacilityCalendarScreen extends StatefulWidget {
  const FacilityCalendarScreen({super.key});

  @override
  State<FacilityCalendarScreen> createState() => _FacilityCalendarScreenState();
}

class _FacilityCalendarScreenState extends State<FacilityCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'カレンダー',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar<Map<String, dynamic>>(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                calendarStyle: const CalendarStyle(
                  // 오늘 날짜 스타일
                  todayDecoration: BoxDecoration(
                    color: AppColors.pointBlue,
                    shape: BoxShape.circle,
                  ),
                  // 선택된 날짜 스타일
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  // 주말 스타일
                  weekendTextStyle: TextStyle(color: AppColors.pointRed),
                  // 기본 텍스트 스타일
                  defaultTextStyle: TextStyle(color: AppColors.textPrimary),
                  // 외부 날짜 스타일
                  outsideDaysVisible: false,
                  // 마커 스타일
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: AppColors.pointGreen,
                    shape: BoxShape.circle,
                  ),
                  // 셀 패딩
                  cellPadding: EdgeInsets.all(4),
                ),
                headerStyle: const HeaderStyle(
                  // 헤더 포맷
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  // 좌우 화살표 스타일
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: AppColors.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                  // 제목 스타일
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 선택된 날짜 정보
            if (_selectedDay != null) _buildSelectedDayInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    final events = _getEventsForDay(_selectedDay!);
    final dateStr =
        '${_selectedDay!.year}年${_selectedDay!.month}月${_selectedDay!.day}日';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateStr,
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (events.isNotEmpty)
            Column(
              children: events.map((event) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.pointGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        color: AppColors.pointGreen,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          event['title'] ?? '予約',
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        event['time'] ?? '',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Text(
              '予約がありません',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // 실제 예약 데이터는 reservationsNotifierProvider에서 가져옵니다
    // 예시 데이터 (개발 중)
    if (day.day == DateTime.now().day && day.month == DateTime.now().month) {
      return [
        {'title': '定期健康診断', 'time': '10:00'},
        {'title': 'ワクチン接種', 'time': '14:30'},
      ];
    } else if (day.day == DateTime.now().day + 1 &&
        day.month == DateTime.now().month) {
      return [
        {'title': '爪切り', 'time': '11:00'},
      ];
    }
    return [];
  }
}
