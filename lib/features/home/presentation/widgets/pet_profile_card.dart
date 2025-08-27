import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../../pet_registor/data/providers/pet_providers.dart';

class PetProfileCard extends ConsumerWidget {
  const PetProfileCard({
    super.key,
    this.petName = 'ペコ',
    this.petImagePath = 'assets/images/dogs/poodle.jpg',
    this.activities = const ['○ 今日は散歩記録がありません', '○ 昼ごはんを食べました'],
  });

  final String petName;
  final String petImagePath;
  final List<String> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pet 리스트 관리 - Mockito를 사용한 실제 Pet provider에서 로드
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (petList) {
        final currentPet = petList.isNotEmpty ? petList[0] : null;
        final hasMultiplePets = petList.length > 1;

        if (currentPet == null) {
          return GestureDetector(
            onTap: () => context.push('/pet/register'),
            child: WhiteCard.panel(
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ペットを登録してください',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => context.push(AppRouter.petProfileRoute),
          child: WhiteCard.panel(
            child: Row(
              children: [
                // 펫 아바타
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pointBrown.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      currentPet.imagePath ?? 'assets/images/pets/default.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets,
                          color: AppColors.pointBrown,
                          size: 30,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 펫 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currentPet.name,
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.lg,
                              color: AppColors.pointDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.small,
                              ),
                            ),
                            child: Text(
                              currentPet.breed ?? currentPet.typeName,
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.pointDark,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...activities.map(
                        (activity) => Text(
                          activity,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 화살표 아이콘 (펫이 2마리 이상일 때 표시)
                if (hasMultiplePets) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.pointGray,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => WhiteCard.panel(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pointBrown.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.pointBrown,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => WhiteCard.panel(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pointBrown.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ペット情報の読み込みに失敗しました',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'タップして再試行',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
