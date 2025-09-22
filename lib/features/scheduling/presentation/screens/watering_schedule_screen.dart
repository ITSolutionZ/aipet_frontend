import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

/// 급수 스케줄 화면
class WateringScheduleScreen extends ConsumerStatefulWidget {
  const WateringScheduleScreen({super.key});

  @override
  ConsumerState<WateringScheduleScreen> createState() =>
      _WateringScheduleScreenState();
}

class _WateringScheduleScreenState
    extends ConsumerState<WateringScheduleScreen> {
  String petName = 'Max';
  List<Map<String, dynamic>>? _todayWaterings;
  List<Map<String, dynamic>>? _scheduleItems;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      // 오늘의 급수 기록 Mock 데이터
      _todayWaterings = [
        {'time': '08:00', 'amount': '200ml', 'completed': true},
        {'time': '14:00', 'amount': '150ml', 'completed': false},
        {'time': '20:00', 'amount': '180ml', 'completed': false},
      ];

      // 급수 스케줄 Mock 데이터
      _scheduleItems = [
        {'mealType': '朝の給水', 'time': '08:00', 'amount': '200ml'},
        {'mealType': '昼の給水', 'time': '14:00', 'amount': '150ml'},
        {'mealType': '夜の給水', 'time': '20:00', 'amount': '180ml'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(title: '$petNameの給水スケジュール'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 급수 요약
            if (_todayWaterings != null) _buildTodayWateringCard(),
            const SizedBox(height: AppSpacing.lg),

            // 스케줄 설정
            Text(
              '給水スケジュール設定',
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
                        return _buildScheduleItemWidget(
                          meal: item['mealType'],
                          time: item['time'],
                          amount: item['amount'],
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            // 급수 기록 추가 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed('add-watering-record');
                },
                icon: const Icon(Icons.add),
                label: const Text('給水記録を追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBlue,
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

  /// 오늘의 급수 카드
  Widget _buildTodayWateringCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日の給水',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._todayWaterings!.map(
              (watering) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      watering['completed']
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: watering['completed']
                          ? AppColors.pointGreen
                          : AppColors.pointGray,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${watering['time']} - ${watering['amount']}',
                      style: AppFonts.bodyMedium.copyWith(
                        color: watering['completed']
                            ? AppColors.pointGreen
                            : AppColors.pointDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 스케줄 아이템 위젯
  Widget _buildScheduleItemWidget({
    required String meal,
    required String time,
    required String amount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.water_drop,
            color: AppColors.pointBlue,
            size: 24,
          ),
        ),
        title: Text(
          meal,
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Text(
          '$time - $amount',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.pushNamed(
              'watering-schedule-edit',
              queryParameters: {
                'mealType': meal,
                'time': time,
                'amount': amount,
              },
            );
          },
        ),
      ),
    );
  }
}
