import 'dart:async';

import 'package:aipet_frontend/app/bootstrap/app_bootstrap.dart';
import 'package:aipet_frontend/app/providers/app_initialization_provider.dart';
import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/splash/data/data.dart';
import 'package:aipet_frontend/features/splash/presentation/widgets/splash_logo_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_screen.g.dart';

/// 스플래시 애니메이션 상태 관리
@riverpod
class SplashAnimationNotifier extends _$SplashAnimationNotifier {
  @override
  SplashAnimationState build() => const SplashAnimationState();

  void initializeAnimations(TickerProvider vsync) {
    final animationController = AnimationController(
      duration: AppConstants.splashAnimationDuration,
      vsync: vsync,
    );

    // ✅ 애니메이션 최적화 - 메모리 효율적인 생성
    final fadeAnimation = _createFadeAnimation(animationController);
    final scaleAnimation = _createScaleAnimation(animationController);

    state = state.copyWith(
      animationController: animationController,
      fadeAnimation: fadeAnimation,
      scaleAnimation: scaleAnimation,
    );
  }

  /// Fade 애니메이션 생성
  Animation<double> _createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: AppConstants.splashFadeStart,
      end: AppConstants.splashFadeEnd,
    ).animate(CurvedAnimation(parent: controller, curve: AppConstants.splashFadeInterval));
  }

  /// Scale 애니메이션 생성
  Animation<double> _createScaleAnimation(AnimationController controller) {
    return Tween<double>(
      begin: AppConstants.splashScaleStart,
      end: AppConstants.splashScaleEnd,
    ).animate(CurvedAnimation(parent: controller, curve: AppConstants.splashScaleInterval));
  }

  void startAnimation() {
    state.animationController?.forward();
  }

  void dispose() {
    state.animationController?.dispose();
  }
}

/// 스플래시 애니메이션 상태
class SplashAnimationState {
  final AnimationController? animationController;
  final Animation<double>? fadeAnimation;
  final Animation<double>? scaleAnimation;

  const SplashAnimationState({this.animationController, this.fadeAnimation, this.scaleAnimation});

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

/// 스플래시 화면
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.testMode = false, // 테스트 모드 지원
  });

  final bool testMode;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<Result<SplashState>>? _splashSequenceSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.testMode) {
        // 테스트 모드에서는 즉시 완료
        _navigateToNext();
      } else {
        _initializeSplash();
      }
    });
  }

  /// 이미지 프리로딩
  Future<void> _preloadImages() async {
    try {
      await Future.wait([
        precacheImage(const AssetImage(AppConstants.splashAppLogoPath), context),
        precacheImage(const AssetImage(AppConstants.splashCompanyLogoPath), context),
      ]);
    } catch (error) {
      // 이미지 프리로딩 실패는 치명적이지 않으므로 로그만 남김
      debugPrint('Image preloading failed: $error');
    }
  }

  /// 스플래시 초기화
  void _initializeSplash() async {
    // 앱 부트스트랩 초기화 실행
    await AppBootstrap.initialize();

    // 이미지 프리로딩
    await _preloadImages();

    // 애니메이션 초기화
    ref.read(splashAnimationNotifierProvider.notifier).initializeAnimations(this);
    ref.read(splashAnimationNotifierProvider.notifier).startAnimation();

    // 스플래시 시퀀스 시작
    _startSplashSequence();
  }

  /// 스플래시 시퀀스 시작
  void _startSplashSequence() {
    final controller = ref.read(splashControllerNotifierProvider.notifier);
    _splashSequenceSubscription = controller.startSplashSequence().listen(
      (result) => _handleSplashResult(result),
      onError: (error) => _handleSplashError(error),
    );
  }

  /// 스플래시 결과 처리
  void _handleSplashResult(Result<SplashState> result) {
    if (result.isSuccess && result.dataOrNull != null) {
      // 상태 업데이트 - SplashStateNotifier를 사용
      ref.read(splashStateNotifierProvider.notifier).updateState(result.dataOrNull!);

      // 완료 시 다음 화면으로 이동
      if (result.dataOrNull!.isCompleted) {
        _navigateToNext();
      }
    } else {
      _handleSplashError(Exception(result.error ?? 'Unknown error'));
    }
  }

  /// 스플래시 에러 처리
  void _handleSplashError(Object error) {
    // 에러 로깅
    debugPrint('Splash sequence error: $error');

    if (mounted) {
      // 에러 상태를 UI에 반영
      ref
          .read(splashStateNotifierProvider.notifier)
          .updateState(
            SplashState.loading(), // 에러 시 로딩 상태로 표시
          );

      // 기본 시퀀스로 fallback
      _startFallbackSequence();
    }
  }

  /// Fallback 시퀀스 시작
  void _startFallbackSequence() {
    // 에러 복구를 위한 간단한 시퀀스
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(splashStateNotifierProvider.notifier).setLoading();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        ref.read(splashStateNotifierProvider.notifier).setAppLogo();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(splashStateNotifierProvider.notifier).setCompleted();
        if (mounted) {
          _navigateToNext();
        }
      }
    });
  }

  /// 다음 화면으로 이동
  Future<void> _navigateToNext() async {
    if (!mounted) return;

    try {
      // 앱 부트스트랩 초기화 완료 확인
      if (!AppBootstrap.isInitialized) {
        debugPrint('⚠️ App bootstrap not completed, initializing...');
        await AppBootstrap.initialize();
      }

      // 앱 초기화 상태 확인
      final initState = ref.read(appInitializationProvider);

      if (initState.isInitialized) {
        // 온보딩 완료 상태에 따라 라우팅 결정
        if (initState.isOnboardingCompleted) {
          if (mounted) {
            context.go(AppRouter.homeRoute);
          }
        } else {
          if (mounted) {
            context.go(AppRouter.onboardingRoute);
          }
        }
      } else {
        // 초기화가 완료되지 않은 경우 온보딩으로 이동
        if (mounted) {
          context.go(AppRouter.onboardingRoute);
        }
      }
    } catch (error) {
      debugPrint('Navigation error: $error');
      // 에러 발생 시 기본 경로로 이동
      if (mounted) {
        context.go(AppRouter.onboardingRoute);
      }
    }
  }

  @override
  void dispose() {
    // StreamSubscription 명시적 해제
    _splashSequenceSubscription?.cancel();
    _splashSequenceSubscription = null;

    // Riverpod Notifier는 자동으로 dispose되므로 별도 호출 불필요
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Semantics(
        label: 'スプラッシュ画面',
        child: Center(
          child: Consumer(
            builder: (context, ref, child) {
              final animationState = ref.watch(splashAnimationNotifierProvider);
              final splashState = ref.watch(splashStateNotifierProvider);

              return animationState.animationController != null
                  ? AnimatedBuilder(
                      animation: animationState.animationController!,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: animationState.fadeAnimation!,
                          child: ScaleTransition(
                            scale: animationState.scaleAnimation!,
                            child: Semantics(
                              label: _getSemanticLabel(splashState),
                              child: SplashLogoWidget(splashState: splashState),
                            ),
                          ),
                        );
                      },
                    )
                  : Semantics(
                      label: _getSemanticLabel(splashState),
                      child: SplashLogoWidget(splashState: splashState),
                    );
            },
          ),
        ),
      ),
    );
  }

  /// 접근성을 위한 시맨틱 라벨 생성
  String _getSemanticLabel(SplashState state) {
    switch (state.phase) {
      case SplashPhase.initializing:
        return 'アプリを初期化しています';
      case SplashPhase.loading:
        return '読み込み中です';
      case SplashPhase.appLogo:
        return 'AI Petアプリロゴを表示しています';
      case SplashPhase.completed:
        return 'スプラッシュが完了しました';
    }
  }
}
