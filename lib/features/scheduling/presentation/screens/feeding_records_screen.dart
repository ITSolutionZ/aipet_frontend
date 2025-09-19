import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/mock_data/features/scheduling/scheduling_mock_service.dart'
    as SchedulingMock;
import '../../../../shared/shared.dart';
import '../widgets/widgets.dart';

/// 급여 기록 화면
class FeedingRecordsScreen extends ConsumerStatefulWidget {
  const FeedingRecordsScreen({super.key});

  @override
  ConsumerState<FeedingRecordsScreen> createState() =>
      _FeedingRecordsScreenState();
}

class _FeedingRecordsScreenState extends ConsumerState<FeedingRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    final feedingRecords =
        SchedulingMock.SchedulingMockService.getMockFeedingRecordsForRecords();
    final statistics = SchedulingMock
        .SchedulingMockService.getMockFeedingStatisticsForRecords();

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '食事記録'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
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

            Expanded(
              child: ListView.builder(
                itemCount: feedingRecords.length,
                itemBuilder: (context, index) {
                  final record = feedingRecords[index];
                  return FeedingRecordItem(record: record);
                },
              ),
            ),
          ],
        ),
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
