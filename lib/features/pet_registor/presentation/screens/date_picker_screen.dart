import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../widgets/widgets.dart';

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
            DateTabBarWidget(tabController: _tabController),

            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // 연도/월 선택
                  YearMonthSelectorWidget(
                    selectedYear: _selectedYear,
                    selectedMonth: _selectedMonth,
                    onYearChanged: (year) {
                      setState(() {
                        _selectedYear = year;
                      });
                    },
                    onMonthChanged: (month) {
                      setState(() {
                        _selectedMonth = month;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 달력
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: CustomCalendarWidget(
                        selectedYear: _selectedYear,
                        selectedMonth: _selectedMonth,
                        selectedDate: _getCurrentSelectedDate(),
                        onDateSelected: (date) {
                          setState(() {
                            if (_currentTab == 'birthday') {
                              _currentBirthday = date;
                            } else {
                              _currentArrivalDate = date;
                            }
                          });
                        },
                      ),
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
