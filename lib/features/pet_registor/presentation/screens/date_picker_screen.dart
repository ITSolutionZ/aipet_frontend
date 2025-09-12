import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class DatePickerScreen extends StatefulWidget {
  final DateTime? selectedBirthday;
  final DateTime? selectedArrivalDate;
  final String initialTab; // 'birthday' or 'arrival'
  final Function(DateTime, String) onDateSelected;

  const DatePickerScreen({
    super.key,
    this.selectedBirthday,
    this.selectedArrivalDate,
    required this.initialTab,
    required this.onDateSelected,
  });

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _currentBirthday;
  DateTime? _currentArrivalDate;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _currentTab = 'birthday';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'birthday' ? 0 : 1,
    );

    _currentTab = widget.initialTab;
    _currentBirthday = widget.selectedBirthday;
    _currentArrivalDate = widget.selectedArrivalDate;

    // 현재 선택된 날짜에 따라 년도/월 설정
    final currentDate = _getCurrentSelectedDate();
    if (currentDate != null) {
      _selectedYear = currentDate.year;
      _selectedMonth = currentDate.month;
    }

    // 탭 변경 리스너 추가
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTab = _tabController.index == 0 ? 'birthday' : 'arrival';

        // 탭이 변경될 때 해당 탭의 선택된 날짜로 년도/월 업데이트
        final currentDate = _getCurrentSelectedDate();
        if (currentDate != null) {
          _selectedYear = currentDate.year;
          _selectedMonth = currentDate.month;
        }
      });
    }
  }

  DateTime? _getCurrentSelectedDate() {
    return _currentTab == 'birthday' ? _currentBirthday : _currentArrivalDate;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 연도 목록 생성
  List<int> _getYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => currentYear - index);
  }

  /// 월 목록 생성
  List<int> _getMonthList() {
    return List.generate(12, (index) => index + 1);
  }

  /// 해당 월의 일수 가져오기
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 달력 위젯 생성
  Widget _buildCalendar() {
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;

    // 일요일을 0으로 만들기 위해 조정
    final startOffset = weekdayOfFirstDay == 7 ? 0 : weekdayOfFirstDay;

    return Column(
      children: [
        // 요일 헤더
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['月', '火', '水', '木', '金', '土', '日']
                .map(
                  (day) => Text(
                    day,
                    style: AppFonts.bodySmall.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // 달력 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: 42, // 6주 × 7일
          itemBuilder: (context, index) {
            final dayIndex = index - startOffset + 1;

            if (index < startOffset || dayIndex > daysInMonth) {
              // 빈 셀 또는 다른 달의 날짜
              if (index < startOffset) {
                // 이전 달의 날짜 표시
                final prevMonth = _selectedMonth == 1 ? 12 : _selectedMonth - 1;
                final prevYear = _selectedMonth == 1
                    ? _selectedYear - 1
                    : _selectedYear;
                final prevMonthDays = _getDaysInMonth(prevYear, prevMonth);
                final prevDay = prevMonthDays - (startOffset - index - 1);

                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    '$prevDay',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                );
              } else {
                // 다음 달의 날짜 표시
                final nextDay = dayIndex - daysInMonth;
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    '$nextDay',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                );
              }
            }

            final currentDate = _getCurrentSelectedDate();
            final isSelected =
                currentDate != null &&
                currentDate.year == _selectedYear &&
                currentDate.month == _selectedMonth &&
                currentDate.day == dayIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  final newDate = DateTime(
                    _selectedYear,
                    _selectedMonth,
                    dayIndex,
                  );
                  if (_currentTab == 'birthday') {
                    _currentBirthday = newDate;
                  } else {
                    _currentArrivalDate = newDate;
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pointPink.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(color: AppColors.pointBrown, width: 2)
                      : null,
                ),
                child: Text(
                  '$dayIndex',
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pointBrown
                        : AppColors.pointDark,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: SoftGradientAppBar(
        title: 'ぺことの記念日は？',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 프로그레스바
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.pointGray.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 5 / 7, // 5단계 중 5단계
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pointPink,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),

            // 탭바
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.pointBrown,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.pointGray,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cake, size: 14),
                        SizedBox(width: 4),
                        Text('誕生日'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, size: 14),
                        SizedBox(width: 4),
                        Text('家に来た日'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // 연도 선택
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _getYearList()
                            .map(
                              (year) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedYear = year;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _selectedYear == year ? 14 : 10,
                                    vertical: _selectedYear == year ? 8 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedYear == year
                                        ? AppColors.pointBrown
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(_selectedYear == year ? 18 : 14),
                                  ),
                                  child: Text(
                                    '$year',
                                    style: (_selectedYear == year ? AppFonts.bodyLarge : AppFonts.bodyMedium).copyWith(
                                      color: _selectedYear == year
                                          ? Colors.white
                                          : AppColors.pointGray,
                                      fontWeight: _selectedYear == year
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 월 선택
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _getMonthList()
                            .map(
                              (month) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMonth = month;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _selectedMonth == month ? 14 : 10,
                                    vertical: _selectedMonth == month ? 8 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedMonth == month
                                        ? AppColors.pointBrown
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(_selectedMonth == month ? 18 : 14),
                                  ),
                                  child: Text(
                                    '$month月',
                                    style: (_selectedMonth == month ? AppFonts.bodyLarge : AppFonts.bodyMedium).copyWith(
                                      color: _selectedMonth == month
                                          ? Colors.white
                                          : AppColors.pointGray,
                                      fontWeight: _selectedMonth == month
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 달력
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _buildCalendar(),
                    ),
                  ),
                ],
              ),
            ),

            // 선택 버튼
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  top: BorderSide(
                    color: AppColors.pointGray.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 생일과 입양일을 모두 저장
                    if (_currentBirthday != null) {
                      widget.onDateSelected(_currentBirthday!, 'birthday');
                    }
                    if (_currentArrivalDate != null) {
                      widget.onDateSelected(_currentArrivalDate!, 'arrival');
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: AppColors.pureWhite,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.pointBrown.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    '選択',
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
