import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../domain/domain.dart';

/// ITZ 회사 로고를 표시하는 페이지
///
/// 스플래시 시퀀스의 첫 번째 단계로, ITZ 회사 로고를 3초간 표시한 후
/// 메인 스플래시 화면으로 이동합니다.
class LogoPage extends ConsumerStatefulWidget {
  const LogoPage({super.key});

  @override
  ConsumerState<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends ConsumerState<LogoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLogoSequence();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
  }

  void _startLogoSequence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();

      // 3초 후 스플래시 화면으로 이동
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.go(AppRouter.splashRoute);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildLogo(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: SplashConstants.companyLogoWidth,
      height: SplashConstants.companyLogoHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SplashConstants.companyLogoRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SplashConstants.companyLogoRadius),
        child: Image.asset(
          SplashConstants.companyLogoPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.business, size: 60, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
