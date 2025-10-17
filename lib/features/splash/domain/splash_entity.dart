import 'splash_constants.dart';

/// 스플래시 화면 상태를 나타내는 클래스
enum SplashPhase {
  initializing,
  loading, // 로딩 애니메이션 표시
  appLogo, // 앱 로고 표시 (회사 로고 포함)
  completed,
}

/// 스플래시 설정 엔티티
class SplashEntity {
  final String logoPath;
  final Duration animationDuration;
  final Duration displayDuration;
  final String nextRoute;

  const SplashEntity({
    required this.logoPath,
    required this.animationDuration,
    required this.displayDuration,
    required this.nextRoute,
  });

  /// 기본 스플래시 설정 생성
  factory SplashEntity.defaultConfig() {
    return const SplashEntity(
      logoPath: 'assets/icons/aipet_logo.png',
      animationDuration: Duration(milliseconds: 2000),
      displayDuration: Duration(seconds: 3),
      nextRoute: '/onboarding',
    );
  }
}

/// 스플래시 상태 엔티티
class SplashState {
  final SplashPhase phase;
  final String imagePath;
  final int currentStep;
  final int totalSteps;
  final double progress;

  const SplashState({
    required this.phase,
    required this.imagePath,
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
  });

  factory SplashState.initializing() => const SplashState(
    phase: SplashPhase.initializing,
    imagePath: '',
    currentStep: 0,
    totalSteps: 2, // 로딩 + 앱로고 단계로 총 2단계
    progress: 0.0,
  );

  factory SplashState.loading() => const SplashState(
    phase: SplashPhase.loading,
    imagePath: SplashConstants.loadingLottiePath,
    currentStep: 1,
    totalSteps: 2,
    progress: 0.5,
  );

  factory SplashState.appLogo(String imagePath) => SplashState(
    phase: SplashPhase.appLogo,
    imagePath: imagePath,
    currentStep: 2,
    totalSteps: 2,
    progress: 1.0,
  );

  factory SplashState.completed() => const SplashState(
    phase: SplashPhase.completed,
    imagePath: '',
    currentStep: 2,
    totalSteps: 2,
    progress: 1.0,
  );

  bool get isCompleted => phase == SplashPhase.completed;
  bool get isLoading => phase == SplashPhase.loading;
  bool get isAppLogo => phase == SplashPhase.appLogo;
  bool get isInitializing => phase == SplashPhase.initializing;

  SplashState copyWith({
    SplashPhase? phase,
    String? imagePath,
    int? currentStep,
    int? totalSteps,
    double? progress,
  }) {
    return SplashState(
      phase: phase ?? this.phase,
      imagePath: imagePath ?? this.imagePath,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashState &&
          runtimeType == other.runtimeType &&
          phase == other.phase &&
          imagePath == other.imagePath &&
          currentStep == other.currentStep &&
          totalSteps == other.totalSteps &&
          progress == other.progress;

  @override
  int get hashCode =>
      phase.hashCode ^
      imagePath.hashCode ^
      currentStep.hashCode ^
      totalSteps.hashCode ^
      progress.hashCode;

  @override
  String toString() =>
      'SplashState(phase: $phase, step: $currentStep/$totalSteps, progress: $progress)';
}
