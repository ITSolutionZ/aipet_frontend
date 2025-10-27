import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_record_card_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'helpers/calendar/helpers.dart';

/// 산책 기록 달력 화면
class WalkCalendarScreen extends ConsumerStatefulWidget {
  const WalkCalendarScreen({super.key});

  @override
  ConsumerState<WalkCalendarScreen> createState() => _WalkCalendarScreenState();
}

class _WalkCalendarScreenState extends ConsumerState<WalkCalendarScreen> {
  late final WalkController _controller;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month; // 기본: 1개월 표시
  String? _selectedPetFilter; // 펫 필터

  // 스크롤 관련 변수
  late ScrollController _scrollController;
  double _calendarFlex = 2.0; // 캘린더의 flex 값

  @override
  void initState() {
    super.initState();
    _controller = WalkController(ref);
    _selectedDay = _focusedDay;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadWalkRecords();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWalkRecords() async {
    await _controller.loadWalkRecords();
  }

  /// 스크롤 리스너 - 스크롤 위치에 따라 캘린더 크기 조절
  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (maxScrollExtent > 0) {
      // 스크롤 진행률 계산 (0.0 ~ 1.0)
      final scrollProgress = (scrollOffset / maxScrollExtent).clamp(0.0, 1.0);

      // 스크롤에 따라 캘린더 flex 값 조절 (2.0 ~ 0.5)
      final newFlex = 2.0 - (scrollProgress * 1.5);

      if ((_calendarFlex - newFlex).abs() > 0.1) {
        setState(() {
          _calendarFlex = newFlex.clamp(0.5, 2.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walkRecords = ref.watch(walkRecordsProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: GradientAppBar(
        title: null, // タイトルを削除
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clean') {
                _showCleanOldRecordsDialog();
              } else if (value == 'clean_no_route') {
                _showCleanNoRouteRecordsDialog();
              } else if (value == 'clean_in_progress') {
                _showCleanInProgressRecordsDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clean_in_progress',
                child: Row(
                  children: [
                    Icon(Icons.pause_circle, size: 20, color: AppColors.pointBlue),
                    SizedBox(width: 8),
                    Text('進行中記録を削除'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clean_no_route',
                child: Row(
                  children: [
                    Icon(Icons.route, size: 20, color: AppColors.pointRed),
                    SizedBox(width: 8),
                    Text('ルートなし記録を削除'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clean',
                child: Row(
                  children: [
                    Icon(
                      Icons.cleaning_services,
                      size: 20,
                      color: AppColors.pointBrown,
                    ),
                    SizedBox(width: 8),
                    Text('古い記録を削除'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 달력 (포맷에 따라 높이 조절)
          Flexible(
            flex: _calendarFlex.round(),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 커스텀 헤더
                  _buildCustomHeader(),

                  // 달력
                  Expanded(
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      startingDayOfWeek: StartingDayOfWeek.sunday, // 日曜日始まり
                      eventLoader: (day) {
                        final events = WalkCalendarDataHelper.getEventsForDay(
                          day,
                          walkRecords,
                        );
                        // 완료된 산책만 필터링 (스탬프는 완료된 날에만)
                        return events
                            .where((e) => e.status == WalkStatus.completed)
                            .toList();
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      // 헤더 숨기기 (커스텀 헤더 사용)
                      headerVisible: false,
                      daysOfWeekHeight: 30,
                      // 커스텀 마커 빌더
                      calendarBuilders: CalendarBuilders(
                        // 요일을 일본어로 표시
                        dowBuilder: (context, day) {
                          const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
                          final weekdayText = weekdays[day.weekday % 7];

                          // 日曜日は赤色、土曜日は青色
                          Color textColor = AppColors.textPrimary;
                          if (day.weekday == DateTime.sunday) {
                            textColor = AppColors.pointRed;
                          } else if (day.weekday == DateTime.saturday) {
                            textColor = AppColors.pointBlue;
                          }

                          return Center(
                            child: Text(
                              weekdayText,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          );
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
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return null;

                          return Positioned(
                            bottom: 1,
                            child: Image.asset(
                              'assets/icons/walk_logo/finished.png',
                              width: 20,
                              height: 20,
                            ),
                          );
                        },
                      ),
                      // 스타일 설정
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.pointBrown,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: const TextStyle(
                          fontSize: 13, // 날짜 폰트 크기 축소
                        ),
                        weekendTextStyle: const TextStyle(
                          color: AppColors.pointRed, // 日曜日は赤色
                          fontSize: 13, // 날짜 폰트 크기 축소
                        ),
                        todayTextStyle: const TextStyle(
                          fontSize: 13, // 오늘 날짜 폰트 크기 축소
                        ),
                        selectedTextStyle: const TextStyle(
                          fontSize: 13, // 선택된 날짜 폰트 크기 축소
                          color: Colors.white,
                        ),
                        outsideDaysVisible: false,
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pointRed, // 日曜日は赤色
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // 통계 요약만 표시 (탭하면 바텀시트 표시)
          _buildStatisticsSection(walkRecords),
        ],
      ),
    );
  }

  /// 통계 섹션 빌드 (탭하면 바텀시트 표시)
  Widget _buildStatisticsSection(List<WalkRecordEntity> walkRecords) {
    final selectedDate = _selectedDay ?? DateTime.now();
    var recordsForDay = WalkCalendarDataHelper.getEventsForDay(
      selectedDate,
      walkRecords,
    );

    // 펫 필터 적용
    recordsForDay = WalkCalendarDataHelper.applyPetFilter(
      recordsForDay,
      _selectedPetFilter,
    );

    // 데이터가 없으면 empty 위젯 표시
    if (recordsForDay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: WalkCalendarUiHelper.buildEmptyState(selectedDate),
      );
    }

    // 통계만 표시
    return GestureDetector(
      onTap: () => _showWalkRecordsBottomSheet(recordsForDay, selectedDate),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatisticsSummary(recordsForDay),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSameDay(selectedDate, DateTime.now())
                      ? '今日の散歩記録 (${recordsForDay.length}件)'
                      : '${selectedDate.month}月${selectedDate.day}日の散歩記録 (${recordsForDay.length}件)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.keyboard_arrow_up,
                  color: AppColors.pointBrown,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 산책 기록 바텀시트 표시
  void _showWalkRecordsBottomSheet(
    List<WalkRecordEntity> recordsForDay,
    DateTime selectedDate,
  ) {
    // 바텀시트 열릴 때 캘린더를 2주 포맷으로 변경
    if (_calendarFormat != CalendarFormat.twoWeeks) {
      setState(() {
        _calendarFormat = CalendarFormat.twoWeeks;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.lg),
              ),
            ),
            child: Column(
              children: [
                // 드래그 핸들
                Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.pointGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSameDay(selectedDate, DateTime.now())
                            ? '今日の散歩記録 (${recordsForDay.length}件)'
                            : '${selectedDate.month}月${selectedDate.day}日の散歩記録 (${recordsForDay.length}件)',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppColors.pointGray,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 산책 기록 리스트
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: recordsForDay.length,
                    itemBuilder: (context, index) {
                      final walkRecord = recordsForDay[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: WalkRecordCardWidget(
                          walkRecord: walkRecord,
                          onTap: () {
                            Navigator.pop(context);
                            _showWalkDetails(walkRecord);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      // 바텀시트가 닫힐 때 캘린더를 1개월 포맷으로 변경
      if (mounted && _calendarFormat != CalendarFormat.month) {
        setState(() {
          _calendarFormat = CalendarFormat.month;
        });
      }
    });
  }

  /// 커스텀 헤더 빌드
  Widget _buildCustomHeader() {
    return WalkCalendarHeaderHelper.buildCustomHeader(
      focusedDay: _focusedDay,
      onPreviousMonth: () {
        setState(() {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
        });
      },
      onNextMonth: () {
        setState(() {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
        });
      },
      onToday: _goToToday,
      onFormatToggle: () {
        setState(() {
          _calendarFormat = _calendarFormat == CalendarFormat.month
              ? CalendarFormat.twoWeeks
              : _calendarFormat == CalendarFormat.twoWeeks
              ? CalendarFormat.week
              : CalendarFormat.month;
        });
      },
      calendarFormat: _calendarFormat,
    );
  }

  /// 통계 요약 빌드 (선택된 날짜의 기록으로 계산)
  Widget _buildStatisticsSummary(List<WalkRecordEntity> recordsForDay) {
    final totalDistance = WalkCalendarStatsHelper.calculateTotalDistance(
      recordsForDay,
    );
    final totalDuration = WalkCalendarStatsHelper.calculateTotalDuration(
      recordsForDay,
    );

    // 달성률 계산
    final achievementRate = WalkCalendarStatsHelper.calculateAchievementRate(
      recordsForDay: recordsForDay,
      totalDuration: totalDuration,
      ref: ref,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: WalkCalendarUiHelper.buildStatItem(
              '${recordsForDay.length}回',
              Icons.directions_walk,
            ),
          ),
          Expanded(
            child: WalkCalendarUiHelper.buildStatItem(
              '${totalDistance.toStringAsFixed(1)}km',
              Icons.straighten,
            ),
          ),
          Expanded(
            child: WalkCalendarUiHelper.buildStatItem(
              '${totalDuration.inMinutes}分',
              Icons.timer,
            ),
          ),
          Expanded(
            child: WalkCalendarUiHelper.buildStatItem(
              '$achievementRate%',
              Icons.emoji_events,
              color: WalkCalendarUiHelper.getAchievementColor(achievementRate),
            ),
          ),
        ],
      ),
    );
  }

  // /// 이번 달 산책 기록 가져오기 (성능 최적화: 필터링만)
  // List<WalkRecordEntity> _getMonthRecords(List<WalkRecordEntity> walkRecords) {
  //   return walkRecords.where((record) {
  //     return record.startTime.year == _focusedDay.year &&
  //         record.startTime.month == _focusedDay.month;
  //   }).toList();
  // }

  /// 산책 기록 정리 대화상자 표시
  Future<void> _showCleanOldRecordsDialog() async {
    final shouldDelete =
        await WalkCalendarDialogHelper.showCleanOldRecordsDialog(context);

    if (shouldDelete == true) {
      await _cleanOldRecords();
    }
  }

  /// 산책 기록 정리 (6개월 이상 된 기록 삭제)
  Future<void> _cleanOldRecords() async {
    try {
      final walkRecords = ref.read(walkRecordsProvider);
      final recentRecords = WalkCalendarDataHelper.filterRecentRecords(
        walkRecords,
      );

      if (recentRecords.length < walkRecords.length) {
        // 1. 로컬 스토리지에서 삭제
        await LocalWalkStorageService.saveWalkRecords(recentRecords);

        // 2. 상태 업데이트
        ref.read(walkRecordsProvider.notifier).setWalkRecords(recentRecords);

        final deletedCount = WalkCalendarDataHelper.calculateDeletedCount(
          walkRecords,
          recentRecords,
        );

        LoggerService.debug('🗑️ WalkCalendar: $deletedCount件の古い記録を削除しました');

        if (mounted) {
          WalkCalendarDialogHelper.showDeleteSuccessSnackBar(
            context,
            deletedCount,
          );
        }
      } else {
        LoggerService.debug('ℹ️ WalkCalendar: 削除する古い記録はありません');

        if (mounted) {
          WalkCalendarDialogHelper.showNoRecordsToDeleteSnackBar(context);
        }
      }
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkCalendar: 記録削除エラー - $e');
      LoggerService.debug('StackTrace: $stackTrace');

      if (mounted) {
        WalkCalendarDialogHelper.showDeleteErrorSnackBar(context);
      }
    }
  }

  /// 펫 필터 빌드
  // Widget _buildPetFilter() {
  //   final pets = PetMockData.getMockPets();

  //   return Container(
  //     height: 40,
  //     margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       children: [
  //         // 전체 보기 칩
  //         _buildFilterChip(
  //           label: '全て',
  //           isSelected: _selectedPetFilter == null,
  //           onTap: () {
  //             setState(() {
  //               _selectedPetFilter = null;
  //             });
  //           },
  //         ),
  //         const SizedBox(width: 8),
  //         // 펫별 필터 칩
  //         ...pets.map(
  //           (pet) => Padding(
  //             padding: const EdgeInsets.only(right: 8),
  //             child: _buildFilterChip(
  //               label: pet.name,
  //               isSelected: _selectedPetFilter == pet.id,
  //               onTap: () {
  //                 setState(() {
  //                   _selectedPetFilter = pet.id;
  //                 });
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildFilterChip({
  //   required String label,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected ? AppColors.pointBrown : Colors.white,
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: isSelected ? AppColors.pointBrown : Colors.grey.shade300,
  //         ),
  //       ),
  //       child: Text(
  //         label,
  //         style: AppTextStyles.bodySmall.copyWith(
  //           color: isSelected ? Colors.white : AppColors.textPrimary,
  //           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// 진행중인 산책 기록 삭제 다이얼로그 표시
  Future<void> _showCleanInProgressRecordsDialog() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('進行中記録を削除'),
        content: const Text(
          '完了されていない進行中の散歩記録を削除しますか？\n'
          'これらの記録は正常に終了されなかったものです。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.pointRed),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _cleanInProgressRecords();
    }
  }

  /// 진행중인 산책 기록 삭제
  Future<void> _cleanInProgressRecords() async {
    try {
      final walkRecords = ref.read(walkRecordsProvider);

      // 완료된 기록만 필터링
      final completedRecords = walkRecords.where((record) {
        return record.status == WalkStatus.completed;
      }).toList();

      final deletedCount = walkRecords.length - completedRecords.length;

      if (deletedCount > 0) {
        // 1. 로컬 스토리지에 저장
        await LocalWalkStorageService.saveWalkRecords(completedRecords);

        // 2. 현재 산책도 정리
        await LocalWalkStorageService.saveCurrentWalk(null);

        // 3. 상태 업데이트
        ref.read(walkRecordsProvider.notifier).setWalkRecords(completedRecords);
        ref.read(currentWalkProvider.notifier).endWalk(); // 현재 산책 종료

        LoggerService.debug('🗑️ WalkCalendar: 進行中記録 $deletedCount件を削除しました');

        if (mounted) {
          SnackBarService.showSuccess(context, '進行中記録を$deletedCount件削除しました');
        }
      } else {
        LoggerService.debug('ℹ️ WalkCalendar: 削除する進行中記録はありません');

        if (mounted) {
          SnackBarService.showInfo(context, '削除する記録がありません');
        }
      }
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkCalendar: 進行中記録削除エラー - $e');
      LoggerService.debug('StackTrace: $stackTrace');

      if (mounted) {
        SnackBarService.showError(context, '記録の削除に失敗しました');
      }
    }
  }

  /// route가 없는 산책 기록 삭제 다이얼로그 표시
  Future<void> _showCleanNoRouteRecordsDialog() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ルートなし記録を削除'),
        content: const Text(
          'ルート情報がない散歩記録を削除しますか？\n'
          'これらの記録は位置追跡なしで保存されたものです。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.pointRed),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _cleanNoRouteRecords();
    }
  }

  /// route가 없는 산책 기록 삭제
  Future<void> _cleanNoRouteRecords() async {
    try {
      final walkRecords = ref.read(walkRecordsProvider);

      // route가 있는 기록만 필터링
      final recordsWithRoute = walkRecords.where((record) {
        return record.route.isNotEmpty;
      }).toList();

      final deletedCount = walkRecords.length - recordsWithRoute.length;

      if (deletedCount > 0) {
        // 1. 로컬 스토리지에 저장
        await LocalWalkStorageService.saveWalkRecords(recordsWithRoute);

        // 2. 상태 업데이트
        ref.read(walkRecordsProvider.notifier).setWalkRecords(recordsWithRoute);

        LoggerService.debug('🗑️ WalkCalendar: ルートなし記録 $deletedCount件を削除しました');

        if (mounted) {
          SnackBarService.showSuccess(context, 'ルートなし記録を$deletedCount件削除しました');
        }
      } else {
        LoggerService.debug('ℹ️ WalkCalendar: 削除するルートなし記録はありません');

        if (mounted) {
          SnackBarService.showInfo(context, '削除する記録がありません');
        }
      }
    } catch (e, stackTrace) {
      LoggerService.debug('❌ WalkCalendar: ルートなし記録削除エラー - $e');
      LoggerService.debug('StackTrace: $stackTrace');

      if (mounted) {
        SnackBarService.showError(context, '記録の削除に失敗しました');
      }
    }
  }

  /// 오늘로 이동
  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  // /// 선택된 날짜의 산책 기록 리스트 빌드 (사용 안 함 - _buildStatisticsAndRecords로 통합)
  // Widget _buildWalkRecordsForSelectedDay(List<WalkRecordEntity> walkRecords) {
  //   // 선택된 날짜의 기록 표시
  //   final selectedDate = _selectedDay ?? DateTime.now();
  //   var recordsForDay = _getEventsForDay(selectedDate, walkRecords);
  //
  //   // 펫 필터 적용
  //   if (_selectedPetFilter != null) {
  //     recordsForDay = recordsForDay.where((record) {
  //       return record.petId == _selectedPetFilter;
  //     }).toList();
  //   }
  //
  //   if (recordsForDay.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.calendar_today,
  //             size: 64,
  //             color: AppColors.pointGray.withValues(alpha: 0.5),
  //           ),
  //           const SizedBox(height: AppSpacing.md),
  //           Text(
  //             isSameDay(selectedDate, DateTime.now())
  //                 ? '今日の散歩記録がありません'
  //                 : '${selectedDate.month}月${selectedDate.day}日の散歩記録がありません',
  //             style: AppTextStyles.bodyMedium.copyWith(
  //               color: AppColors.textSecondary,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // 선택된 날짜 표시
  //         Padding(
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: AppSpacing.sm,
  //             vertical: AppSpacing.xs,
  //           ),
  //           child: Text(
  //             isSameDay(selectedDate, DateTime.now())
  //                 ? '今日の散歩記録 (${recordsForDay.length}件)'
  //                 : '${selectedDate.month}月${selectedDate.day}日の散歩記録 (${recordsForDay.length}件)',
  //             style: AppTextStyles.bodyMedium.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: AppColors.textPrimary,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: AppSpacing.xs),
  //         // 산책 기록 리스트
  //         Expanded(
  //           child: ListView.builder(
  //             physics: const AlwaysScrollableScrollPhysics(),
  //             itemCount: recordsForDay.length,
  //             itemBuilder: (context, index) {
  //               final walkRecord = recordsForDay[index];
  //               return Padding(
  //                 padding: const EdgeInsets.only(bottom: AppSpacing.sm),
  //                 child: WalkRecordCardWidget(
  //                   walkRecord: walkRecord,
  //                   onTap: () => _showWalkDetails(walkRecord),
  //                   onLongPress: () => _showWalkOptions(walkRecord),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showWalkDetails(WalkRecordEntity walkRecord) {
    context.push('/walk/detail', extra: walkRecord);
  }
}
