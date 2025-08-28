/// 스플래시 화면 상태를 나타내는 클래스
enum SplashPhase { 
  initializing, 
  companyLogo, 
  appLogo, 
  completed 
}

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
        totalSteps: 2,
        progress: 0.0,
      );

  factory SplashState.companyLogo(String imagePath) => SplashState(
        phase: SplashPhase.companyLogo,
        imagePath: imagePath,
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
  bool get isCompanyLogo => phase == SplashPhase.companyLogo;
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