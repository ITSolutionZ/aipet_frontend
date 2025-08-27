import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../widgets/widgets.dart';

/// 급여 스케줄 화면
class FeedingScheduleScreen extends ConsumerStatefulWidget {
  final String petId;

  const FeedingScheduleScreen({super.key, required this.petId});

  @override
  ConsumerState<FeedingScheduleScreen> createState() =>
      _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends ConsumerState<FeedingScheduleScreen> {
  String petName = 'Max';
  List<Map<String, dynamic>>? _todayMeals;
  List<Map<String, dynamic>>? _scheduleItems;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _todayMeals = MockDataService.getMockTodayMealsForSchedule();
      _scheduleItems = MockDataService.getMockFeedingSchedulesForSchedule();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 포커스될 때마다 데이터 새로고침
    _loadMockData();
  }

  void _handleAddFeedingRecord() {
    context.go(AppRouter.addFeedingRecordRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '$petNameの食事スケジュール',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 급여 요약
            if (_todayMeals != null) TodayMealsCard(todayMeals: _todayMeals!),
            const SizedBox(height: AppSpacing.lg),

            // 스케줄 설정
            Text(
              'スケジュール設定',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _scheduleItems != null
                  ? ListView.builder(
                      itemCount: _scheduleItems!.length,
                      itemBuilder: (context, index) {
                        final item = _scheduleItems![index];
                        return ScheduleItemWidget(
                          meal: item['mealType'],
                          time: item['time'],
                          amount: item['amount'],
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            // 급여 기록 추가 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleAddFeedingRecord,
                icon: const Icon(Icons.add),
                label: const Text('食事記録を追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
