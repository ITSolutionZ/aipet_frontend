import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_providers.g.dart';

// 스플래시 상태 관리
@riverpod
class SplashState extends _$SplashState {
  @override
  SplashStateData build() {
    return const SplashStateData(
      isLoading: true,
      error: null,
      logoPath: 'assets/icons/aipet_logo.png',
      animationProgress: 0.0,
    );
  }

  Future<void> loadSplashConfig() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 시뮬레이션된 로딩
      await Future.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateAnimationProgress(double progress) {
    state = state.copyWith(animationProgress: progress);
  }
}

// 스플래시 상태 데이터 클래스
class SplashStateData {
  final bool isLoading;
  final String? error;
  final String logoPath;
  final double animationProgress;

  const SplashStateData({
    required this.isLoading,
    this.error,
    required this.logoPath,
    required this.animationProgress,
  });

  SplashStateData copyWith({
    bool? isLoading,
    String? error,
    String? logoPath,
    double? animationProgress,
  }) {
    return SplashStateData(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      logoPath: logoPath ?? this.logoPath,
      animationProgress: animationProgress ?? this.animationProgress,
    );
  }
}

// 스플래시 애니메이션 타이머
@riverpod
Future<void> splashAnimationTimer(Ref ref) async {
  await Future.delayed(const Duration(milliseconds: 2000));
  await Future.delayed(const Duration(milliseconds: 1000));
}
