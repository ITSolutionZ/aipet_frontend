import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_record_card_widget.dart';
import 'package:aipet_frontend/shared/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart' hide WalkRecordCardWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

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
    final walkRecords = ref.watch(walkRecordsNotifierProvider);

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
                      eventLoader: (day) => _getEventsForDay(day, walkRecords),
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
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getMarkerColor(events.length),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${events.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 이전 달 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                  1,
                );
              });
            },
          ),

          // 날짜 표시 (yyyy年m月)
          Expanded(
            child: Center(
              child: Text(
                '${_focusedDay.year}年${_focusedDay.month}月',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 다음 달 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                  1,
                );
              });
            },
          ),

          const SizedBox(width: 8),

          // 오늘로 이동 버튼
          Container(
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton.icon(
              onPressed: _goToToday,
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
              onPressed: () {
                setState(() {
                  _calendarFormat = _calendarFormat == CalendarFormat.month
                      ? CalendarFormat.twoWeeks
                      : _calendarFormat == CalendarFormat.twoWeeks
                      ? CalendarFormat.week
                      : CalendarFormat.month;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _getFormatButtonText(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 포맷 버튼 텍스트
  String _getFormatButtonText() {
    switch (_calendarFormat) {
      case CalendarFormat.month:
        return '月';
      case CalendarFormat.twoWeeks:
        return '2週';
      case CalendarFormat.week:
        return '週';
    }
  }

  /// 마커 색상 (산책 개수에 따라)
  Color _getMarkerColor(int count) {
    if (count >= 3) return AppColors.pointPink;
    if (count >= 2) return AppColors.pointBrown;
    return AppColors.pointGreen;
  }

  /// 통계 및 산책 기록 빌드 (데이터 없으면 empty 위젯)
  Widget _buildStatisticsAndRecords(List<WalkRecordEntity> walkRecords) {
    final selectedDate = _selectedDay ?? DateTime.now();
    var recordsForDay = _getEventsForDay(selectedDate, walkRecords);

    // 펫 필터 적용
    if (_selectedPetFilter != null) {
      recordsForDay = recordsForDay.where((record) {
        return record.petId == _selectedPetFilter;
      }).toList();
    }

    // 데이터가 없으면 empty 위젯 표시
    if (recordsForDay.isEmpty) {
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
              isSameDay(selectedDate, DateTime.now())
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
    final totalDistance = recordsForDay.fold<double>(
      0,
      (sum, record) => sum + (record.distance ?? 0),
    );
    final totalDuration = recordsForDay.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + record.calculatedDuration,
    );

    // 달성률 계산: 펫의 1일 권장 시간 기준
    final achievementRate = _calculateAchievementRate(
      recordsForDay,
      totalDuration,
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
            child: _buildStatItem(
              '${recordsForDay.length}回',
              Icons.directions_walk,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '${totalDistance.toStringAsFixed(1)}km',
              Icons.straighten,
            ),
          ),
          Expanded(
            child: _buildStatItem('${totalDuration.inMinutes}分', Icons.timer),
          ),
          Expanded(
            child: _buildStatItem(
              '$achievementRate%',
              Icons.emoji_events,
              color: _getAchievementColor(achievementRate),
            ),
          ),
        ],
      ),
    );
  }

  /// 달성률 계산
  int _calculateAchievementRate(
    List<WalkRecordEntity> recordsForDay,
    Duration totalDuration,
  ) {
    if (recordsForDay.isEmpty) return 0;

    // 펫의 1일 권장 시간 가져오기
    final pets = PetMockData.getMockPets();
    final petId = recordsForDay.first.petId;
    final pet = pets.firstWhere((p) => p.id == petId, orElse: () => pets.first);

    final recommendedMinutes = pet.recommendedWalkTime;
    if (recommendedMinutes <= 0) return 0;

    final actualMinutes = totalDuration.inMinutes;
    final rate = (actualMinutes / recommendedMinutes * 100).round();

    // 최대 200%까지만 표시
    return rate > 200 ? 200 : rate;
  }

  /// 달성률에 따른 색상
  Color _getAchievementColor(int rate) {
    if (rate >= 100) return AppColors.pointGreen;
    if (rate >= 70) return AppColors.pointBrown;
    return AppColors.pointPink;
  }

  Widget _buildStatItem(String value, IconData icon, {Color? color}) {
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
                    onLongPress: () => _showWalkOptions(walkRecord),
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
  void _showCleanOldRecordsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('古い記録を削除'),
        content: const Text('6ヶ月以上前の散歩記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cleanOldRecords();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// 산책 기록 정리 (6개월 이상 된 기록 삭제)
  Future<void> _cleanOldRecords() async {
    try {
      final walkRecords = ref.read(walkRecordsNotifierProvider);
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

      final recentRecords = walkRecords.where((record) {
        return record.startTime.isAfter(sixMonthsAgo);
      }).toList();

      if (recentRecords.length < walkRecords.length) {
        // 1. 로컬 스토리지에서 삭제
        await LocalWalkStorageService.saveWalkRecords(recentRecords);

        // 2. 상태 업데이트
        ref
            .read(walkRecordsNotifierProvider.notifier)
            .setWalkRecords(recentRecords);

        final deletedCount = walkRecords.length - recentRecords.length;

        debugPrint('🗑️ WalkCalendar: $deletedCount件の古い記録を削除しました');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('古い散歩記録を$deletedCount件削除しました'),
              backgroundColor: AppColors.pointGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('ℹ️ WalkCalendar: 削除する古い記録はありません');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('削除する古い記録はありません'),
              backgroundColor: AppColors.pointBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ WalkCalendar: 記録削除エラー - $e');
      debugPrint('StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('削除中にエラーが発生しました'),
            backgroundColor: AppColors.pointPink,
            duration: Duration(seconds: 3),
          ),
        );
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
    final screenHeight = MediaQuery.of(context).size.height;

    switch (_calendarFormat) {
      case CalendarFormat.month:
        return screenHeight * 0.45; // 월간: 45%
      case CalendarFormat.twoWeeks:
        return screenHeight * 0.35; // 2주: 35%
      case CalendarFormat.week:
        return screenHeight * 0.25; // 1주: 25%
    }
  }

  /// 특정 날짜의 산책 기록 가져오기 (최신순 정렬)
  List<WalkRecordEntity> _getEventsForDay(
    DateTime day,
    List<WalkRecordEntity> walkRecords,
  ) {
    final records = walkRecords.where((record) {
      return isSameDay(record.startTime, day);
    }).toList();

    // 최신순 정렬
    records.sort((a, b) => b.startTime.compareTo(a.startTime));

    return records;
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

  void _showWalkOptions(WalkRecordEntity walkRecord) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 수정 기능 구현
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('共有'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 공유 기능 구현
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.pointPink),
              title: const Text(
                '削除',
                style: TextStyle(color: AppColors.pointPink),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _controller.deleteWalkRecord(walkRecord.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
