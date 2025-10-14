import 'package:aipet_frontend/features/home/presentation/widgets/appbar_banner_image.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 홈 화면 상단 펫 프로필 배너
class PetProfileBanner extends ConsumerWidget {
  final double scrollOffset;

  const PetProfileBanner({super.key, this.scrollOffset = 0.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesNotifierProvider);

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
    // 최대 3마리까지만 표시
    final displayPets = pets.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...displayPets.map((pet) => _buildPetAvatar(context, pet)),
        if (pets.length < 3) _buildAddPetButton(context),
      ],
    );
  }

  Widget _buildPetAvatar(BuildContext context, PetProfileEntity pet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          context.push('/pet-profile/${pet.id}');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(child: _getPetImage(pet)),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              pet.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          context.push('/daily/pet-registration');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 40),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              '追加',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _getPetImage(PetProfileEntity pet) {
    // 펫 이미지가 있는 경우
    if (pet.imagePath != null && pet.imagePath!.isNotEmpty) {
      return Image.asset(
        pet.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _getDefaultPetIcon(pet);
        },
      );
    }

    // 기본 펫 이미지
    return _getDefaultPetIcon(pet);
  }

  Widget _getDefaultPetIcon(PetProfileEntity pet) {
    IconData iconData;
    if (pet.type == 'dog') {
      iconData = Icons.pets;
    } else if (pet.type == 'cat') {
      iconData = Icons.pets;
    } else {
      iconData = Icons.pets;
    }

    return Container(
      color: AppColors.pointGreen.withValues(alpha: 0.2),
      child: Icon(iconData, color: AppColors.pointGreen, size: 40),
    );
  }
}
