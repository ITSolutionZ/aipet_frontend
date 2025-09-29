import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashLogoWidget extends StatelessWidget {
  final SplashState splashState;

  const SplashLogoWidget({super.key, required this.splashState});

  @override
  Widget build(BuildContext context) {
    // 현재 상태에 따라 다른 로고 표시
    return _buildLogoForCurrentState();
  }

  Widget _buildLogoForCurrentState() {
    switch (splashState.phase) {
      case SplashPhase.loading:
        // 로딩 단계: Lottie 애니메이션 표시
        return _buildLoadingAnimation();
      case SplashPhase.appLogo:
        // 앱 로고 단계: AI Pet 로고 + 회사 로고 표시
        return _buildAppLogoWithCompanyLogo();
      case SplashPhase.initializing:
        // 초기화 중: 로딩 애니메이션 표시 (첫 번째 단계 준비)
        return _buildLoadingAnimation();
      case SplashPhase.completed:
        // 완료: 앱 로고 + 회사 로고 표시 (마지막 표시된 로고 유지)
        return _buildAppLogoWithCompanyLogo();
    }
  }

  /// 로딩 애니메이션 위젯 - 카드 없이 깔끔하게 표시
  Widget _buildLoadingAnimation() {
    return Lottie.asset(
      AppConstants.splashLoadingLottiePath,
      width: AppConstants.splashLoadingLottieSize,
      height: AppConstants.splashLoadingLottieSize,
      fit: BoxFit.contain,
      repeat: true,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(context, error, stackTrace);
      },
    );
  }

  /// 앱 로고 + 회사 로고 위젯 (앱 로고 하단에 작은 회사 로고)
  Widget _buildAppLogoWithCompanyLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 앱 로고
        Container(
          width: AppConstants.splashAppLogoSize,
          height: AppConstants.splashAppLogoSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(
                  alpha: AppConstants.splashGradientAlpha1 / 255,
                ),
                Colors.white.withValues(
                  alpha: AppConstants.splashGradientAlpha2 / 255,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.splashLogoRadius),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: AppConstants.splashBorderAlpha / 255,
              ),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.splashLogoRadius),
            child: Image.asset(
              AppConstants.splashAppLogoPath,
              fit: BoxFit.contain,
              errorBuilder: _buildErrorWidget,
            ),
          ),
        ),

        const const const SizedBox(height: AppSpacing.lg), // 앱 로고와 회사 로고 사이 간격
        // 회사 로고 (작게)
        Container(
          width: AppConstants.splashCompanyLogoWidth,
          height: AppConstants.splashCompanyLogoHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8.0), // companyLogoRadius 상수화
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              AppConstants.splashCompanyLogoPath,
              fit: BoxFit.contain,
              errorBuilder: _buildErrorWidget,
            ),
          ),
        ),
      ],
    );
  }

  /// 이미지 로드 실패시 표시할 위젯
  Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.pets, size: 60, color: Colors.grey),
    );
  }
}
