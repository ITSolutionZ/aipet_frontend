import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Splash Screen 애니메이션 상태 관리
final splashAnimationProvider =
    StateNotifierProvider<SplashAnimationController, SplashAnimationState>(
      (ref) => SplashAnimationController(),
    );

class SplashAnimationController extends StateNotifier<SplashAnimationState> {
  SplashAnimationController() : super(const SplashAnimationState());

  void initializeAnimations(TickerProvider vsync) {
    final animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    final scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    state = state.copyWith(
      animationController: animationController,
      fadeAnimation: fadeAnimation,
      scaleAnimation: scaleAnimation,
    );
  }

  void startAnimation() {
    state.animationController?.forward();
  }

  @override
  void dispose() {
    state.animationController?.dispose();
    super.dispose();
  }
}

class SplashAnimationState {
  final AnimationController? animationController;
  final Animation<double>? fadeAnimation;
  final Animation<double>? scaleAnimation;

  const SplashAnimationState({
    this.animationController,
    this.fadeAnimation,
    this.scaleAnimation,
  });

  SplashAnimationState copyWith({
    AnimationController? animationController,
    Animation<double>? fadeAnimation,
    Animation<double>? scaleAnimation,
  }) {
    return SplashAnimationState(
      animationController: animationController ?? this.animationController,
      fadeAnimation: fadeAnimation ?? this.fadeAnimation,
      scaleAnimation: scaleAnimation ?? this.scaleAnimation,
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashAnimationProvider.notifier).initializeAnimations(this);
      ref.read(splashAnimationProvider.notifier).startAnimation();
      _listenToSplashSequence();
    });
  }

  void _listenToSplashSequence() {
    // 스플래시 시퀀스를 단순화: 3초 후 자동으로 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;

    // 스플래시 완료 후 무조건 온보딩으로 이동
    // 다른 조건이나 분기 로직 없음
    context.go(AppRouter.onboardingRoute);
  }

  @override
  void dispose() {
    ref.read(splashAnimationProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationState = ref.watch(splashAnimationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: animationState.animationController != null
            ? AnimatedBuilder(
                animation: animationState.animationController!,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: animationState.fadeAnimation!,
                    child: ScaleTransition(
                      scale: animationState.scaleAnimation!,
                      child: const Center(child: FlutterLogo(size: 150)),
                    ),
                  );
                },
              )
            : const Center(child: FlutterLogo(size: 150)),
      ),
    );
  }
}
