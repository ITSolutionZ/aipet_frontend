import 'package:flutter/material.dart';

import '../../domain/domain.dart';

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
      case SplashPhase.companyLogo:
        // 회사 로고 단계: ITZ 로고 표시
        return _buildCompanyLogo();
      case SplashPhase.appLogo:
        // 앱 로고 단계: AI Pet 로고 표시
        return _buildAppLogo();
      case SplashPhase.initializing:
        // 초기화 중: 회사 로고 표시 (첫 번째 단계 준비)
        return _buildCompanyLogo();
      case SplashPhase.completed:
        // 완료: 앱 로고 표시 (마지막 표시된 로고 유지)
        return _buildAppLogo();
    }
  }

  /// 회사 로고 위젯
  Widget _buildCompanyLogo() {
    return Container(
      width: SplashConstants.companyLogoWidth,
      height: SplashConstants.companyLogoHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SplashConstants.companyLogoRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SplashConstants.companyLogoRadius),
        child: Image.asset(
          SplashConstants.companyLogoPath,
          fit: BoxFit.contain,
          errorBuilder: _buildErrorWidget,
        ),
      ),
    );
  }

  /// 앱 로고 위젯
  Widget _buildAppLogo() {
    return Container(
      width: SplashConstants.appLogoSize,
      height: SplashConstants.appLogoSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: SplashConstants.gradientAlpha1 / 255),
            Colors.white.withValues(alpha: SplashConstants.gradientAlpha2 / 255),
          ],
        ),
        borderRadius: BorderRadius.circular(SplashConstants.logoRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: SplashConstants.borderAlpha / 255),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SplashConstants.logoRadius),
        child: Image.asset(
          SplashConstants.appLogoPath,
          fit: BoxFit.contain,
          errorBuilder: _buildErrorWidget,
        ),
      ),
    );
  }

  /// 이미지 로드 실패시 표시할 위젯
  Widget _buildErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.pets,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}
