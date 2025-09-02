import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../data/providers/home_providers.dart';

class WeightSummaryCard extends ConsumerWidget {
  const WeightSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final currentPetId = selectedPet?.id ?? '1';

    // 선택된 펫에 따른 체중 데이터 가져오기
    final weightRecords = MockDataService.getMockWeightRecords(
      petId: currentPetId,
    );

    final currentWeight = weightRecords.isNotEmpty
        ? weightRecords.first.weight
        : 5.0;
    final previousWeight = weightRecords.length > 1
        ? weightRecords[1].weight
        : currentWeight;
    final weeklyChange = currentWeight - previousWeight;

    final weightData = {
      'currentWeight': currentWeight,
      'targetWeight': currentWeight * 0.95, // 목표 체중을 현재 체중의 95%로 설정
      'weeklyChange': weeklyChange,
      'lastMeasurement': '昨日',
    };

    return GestureDetector(
      onTap: () => context.go(RouteConstants.weightTrackingRoute),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 원형 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.pointBrown.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: AppColors.pointBrown.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.monitor_weight,
                color: AppColors.pointBrown,
                size: 24,
              ),
            ),

            const SizedBox(height: 12),

            // 메인 수치와 단위
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${weightData['currentWeight']}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
