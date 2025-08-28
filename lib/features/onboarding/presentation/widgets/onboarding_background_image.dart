import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';

/// 온보딩 배경 이미지를 정교하게 표시하는 위젯
class OnboardingBackgroundImage extends StatelessWidget {
  final OnboardingPage page;
  final double screenHeight;
  final double screenWidth;

  const OnboardingBackgroundImage({
    super.key,
    required this.page,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (page.useCustomImageDisplay) {
      return _buildCustomImageDisplay();
    } else {
      return _buildStandardImageDisplay();
    }
  }

  /// 표준 이미지 표시 (기존 방식)
  Widget _buildStandardImageDisplay() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(page.imagePath),
          fit: page.imageFit,
          alignment: page.imageAlignment,
          onError: (exception, stackTrace) {
            debugPrint('❌ 이미지 로드 실패: ${page.imagePath}');
            debugPrint('   에러: $exception');
          },
        ),
      ),
    );
  }

  /// 커스텀 이미지 표시 (더 정교한 제어)
  Widget _buildCustomImageDisplay() {
    final pageIndex = OnboardingData.pages.indexOf(page);

    return Stack(
      children: [
        // 배경 이미지 - 반응형으로 중요한 부분이 보이도록
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 화면 비율에 따라 이미지 표시 방식 조정
              final aspectRatio = constraints.maxWidth / constraints.maxHeight;

              // 세로 화면 (모바일)
              if (aspectRatio < 0.8) {
                // Intelligent 페이지는 더 큰 이미지로 표시
                if (pageIndex == 2) {
                  return Transform.scale(
                    scale: 2.5, // 150% 더 크게
                    alignment: Alignment.center,
                    child: _buildImageWithFallback(),
                  );
                }

                return _buildImageWithFallback();
              }
              // 가로 화면 (태블릿)
              else {
                return _buildImageWithFallback();
              }
            },
          ),
        ),
        // 그라데이션 오버레이 (위에서 아래로 어두워지는 효과)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 이미지 로드 실패 시 fallback 처리
  Widget _buildImageWithFallback() {
    return Image.asset(
      page.imagePath,
      fit: _getOptimalFit(),
      alignment: _getOptimalAlignment(),
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ 이미지 로드 실패: ${page.imagePath}');
        debugPrint('   에러: $error');

        // Fallback: 기본 배경색과 아이콘 표시
        return Container(
          color: AppColors.pointBrown.withValues(
            alpha: OnboardingConstants.fallbackBackgroundOpacity,
          ),
          child: Center(
            child: Icon(
              Icons.pets,
              size: 80,
              color: AppColors.pointBrown.withValues(
                alpha: OnboardingConstants.fallbackIconOpacity,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 페이지별 최적 fit 반환
  BoxFit _getOptimalFit() {
    final pageIndex = OnboardingData.pages.indexOf(page);

    switch (pageIndex) {
      case 0: // Welcome - 손바닥 위의 강아지 발 (클로즈업 효과)
        return BoxFit.cover;
      case 1: // Together - 산책하는 강아지와 사람 (전체 장면)
        return BoxFit.cover;
      case 2: // Intelligent - 골든 리트리버 강아지 얼굴 (더 큰 클로즈업)
        return BoxFit.cover;
      case 3: // Reservations - 포메라니안 강아지 얼굴 (클로즈업)
        return BoxFit.cover;
      default:
        return BoxFit.cover;
    }
  }

  /// 페이지별 최적 정렬 반환
  Alignment _getOptimalAlignment() {
    // 페이지 인덱스에 따라 최적의 정렬 반환
    final pageIndex = OnboardingData.pages.indexOf(page);

    switch (pageIndex) {
      case 0: // Welcome - 손바닥 위의 강아지 발 (하단에 위치)
        return Alignment.bottomCenter; // 하단 중앙
      case 1: // Together - 산책하는 강아지와 사람 (상단 중앙)
        return Alignment.topCenter; // 상단 중앙
      case 2: // Intelligent - 골든 리트리버 강아지 얼굴 (중앙)
        return Alignment.center; // 중앙
      case 3: // Reservations - 포메라니안 강아지 얼굴 (중앙)
        return Alignment.center; // 중앙
      default:
        return Alignment.center;
    }
  }
}
