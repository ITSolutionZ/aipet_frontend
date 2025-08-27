import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAIPetLogo();
  }

  void _initializeAnimations() {
    // AI Pet 로고 애니메이션 (3초)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 페이드 인 애니메이션 (0-1초)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeIn),
      ),
    );

    // 스케일 애니메이션 (0-1초)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.33, curve: Curves.elasticOut),
      ),
    );
  }

  /// AI Pet 로고 시작 - UI 초기화만 담당
  void _startAIPetLogo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 애니메이션 시작
      _animationController.forward();

      // AI Pet 로고를 3초간 표시
      await Future.delayed(const Duration(seconds: 3));

      // 3초 후 onboarding 화면으로 이동
      if (mounted) {
        _navigateToNext();
      }
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
      body: Center(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildLogoContent(),
          ),
        );
      },
    );
  }

  /// AI Pet 로고 표시 UI
  Widget _buildLogoContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // AI Pet 로고 이미지 (300x300 고정 크기)
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            // 그라데이션 배경
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withAlpha(23), Colors.white.withAlpha(10)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(22), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/icons/aipet_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  /// 다음 화면으로 이동 - UI 로직만 담당
  void _navigateToNext() {
    context.go(AppRouter.onboardingRoute);
  }
}
