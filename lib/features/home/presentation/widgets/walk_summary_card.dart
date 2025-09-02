import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../data/providers/home_providers.dart';

class WalkSummaryCard extends ConsumerWidget {
  const WalkSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final currentPetId = selectedPet?.id ?? '1';

    // 선택된 펫에 따른 산책 데이터 가져오기
    final walkSummary = MockDataService.getMockWalkSummary(petId: currentPetId);

    final walkData = {
      'todayWalks': walkSummary.todayWalks,
      'todayDistance': walkSummary.todayDistance,
      'weeklyProgress': walkSummary.weeklyProgress / walkSummary.weeklyGoal,
      'nextWalkTime': '夕方',
    };

    return GestureDetector(
      onTap: () => context.go(RouteConstants.walkFromHomeRoute),
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
                  color: AppColors.pointGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: AppColors.pointGreen.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.directions_walk,
                color: AppColors.pointGreen,
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
                  '${walkData['todayDistance']}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'km',
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
