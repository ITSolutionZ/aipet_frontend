import 'package:aipet_frontend/features/scheduling/data/services/calendar_event_service.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/add_event_bottom_sheet.dart';
import '../widgets/calendar_event_item.dart';

/// 스케줄링 메인 화면
/// 식사, 학습, 급수 카테고리와 알람 설정을 제공합니다.
class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  ConsumerState<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  late ScrollController _scrollController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Mock data for testing - will be replaced with real data from controller
  final Map<DateTime, List<CalendarEventEntity>> _events = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedDay = DateTime.now();
    _loadEventsFromDatabase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final calendarState = ref.watch(calendarControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: '',
        actions: [
          IconButton(
            onPressed: _openAlarmSetup,
            icon: const Icon(Icons.alarm_add, color: Colors.white),
            tooltip: '알람 설정',
          ),
        ],
      ),
      body: Column(
        children: [
          // テーブルカレンダー
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TableCalendar<CalendarEventEntity>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: AppColors.pointRed),
                holidayTextStyle: const TextStyle(color: AppColors.pointRed),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.pointBrown,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.pointGreen,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.pointBrown,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                formatButtonTextStyle: TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 12,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.pointBrown,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.pointBrown,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
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
          const SizedBox(height: 8.0),

          // イベントリスト
          Expanded(
            child: Container(
              color: AppColors.pointOffWhite,
              child: _selectedDay == null
                  ? _buildEmptyState()
                  : _buildEventsList(),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: _openAlarmSetup,
        icon: const Icon(Icons.add, color: Colors.white),
        tooltip: '새 일정 추가',
        style: IconButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  /// 데이터베이스에서 이벤트 로드
  Future<void> _loadEventsFromDatabase() async {
    try {
      final events = await CalendarEventService.instance.getCalendarEvents();
      setState(() {
        _events.clear();
        for (final event in events) {
          final eventDate = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          if (_events.containsKey(eventDate)) {
            _events[eventDate]!.add(event);
          } else {
            _events[eventDate] = [event];
          }
        }
      });
    } catch (e) {
      debugPrint('이벤트 로드 실패: $e');
    }
  }

  /// 특정 날짜의 이벤트 가져오기
  List<CalendarEventEntity> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /// 선택된 날짜가 없을 때 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppColors.pointGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '날짜를 선택해주세요',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: 8),
          Text(
            '캘린더에서 날짜를 선택하면\n해당 날짜의 일정을 확인할 수 있습니다',
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 선택된 날짜의 이벤트 목록 표시
  Widget _buildEventsList() {
    if (_selectedDay == null) return _buildEmptyState();

    final events = _getEventsForDay(_selectedDay!);

    // 시간순으로 정렬 (전일 이벤트는 상단에, 그 외는 시작 시간순)
    final sortedEvents = [...events]
      ..sort((a, b) {
        // 전일 이벤트 우선 정렬
        if (a.isAllDay == true && b.isAllDay != true) return -1;
        if (a.isAllDay != true && b.isAllDay == true) return 1;

        // 둘 다 전일 이벤트이거나 둘 다 일반 이벤트인 경우 시작 시간순 정렬
        return a.startTime.compareTo(b.startTime);
      });

    if (sortedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: AppColors.pointGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '일정이 없습니다',
              style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('M月d日', 'ja_JP').format(_selectedDay!),
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.pointBrown,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showAddEventDialog,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          color: AppColors.pureWhite,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '일정 추가',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pureWhite,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return CalendarEventItem(
          event: event,
          onTap: () => _showEventDetail(event),
          onEdit: () => _showEditEventDialog(event),
          onDelete: () => _showDeleteEventDialog(event),
        );
      },
    );
  }

  /// 새 이벤트 추가 바텀시트 표시
  void _showAddEventDialog() async {
    final selectedDate = _selectedDay ?? DateTime.now();
    final result = await showModalBottomSheet<CalendarEventEntity>(
      context: context,
      isScrollControlled: true, // 100% 높이를 위해 필요
      backgroundColor: Colors.transparent, // 투명 배경으로 설정
      builder: (context) => AddEventBottomSheet(selectedDate: selectedDate),
    );

    // 결과가 CalendarEventEntity인 경우 이벤트 추가
    if (result is CalendarEventEntity) {
      _addEvent(result);
    }
  }

  /// 이벤트 추가
  Future<void> _addEvent(CalendarEventEntity event) async {
    try {
      // SQLite에 저장
      await CalendarEventService.instance.saveCalendarEvent(event);

      setState(() {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );

        if (_events.containsKey(eventDate)) {
          _events[eventDate]!.add(event);
        } else {
          _events[eventDate] = [event];
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${event.title} 일정이 추가되었습니다'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('이벤트 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 저장에 실패했습니다: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }

  /// 이벤트 상세 보기
  void _showEventDetail(CalendarEventEntity event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${event.type.emoji} ${event.type.displayName}'),
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 8),
            Text(
              '시간: ${DateFormat('HH:mm', 'ja_JP').format(event.startTime)} - ${DateFormat('HH:mm', 'ja_JP').format(event.endTime)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 이벤트 편집 바텀시트 표시
  void _showEditEventDialog(CalendarEventEntity event) async {
    final result = await showModalBottomSheet<CalendarEventEntity>(
      context: context,
      isScrollControlled: true, // 100% 높이를 위해 필요
      backgroundColor: Colors.transparent, // 투명 배경으로 설정
      builder: (context) => AddEventBottomSheet(
        selectedDate: event.startTime,
        initialEvent: event,
      ),
    );

    // 결과가 CalendarEventEntity인 경우 이벤트 업데이트
    if (result is CalendarEventEntity) {
      _updateEvent(event, result);
    }
  }

  /// 이벤트 업데이트
  Future<void> _updateEvent(
    CalendarEventEntity oldEvent,
    CalendarEventEntity newEvent,
  ) async {
    try {
      // SQLite에 업데이트
      await CalendarEventService.instance.updateCalendarEvent(newEvent);

      setState(() {
        // 기존 이벤트 제거
        final oldEventDate = DateTime(
          oldEvent.startTime.year,
          oldEvent.startTime.month,
          oldEvent.startTime.day,
        );

        if (_events.containsKey(oldEventDate)) {
          _events[oldEventDate]!.removeWhere((e) => e.id == oldEvent.id);
          if (_events[oldEventDate]!.isEmpty) {
            _events.remove(oldEventDate);
          }
        }

        // 새 이벤트 추가 (날짜가 변경될 수 있으므로)
        final newEventDate = DateTime(
          newEvent.startTime.year,
          newEvent.startTime.month,
          newEvent.startTime.day,
        );

        if (_events.containsKey(newEventDate)) {
          _events[newEventDate]!.add(newEvent);
        } else {
          _events[newEventDate] = [newEvent];
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newEvent.title} 일정이 수정되었습니다'),
            backgroundColor: AppColors.pointBlue,
          ),
        );
      }
    } catch (e) {
      debugPrint('이벤트 업데이트 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 수정에 실패했습니다: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }

  /// 이벤트 삭제 확인 다이얼로그
  void _showDeleteEventDialog(CalendarEventEntity event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('${event.title} 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.pointRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 이벤트 삭제
  Future<void> _deleteEvent(CalendarEventEntity event) async {
    try {
      // SQLite에서 삭제
      await CalendarEventService.instance.deleteCalendarEvent(event.id);

      setState(() {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );

        if (_events.containsKey(eventDate)) {
          _events[eventDate]!.removeWhere((e) => e.id == event.id);
          if (_events[eventDate]!.isEmpty) {
            _events.remove(eventDate);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${event.title} 일정이 삭제되었습니다'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    } catch (e) {
      debugPrint('이벤트 삭제 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 삭제에 실패했습니다: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }

  /// 알람 설정 화면 열기
  void _openAlarmSetup() async {
    final result = await context.push(
      '/scheduling/new-event?date=${_selectedDay?.toIso8601String()}',
    );
    
    // 새 이벤트가 추가되었을 때 이벤트 목록 새로고침
    if (result == true) {
      await _loadEventsFromDatabase();
    }
  }
}
