import 'package:aipet_frontend/features/pet_profile/pet_profile.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appbar_banner_image.dart';

/// 홈 화면 상단 펫 프로필 배너
class PetProfileBanner extends ConsumerWidget {
  final double scrollOffset;

  const PetProfileBanner({super.key, this.scrollOffset = 0.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.35, // 배너 높이 더 증가
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Stack(
          children: [
            // 배너 이미지 (배경)
            const Positioned.fill(child: AppbarBannerImage()),
            // 그라데이션 오버레이 (동적 투명도)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // 상단은 항상 투명
                      scrollOffset > 0
                          ? Colors.white.withValues(alpha: 0.8) // 스크롤 시 하단 흰색
                          : Colors.transparent, // 스크롤 없을 때 하단도 투명
                    ],
                  ),
                ),
              ),
            ),
            // 콘텐츠 (펫 프로필) - SafeArea 제거하여 화면 최상단부터 시작
            Padding(
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top +
                    AppSpacing.xl, // 상태바 높이 + 여백
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: 0, // 하단 패딩 삭제
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 펫 프로필 섹션
                  Expanded(
                    child: petsAsync.when(
                      data: (pets) {
                        if (pets.isEmpty) {
                          return _buildEmptyState(context);
                        }
                        return _buildPetProfiles(context, pets);
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (error, _) => _buildErrorState(context),
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

  Widget _buildPetProfiles(BuildContext context, List<PetProfileEntity> pets) {
    // 펫 프로필과 추가 버튼을 완전히 숨김
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return const SizedBox.shrink(); // 빈 위젯으로 완전히 숨김
  }

  Widget _buildErrorState(BuildContext context) {
    return const Center(
      child: Text(
        'データの読み込みに失敗しました',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
