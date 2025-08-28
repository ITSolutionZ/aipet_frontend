import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../controllers/controllers.dart';
import '../widgets/widgets.dart';

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
  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController(ref);
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: SplashConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: SplashConstants.fadeStart,
      end: SplashConstants.fadeEnd,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: SplashConstants.fadeInterval,
    ));

    _scaleAnimation = Tween<double>(
      begin: SplashConstants.scaleStart,
      end: SplashConstants.scaleEnd,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: SplashConstants.scaleInterval,
    ));
  }

  void _startSplashSequence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _listenToSplashSequence();
    });
  }

  void _listenToSplashSequence() {
    _controller.startSplashSequence().listen(
      (result) {
        if (result.isSuccess && result.data != null) {
          // 상태 업데이트
          ref.read(splashSequenceNotifierProvider.notifier).updateState(result.data!);
          
          // 완료 시 다음 화면으로 이동
          if (result.data!.isCompleted) {
            _navigateToNext();
          }
        }
      },
      onError: (error) {
        // 에러 발생 시에도 다음 화면으로 이동
        _navigateToNext();
      },
    );
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    
    // 스플래시 완료 후 무조건 온보딩으로 이동
    // 다른 조건이나 분기 로직 없음
    context.go(AppRouter.onboardingRoute);
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
    final splashState = ref.watch(splashSequenceNotifierProvider);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SplashLogoWidget(
              splashState: splashState,
            ),
          ),
        );
      },
    );
  }
}
