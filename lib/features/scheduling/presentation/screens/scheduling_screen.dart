import 'dart:async';
import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/scheduling/data/services/calendar_event_service.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks; // 2週間表示

  // ビューモード: true = カテゴリ別, false = 日付別
  bool _isCategoryView = true;

  // 選択されたペットID (null = 全てのペット)
  String? _selectedPetId;

  // Mock data for testing - will be replaced with real data from controller
  final Map<DateTime, List<CalendarEventEntity>> _events = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedDay = DateTime.now();
    unawaited(_loadEventsFromDatabase());
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
      appBar: SoftGradientAppBar(
        title: '',
        actions: [
          // ビュー切り替えボタン
          IconButton(
            onPressed: () {
              setState(() {
                _isCategoryView = !_isCategoryView;
              });
            },
            icon: Icon(
              _isCategoryView ? Icons.calendar_today : Icons.category,
              color: Colors.white,
            ),
            tooltip: _isCategoryView ? '日付別表示' : 'カテゴリ別表示',
          ),
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
              startingDayOfWeek: StartingDayOfWeek.sunday, // 日曜日始まり
              locale: 'ja_JP',
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(
                  color: AppColors.pointRed,
                  fontSize: 13, // 날짜 폰트 크기 축소
                ), // 日曜日は赤色
                holidayTextStyle: const TextStyle(
                  color: AppColors.pointRed,
                  fontSize: 13, // 날짜 폰트 크기 축소
                ),
                defaultTextStyle: const TextStyle(
                  color: AppColors.pointDark,
                  fontSize: 13, // 날짜 폰트 크기 축소
                ),
                todayTextStyle: const TextStyle(
                  fontSize: 13, // 오늘 날짜 폰트 크기 축소
                  color: Colors.white,
                ),
                selectedTextStyle: const TextStyle(
                  fontSize: 13, // 선택된 날짜 폰트 크기 축소
                  color: Colors.white,
                ),
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
              calendarBuilders: CalendarBuilders(
                // 土曜日を青色に設定
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text(
                        DateFormat.E('ja_JP').format(day),
                        style: const TextStyle(color: AppColors.pointBlue),
                      ),
                    );
                  }
                  return null;
                },
                // 土曜日の日付を青色に設定
                defaultBuilder: (context, day, focusedDay) {
                  if (day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: AppColors.pointBlue,
                          fontSize: 13, // 날짜 폰트 크기 축소
                        ),
                      ),
                    );
                  }
                  return null;
                },
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

          // ペットタブ (カテゴリビュー時のみ表示)
          if (_isCategoryView) _buildPetTabs(),

          // イベントリスト
          Expanded(
            child: Container(
              color: AppColors.pointOffWhite,
              child: _isCategoryView
                  ? _buildCategoryView()
                  : (_selectedDay == null
                        ? _buildEmptyState()
                        : _buildEventsList()),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: _openAlarmSetup,
        icon: const Icon(Icons.add, color: Colors.white),
        tooltip: '新しい予定を追加',
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
      LoggerService.debug('📥 イベント読み込み開始...');
      final events = await CalendarEventService.instance.getCalendarEvents();
      LoggerService.debug('📥 読み込まれたイベント数: ${events.length}');

      // ✅ 각 이벤트 상세 로그
      for (final event in events) {
        LoggerService.debug(
          '  - ${event.title}: ${event.startTime.toString().substring(0, 10)}',
        );
      }

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
        LoggerService.debug('📥 イベントキャッシュ更新完了: ${_events.length}日分');
      });
    } catch (e, stackTrace) {
      LoggerService.debug('❌ イベント読み込み失敗: $e');
      LoggerService.debug('❌ スタックトレース: $stackTrace');
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
            '日付を選択してください',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: 8),
          Text(
            'カレンダーで日付を選択すると\nその日の予定を確認できます',
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
              '予定がありません',
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
                  onTap: _openAlarmSetup,
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
                          '予定追加',
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

  /// ペットタブ
  Widget _buildPetTabs() {
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) return const SizedBox.shrink();

        // ペットが1匹の場合はタブを表示しない
        if (pets.length == 1) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 「全て」タブ
                _buildPetTab(
                  label: '全て',
                  petId: null,
                  isSelected: _selectedPetId == null,
                ),
                const SizedBox(width: AppSpacing.md),

                // 各ペットのタブ
                ...pets.asMap().entries.map((entry) {
                  final pet = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _buildPetTab(
                      label: pet.name,
                      petId: pet.id,
                      isSelected: _selectedPetId == pet.id,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// ペットタブボタン (アイコン版)
  Widget _buildPetTab({
    required String label,
    required String? petId,
    required bool isSelected,
  }) {
    // 全てタブかペットタブかを判定
    final isAllTab = petId == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPetId = petId;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isSelected ? 68 : 60,
            height: isSelected ? 68 : 60,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.pointBrown,
                        AppColors.pointBrown.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : AppColors.pointGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.pointBrown
                    : AppColors.pointGray.withValues(alpha: 0.2),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.pointBrown.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Container(
              padding: EdgeInsets.all(isSelected ? 3 : 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.pureWhite : Colors.transparent,
              ),
              child: isAllTab
                  ? Icon(
                      Icons.pets,
                      size: isSelected ? 32 : 28,
                      color: isSelected
                          ? AppColors.pointBrown
                          : AppColors.pointGray,
                    )
                  : ClipOval(
                      child: Container(
                        color: AppColors.pureWhite,
                        child: _buildPetImage(petId, isSelected),
                      ),
                    ),
            ),
          ),
        ),
        if (isSelected) ...[
          const SizedBox(height: 4),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }

  /// ペット画像を表示
  Widget _buildPetImage(String petId, bool isSelected) {
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) {
        final pet = pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => pets.first,
        );

        if (pet.imagePath != null && pet.imagePath!.isNotEmpty) {
          final storageService = ImageStorageService();
          final absolutePath =
              storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;

          return ClipOval(
            child: Image.file(
              File(absolutePath),
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  pet.type == 'dog' ? Icons.pets : Icons.pets_outlined,
                  size: 32,
                  color: isSelected
                      ? AppColors.pointBrown
                      : AppColors.pointGray,
                );
              },
            ),
          );
        } else {
          return Icon(
            pet.type == 'dog' ? Icons.pets : Icons.pets_outlined,
            size: 32,
            color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
          );
        }
      },
      loading: () => Icon(
        Icons.pets,
        size: 32,
        color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
      ),
      error: (_, __) => Icon(
        Icons.pets,
        size: 32,
        color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
      ),
    );
  }

  /// カテゴリ別ビュー
  Widget _buildCategoryView() {
    // すべてのイベントを取得
    final allEvents = <CalendarEventEntity>[];
    for (final eventList in _events.values) {
      allEvents.addAll(eventList);
    }

    // ペットフィルタリング
    final filteredEvents = _selectedPetId == null
        ? allEvents
        : allEvents.where((event) => event.petId == _selectedPetId).toList();

    if (filteredEvents.isEmpty) {
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
              '予定がありません',
              style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
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
                  onTap: _openAlarmSetup,
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
                          '予定追加',
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

    // カテゴリ別にグループ化
    final categoryGroups = <AlarmCategory, List<CalendarEventEntity>>{};
    for (final event in filteredEvents) {
      final category = event.type.alarmCategory;
      if (!categoryGroups.containsKey(category)) {
        categoryGroups[category] = [];
      }
      categoryGroups[category]!.add(event);
    }

    // 各カテゴリ内で時間順にソート
    for (final events in categoryGroups.values) {
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 食事アラーム
        if (categoryGroups.containsKey(AlarmCategory.meal))
          _buildCategorySection(
            '食事アラーム',
            Icons.restaurant,
            categoryGroups[AlarmCategory.meal]!,
          ),

        // 散歩アラーム
        if (categoryGroups.containsKey(AlarmCategory.walk))
          _buildCategorySection(
            '散歩アラーム',
            Icons.pets,
            categoryGroups[AlarmCategory.walk]!,
          ),

        // 予約・システムアラーム
        if (categoryGroups.containsKey(AlarmCategory.system))
          _buildCategorySection(
            '予約・システムアラーム',
            Icons.notifications,
            categoryGroups[AlarmCategory.system]!,
          ),
      ],
    );
  }

  /// カテゴリセクションを構築
  Widget _buildCategorySection(
    String title,
    IconData icon,
    List<CalendarEventEntity> events,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.pointBrown, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${events.length}件',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // イベントリスト
        ...events.map(
          (event) => CalendarEventItem(
            event: event,
            onTap: () => _showEventDetail(event),
            onEdit: () => _showEditEventDialog(event),
            onDelete: () => _showDeleteEventDialog(event),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  /// 新 이벤트 추가 바텀시트 표시
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
        // ✅ Shared SnackBarService 사용
        SnackBarService.showSuccess(context, '${event.title}の予定が追加されました');
      }
    } catch (e) {
      LoggerService.debug('이벤트 저장 실패: $e');
      if (mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, '予定の保存に失敗しました: $e');
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

  /// 이벤트 편집 화면 표시
  void _showEditEventDialog(CalendarEventEntity event) async {
    final result = await context.push<CalendarEventEntity>(
      '/scheduling/new-event',
      extra: event, // 편집モード用にイベントを渡す
    );

    // 결과가 CalendarEventEntity인 경우 이벤트 업데이트
    if (result is CalendarEventEntity && mounted) {
      await _loadEventsFromDatabase();
      // TableCalendar의 마커 업데이트를 강제하기 위해 선택된 날짜 다시 선택
      if (_selectedDay != null) {
        setState(() {
          // 달력 재렌더링
          _focusedDay = _selectedDay!;
        });
      }
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
        // ✅ Shared SnackBarService 사용
        SnackBarService.showInfo(context, '${newEvent.title}の予定が修正されました');
      }
    } catch (e) {
      LoggerService.debug('이벤트 업데이트 실패: $e');
      if (mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, '予定の修正に失敗しました: $e');
      }
    }
  }

  /// 이벤트 삭제 확인 다이얼로그
  void _showDeleteEventDialog(CalendarEventEntity event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予定削除'),
        content: Text('${event.title}の予定を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.pointRed),
            child: const Text('削除'),
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
        // ✅ Shared SnackBarService 사용
        SnackBarService.showWarning(context, '${event.title}の予定が削除されました');
      }
    } catch (e) {
      LoggerService.debug('이벤트 삭제 실패: $e');
      if (mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, '일정 삭제에 실패했습니다: $e');
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
      // TableCalendar의 마커 업데이트를 강제하기 위해 선택된 날짜 다시 선택
      if (_selectedDay != null) {
        setState(() {
          // 달력 재렌더링
          _focusedDay = _selectedDay!;
        });
      }
    }
  }
}
