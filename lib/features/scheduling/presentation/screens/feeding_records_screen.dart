import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/scheduling/presentation/widgets/scheduling_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/scheduling/scheduling_mock_service.dart'
    as SchedulingMock;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 급여 기록 화면
class FeedingRecordsScreen extends ConsumerStatefulWidget {
  const FeedingRecordsScreen({super.key});

  @override
  ConsumerState<FeedingRecordsScreen> createState() =>
      _FeedingRecordsScreenState();
}

class _FeedingRecordsScreenState extends ConsumerState<FeedingRecordsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedingRecords =
        SchedulingMock.SchedulingMockService.getMockFeedingRecordsForRecords();
    final statistics = SchedulingMock
        .SchedulingMockService.getMockFeedingStatisticsForRecords();

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: '食事記録',
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 통계 차트
                    FeedingStatisticsCard(
                      feedingRecords: feedingRecords,
                      statistics: statistics,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 기록 목록
                    Text(
                      '食事記録一覧',
                      style: AppFonts.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 기록 목록
                    ...feedingRecords.map(
                      (record) => FeedingRecordItem(record: record),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRouter.addFeedingRecordRoute);
        },
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
