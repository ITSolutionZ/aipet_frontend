import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/scheduling/data/services/feeding_local_storage_service.dart';
import 'package:aipet_frontend/features/scheduling/presentation/widgets/scheduling_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final todayMeals = await FeedingLocalStorageService.getTodayMeals();
    final scheduleItems =
        await FeedingLocalStorageService.getFeedingSchedules();

    setState(() {
      _todayMeals = todayMeals;
      _scheduleItems = scheduleItems;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 포커스될 때마다 데이터 새로고침
    _loadMockData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAddFeedingRecord() {
    context.go(AppRouter.addFeedingRecordRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: '$petNameの食事スケジュール',
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 오늘의 급여 요약
                    if (_todayMeals != null)
                      TodayMealsCard(todayMeals: _todayMeals!),
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
                    // 스케줄 목록
                    if (_scheduleItems != null)
                      ...(_scheduleItems!.map(
                        (item) => ScheduleItemWidget(
                          meal: item['mealType'],
                          time: item['time'],
                          amount: item['amount'],
                        ),
                      )),

                    const SizedBox(height: AppSpacing.lg),

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
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
