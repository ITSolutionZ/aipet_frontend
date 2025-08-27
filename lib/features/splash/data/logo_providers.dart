import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logo_providers.g.dart';

// 로고 상태 관리
@riverpod
class LogoState extends _$LogoState {
  @override
  LogoStateData build() {
    return const LogoStateData(
      isLoading: true,
      error: null,
      currentPhase: LogoPhase.company,
      companyLogoPath: 'assets/icons/itz.png',
      appLogoPath: 'assets/icons/aipet_logo.png',
    );
  }

  /// 로고 시퀀스 시작 - 순수 비즈니스 로직만 포함
  Future<void> startLogoSequence() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPhase: LogoPhase.company,
    );

    try {
      // 1단계: ITZ 로고 표시 (정확히 3초)
      await _showCompanyLogo();

      // 2단계: AI Pet 로고 표시 (정확히 3초)
      await _showAppLogo();

      // 완료 - 모든 단계 완료 후에만
      state = state.copyWith(
        isLoading: false,
        currentPhase: LogoPhase.completed,
      );
    } catch (e) {
      // 에러 발생 시에도 모든 로고를 표시해야 함
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        currentPhase: LogoPhase.completed,
      );
    }
  }

  /// ITZ 로고 표시 단계 - 정확히 3초
  Future<void> _showCompanyLogo() async {
    state = state.copyWith(
      currentPhase: LogoPhase.company,
      isLoading: true,
    );
    
    // 정확히 3초 대기
    await Future.delayed(const Duration(seconds: 3));
    
    // ITZ 로고 완료 후 AI Pet 단계로 자동 전환
    state = state.copyWith(currentPhase: LogoPhase.app);
  }

  /// AI Pet 로고 표시 단계 - 정확히 3초
  Future<void> _showAppLogo() async {
    state = state.copyWith(
      currentPhase: LogoPhase.app,
      isLoading: true,
    );
    
    // 정확히 3초 대기
    await Future.delayed(const Duration(seconds: 3));
    
    // AI Pet 로고 완료 후 completed 단계로 자동 전환
    state = state.copyWith(currentPhase: LogoPhase.completed);
  }

  /// 현재 로고 경로 반환
  String get currentLogoPath {
    switch (state.currentPhase) {
      case LogoPhase.company:
        return state.companyLogoPath;
      case LogoPhase.app:
      case LogoPhase.completed:
        return state.appLogoPath;
    }
  }

  /// 로고 시퀀스 완료 여부
  bool get isSequenceComplete => state.currentPhase == LogoPhase.completed;
}

// 로고 단계 열거형
enum LogoPhase { company, app, completed }

// 로고 상태 데이터 클래스
class LogoStateData {
  final bool isLoading;
  final String? error;
  final LogoPhase currentPhase;
  final String companyLogoPath;
  final String appLogoPath;

  const LogoStateData({
    required this.isLoading,
    this.error,
    required this.currentPhase,
    required this.companyLogoPath,
    required this.appLogoPath,
  });

  LogoStateData copyWith({
    bool? isLoading,
    String? error,
    LogoPhase? currentPhase,
    String? companyLogoPath,
    String? appLogoPath,
  }) {
    return LogoStateData(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPhase: currentPhase ?? this.currentPhase,
      companyLogoPath: companyLogoPath ?? this.companyLogoPath,
      appLogoPath: appLogoPath ?? this.appLogoPath,
    );
  }

  /// 현재 표시할 로고 경로
  String get currentLogoPath {
    switch (currentPhase) {
      case LogoPhase.company:
        return companyLogoPath;
      case LogoPhase.app:
      case LogoPhase.completed:
        return appLogoPath;
    }
  }

  /// 로고 시퀀스 완료 여부
  bool get isSequenceComplete => currentPhase == LogoPhase.completed;
}
