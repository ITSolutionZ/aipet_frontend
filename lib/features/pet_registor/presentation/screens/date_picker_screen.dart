import 'package:aipet_frontend/features/pet_registor/presentation/widgets/pet_registor_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final datePickerProvider =
    StateNotifierProvider.family<
      DatePickerController,
      DatePickerState,
      DatePickerParams
    >((ref, params) => DatePickerController(params));

class DatePickerParams {
  final DateTime? selectedBirthday;
  final DateTime? selectedArrivalDate;
  final String initialTab;
  final Function(DateTime, String) onDateSelected;

  const DatePickerParams({
    this.selectedBirthday,
    this.selectedArrivalDate,
    required this.initialTab,
    required this.onDateSelected,
  });
}

class DatePickerState {
  final TabController? tabController;
  final DateTime? currentBirthday;
  final DateTime? currentArrivalDate;
  final int selectedYear;
  final int selectedMonth;
  final String currentTab;

  const DatePickerState({
    this.tabController,
    this.currentBirthday,
    this.currentArrivalDate,
    required this.selectedYear,
    required this.selectedMonth,
    required this.currentTab,
  });

  DatePickerState copyWith({
    TabController? tabController,
    DateTime? currentBirthday,
    DateTime? currentArrivalDate,
    int? selectedYear,
    int? selectedMonth,
    String? currentTab,
  }) {
    return DatePickerState(
      tabController: tabController ?? this.tabController,
      currentBirthday: currentBirthday ?? this.currentBirthday,
      currentArrivalDate: currentArrivalDate ?? this.currentArrivalDate,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class DatePickerController extends StateNotifier<DatePickerState> {
  final DatePickerParams params;

  DatePickerController(this.params)
    : super(
        DatePickerState(
          selectedYear: DateTime.now().year,
          selectedMonth: DateTime.now().month,
          currentTab: params.initialTab,
        ),
      );

  void initialize(TickerProvider vsync) {
    final tabController = TabController(
      length: 2,
      vsync: vsync,
      initialIndex: params.initialTab == 'birthday' ? 0 : 1,
    );

    final currentDate = getCurrentSelectedDate();
    final year = currentDate?.year ?? DateTime.now().year;
    final month = currentDate?.month ?? DateTime.now().month;

    state = state.copyWith(
      tabController: tabController,
      currentBirthday: params.selectedBirthday,
      currentArrivalDate: params.selectedArrivalDate,
      selectedYear: year,
      selectedMonth: month,
    );

    tabController.addListener(onTabChanged);
  }

  void onTabChanged() {
    final tabController = state.tabController;
    if (tabController != null && !tabController.indexIsChanging) {
      final currentTab = tabController.index == 0 ? 'birthday' : 'arrival';
      final currentDate = getCurrentSelectedDate();

      state = state.copyWith(
        currentTab: currentTab,
        selectedYear: currentDate?.year ?? state.selectedYear,
        selectedMonth: currentDate?.month ?? state.selectedMonth,
      );
    }
  }

  DateTime? getCurrentSelectedDate() {
    return state.currentTab == 'birthday'
        ? state.currentBirthday
        : state.currentArrivalDate;
  }

  void updateYear(int year) {
    state = state.copyWith(selectedYear: year);
  }

  void updateMonth(int month) {
    state = state.copyWith(selectedMonth: month);
  }

  void updateDate(DateTime date) {
    if (state.currentTab == 'birthday') {
      state = state.copyWith(currentBirthday: date);
    } else {
      state = state.copyWith(currentArrivalDate: date);
    }
  }

  @override
  void dispose() {
    state.tabController?.dispose();
    super.dispose();
  }
}

class DatePickerScreen extends ConsumerStatefulWidget {
  final DateTime? selectedBirthday;
  final DateTime? selectedArrivalDate;
  final String initialTab;
  final Function(DateTime, String) onDateSelected;

  const DatePickerScreen({
    super.key,
    this.selectedBirthday,
    this.selectedArrivalDate,
    required this.initialTab,
    required this.onDateSelected,
  });

  @override
  ConsumerState<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends ConsumerState<DatePickerScreen>
    with TickerProviderStateMixin {
  late DatePickerParams params;

  @override
  void initState() {
    super.initState();
    params = DatePickerParams(
      selectedBirthday: widget.selectedBirthday,
      selectedArrivalDate: widget.selectedArrivalDate,
      initialTab: widget.initialTab,
      onDateSelected: widget.onDateSelected,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(datePickerProvider(params).notifier);
      controller.initialize(this);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(datePickerProvider(params).notifier);
    final state = ref.watch(datePickerProvider(params));
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
              padding: const const const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
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
            if (state.tabController != null)
              DateTabBarWidget(tabController: state.tabController!),

            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: Column(
                children: [
                  const const const SizedBox(height: AppSpacing.lg),

                  // 연도/월 선택
                  YearMonthSelectorWidget(
                    selectedYear: state.selectedYear,
                    selectedMonth: state.selectedMonth,
                    onYearChanged: controller.updateYear,
                    onMonthChanged: controller.updateMonth,
                  ),
                  const const const SizedBox(height: AppSpacing.md),

                  // 달력
                  Expanded(
                    child: Container(
                      padding: const const const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: CustomCalendarWidget(
                        selectedYear: state.selectedYear,
                        selectedMonth: state.selectedMonth,
                        selectedDate: controller.getCurrentSelectedDate(),
                        onDateSelected: controller.updateDate,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 선택 버튼
            Container(
              padding: const const const EdgeInsets.all(AppSpacing.lg),
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
                    if (state.currentBirthday != null) {
                      widget.onDateSelected(state.currentBirthday!, 'birthday');
                    }
                    if (state.currentArrivalDate != null) {
                      widget.onDateSelected(
                        state.currentArrivalDate!,
                        'arrival',
                      );
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: AppColors.pureWhite,
                    padding: const const const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
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
