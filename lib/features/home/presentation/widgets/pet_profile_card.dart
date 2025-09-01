import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../../pet_registor/data/providers/pet_providers.dart';

class PetProfileCard extends ConsumerStatefulWidget {
  const PetProfileCard({
    super.key,
    this.activities = const ['○ 今日は散歩記録がありません', '○ 昼ごはんを食べました'],
  });

  final List<String> activities;

  @override
  ConsumerState<PetProfileCard> createState() => _PetProfileCardState();
}

class _PetProfileCardState extends ConsumerState<PetProfileCard> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pet 리스트 관리 - Mockito를 사용한 실제 Pet provider에서 로드
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (petList) {
        if (petList.isEmpty) {
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

        final hasMultiplePets = petList.length > 1;

        return WhiteCard.panel(
          child: Column(
            children: [
              // ペット表示部分 (スワイプ対応)
              SizedBox(
                height: 100, // 固定 높이 설정
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    // 페이지 변경 시 추가 로직이 필요한 경우 여기에 구현
                  },
                  itemCount: petList.length,
                  itemBuilder: (context, index) {
                    final currentPet = petList[index];
                    return GestureDetector(
                      onTap: () => context.push(AppRouter.petProfileRoute),
                      child: Row(
                        children: [
                          // 펫 아바타
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                currentPet.imagePath ??
                                    'assets/images/pets/default.jpg',
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                ...widget.activities.map(
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
                    );
                  },
                ),
              ),
            ],
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
