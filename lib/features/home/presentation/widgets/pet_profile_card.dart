import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../../pet_registor/data/providers/pet_providers.dart';
import '../../data/providers/home_providers.dart';

class PetProfileCard extends ConsumerStatefulWidget {
  const PetProfileCard({super.key});

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

  /// 마이크로칩 등록 체크 및 모달 표시
  void _checkMicrochipRegistration(List<dynamic> pets) {
    if (pets.isNotEmpty) {
      final firstPet = pets.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MicrochipReminderService.showReminderIfNeeded(
          context,
          firstPet,
          onRegisterTap: () {
            // 마이크로칩 등록 화면으로 이동
            context.push('/pet/microchip-register');
          },
        );
      });
    }
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
        // 마이크로칩 등록 체크
        _checkMicrochipRegistration(petList);

        if (petList.isEmpty) {
          return GestureDetector(
            onTap: () => context.push('/pet/register'),
            child: const WhiteCard.panel(
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: AppColors.pointGray,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ペットを登録してください',
                    style: TextStyle(color: AppColors.pointGray),
                  ),
                ],
              ),
            ),
          );
        }

        final hasMultiplePets = petList.length > 1;

        return WhiteCard.panel(
          borderWidth: 1.5,
          borderColor: Colors.white.withValues(alpha: 0.5),
          elevation: 8,
          child: Column(
            children: [
              // ペット表示部分 (スワイプ対応)
              SizedBox(
                height: 100, // 固定 높이 설정
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    // 페이지 변경 시 홈 선택된 펫 프로바이더 업데이트
                    if (index < petList.length) {
                      ref
                          .read(homeSelectedPetNotifierProvider.notifier)
                          .selectPet(petList[index]);
                    }
                  },
                  itemCount: petList.length,
                  itemBuilder: (context, index) {
                    final currentPet = petList[index];
                    return GestureDetector(
                      onTap: () => context.push(
                        '${AppRouter.petProfileRoute}?petId=${currentPet.id}',
                      ),
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
                                        PetMockData.getPetGenderByName(
                                                  currentPet.name,
                                                ) ==
                                                'male'
                                            ? 'オス'
                                            : 'メス',
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
                                ...HomeMockService.getMockPetActivities().map(
                                  (activity) => Text(
                                    activity['label']?.toString() ?? '',
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
                      color: AppColors.pointGray.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.pointGray.withValues(alpha: 0.3),
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
                color: AppColors.pointPink,
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
                      color: AppColors.pointPink,
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
