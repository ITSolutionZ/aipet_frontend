import 'package:aipet_frontend/features/home/data/providers/pets_provider.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/pet_profile_card/pet_card_item.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/pet_profile_card/pet_empty_state.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/pet_profile_card/pet_navigation_dots.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 리팩토링된 Pet Profile Card
///
/// 기존 320줄의 거대한 위젯을 컴포넌트로 분리:
/// - PetEmptyState: 펫이 없을 때 상태
/// - PetCardItem: 개별 펫 카드
/// - PetNavigationDots: 네비게이션 점들
/// - 마이크로칩 체크 로직 분리
class PetProfileCardRefactored extends ConsumerStatefulWidget {
  const PetProfileCardRefactored({super.key});

  @override
  ConsumerState<PetProfileCardRefactored> createState() => _PetProfileCardRefactoredState();
}

class _PetProfileCardRefactoredState extends ConsumerState<PetProfileCardRefactored> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// 마이크로칩 등록 체크 (추후 구현)
  void _checkMicrochipRegistration(List<PetEntity> pets) {
    // TODO: home feature에서 필요한 경우 별도 구현
    // cross-feature 의존성 제거를 위해 임시 비활성화
  }

  /// 페이지 변경 처리
  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// 네비게이션 점 탭 처리
  void _onDotTap(int index) {
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (petList) {
        // 마이크로칩 등록 체크 (현재는 비활성화)
        _checkMicrochipRegistration(petList);

        // 펫이 없을 때
        if (petList.isEmpty) {
          return const PetEmptyState();
        }

        // 펫이 1개일 때
        if (petList.length == 1) {
          return PetCardItem(pet: petList.first);
        }

        // 펫이 여러 개일 때 - PageView 사용
        return _buildMultiplePetsView(petList);
      },
      loading: () => const _LoadingCard(),
      error: (error, stackTrace) => _ErrorCard(error: error.toString()),
    );
  }

  Widget _buildMultiplePetsView(List<PetEntity> petList) {
    return Column(
      children: [
        // PageView로 펫 카드들 표시
        SizedBox(
          height: 280, // 고정 높이 설정
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: petList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: PetCardItem(pet: petList[index]),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 네비게이션 점들
        PetNavigationDots(
          currentIndex: _currentIndex,
          totalCount: petList.length,
          onTap: _onDotTap,
        ),
      ],
    );
  }
}

/// 로딩 카드
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const WhiteCard.panel(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.pointBrown,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'ペット情報を読み込み中...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 에러 카드
class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return WhiteCard.panel(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.pointPink,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'ペット情報の読み込みに失敗しました',
                style: AppFonts.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}