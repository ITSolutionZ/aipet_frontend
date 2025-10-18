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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedPetFilter; // 펫 필터

  @override
  void initState() {
    super.initState();
    _controller = WalkController(ref);
    _selectedDay = _focusedDay;
    _loadWalkRecords();
  }

  Future<void> _loadWalkRecords() async {
    await _controller.loadWalkRecords();
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
              }
            },
            itemBuilder: (context) => [
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _getCalendarHeight(),
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
                      eventLoader: (day) =>
                          WalkCalendarDataHelper.getEventsForDay(
                            day,
                            walkRecords,
                          ),
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
                          final isWeekend =
                              day.weekday == DateTime.sunday ||
                              day.weekday == DateTime.saturday;

                          return Center(
                            child: Text(
                              weekdayText,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isWeekend
                                    ? AppColors.pointPink
                                    : AppColors.textPrimary,
                              ),
                            ),
                          );
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
                        weekendTextStyle: const TextStyle(
                          color: AppColors.pointPink,
                        ),
                        outsideDaysVisible: false,
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pointPink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 통계 및 산책 기록 리스트 (데이터 없으면 empty 위젯)
          Expanded(child: _buildStatisticsAndRecords(walkRecords)),
        ],
      ),
    );
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

  /// 통계 및 산책 기록 빌드 (데이터 없으면 empty 위젯)
  Widget _buildStatisticsAndRecords(List<WalkRecordEntity> walkRecords) {
    final selectedDate = _selectedDay ?? DateTime.now();
    debugPrint('📅 캘린더: 선택 날짜=${selectedDate.year}-${selectedDate.month}-${selectedDate.day}, 전체 산책=${walkRecords.length}개');

    var recordsForDay = WalkCalendarDataHelper.getEventsForDay(
      selectedDate,
      walkRecords,
    );
    debugPrint('📅 캘린더: 선택 날짜의 산책 기록=${recordsForDay.length}개');

    // 펫 필터 적용
    recordsForDay = WalkCalendarDataHelper.applyPetFilter(
      recordsForDay,
      _selectedPetFilter,
    );
    debugPrint('📅 캘린더: 필터 후 산책 기록=${recordsForDay.length}개');

    // 데이터가 없으면 empty 위젯 표시
    if (recordsForDay.isEmpty) {
      debugPrint('❌ 캘린더: 선택된 날짜에 산책 기록이 없습니다');
      return WalkCalendarUiHelper.buildEmptyState(selectedDate);
    }

    // 데이터가 있으면 통계 + 리스트 표시
    return Column(
      children: [
        // 통계 요약
        _buildStatisticsSummary(recordsForDay),

        const SizedBox(height: AppSpacing.sm),

        // 산책 기록 리스트
        Expanded(child: _buildWalkRecordsList(recordsForDay, selectedDate)),
      ],
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

  /// 산책 기록 리스트 빌드
  Widget _buildWalkRecordsList(
    List<WalkRecordEntity> recordsForDay,
    DateTime selectedDate,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 날짜 표시
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              isSameDay(selectedDate, DateTime.now())
                  ? '今日の散歩記録 (${recordsForDay.length}件)'
                  : '${selectedDate.month}月${selectedDate.day}日の散歩記録 (${recordsForDay.length}件)',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // 산책 기록 리스트
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: recordsForDay.length,
              itemBuilder: (context, index) {
                final walkRecord = recordsForDay[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: WalkRecordCardWidget(
                    walkRecord: walkRecord,
                    onTap: () => _showWalkDetails(walkRecord),
                  ),
                );
              },
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

        debugPrint('🗑️ WalkCalendar: $deletedCount件の古い記録を削除しました');

        if (mounted) {
          WalkCalendarDialogHelper.showDeleteSuccessSnackBar(
            context,
            deletedCount,
          );
        }
      } else {
        debugPrint('ℹ️ WalkCalendar: 削除する古い記録はありません');

        if (mounted) {
          WalkCalendarDialogHelper.showNoRecordsToDeleteSnackBar(context);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ WalkCalendar: 記録削除エラー - $e');
      debugPrint('StackTrace: $stackTrace');

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

  /// 오늘로 이동
  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  /// 달력 포맷에 따른 높이 계산
  double _getCalendarHeight() {
    return WalkCalendarUiHelper.calculateCalendarHeight(
      context,
      _calendarFormat,
    );
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
