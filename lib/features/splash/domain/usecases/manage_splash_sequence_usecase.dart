import '../constants/splash_constants.dart';
import '../entities/splash_result.dart';
import '../entities/splash_state.dart';
import '../repositories/splash_repository.dart';

/// 스플래시 시퀀스 관리 UseCase
class ManageSplashSequenceUseCase {
  final SplashRepository repository;

  const ManageSplashSequenceUseCase(this.repository);

  /// 스플래시 시퀀스 실행 - 무조건 순차적 진행
  /// 1단계: 초기화 → 2단계: 회사로고 3초 → 3단계: 앱로고 3초 → 4단계: 완료
  Stream<SplashResult<SplashState>> execute() async* {
    try {
      // 1단계: 초기화 (회사 로고 준비)
      yield SplashResult.success(
        '스플래시 초기화 중...',
        SplashState.initializing(),
      );

      // 앱 초기화 작업 수행
      await repository.initializeApp();

      // 2단계: 회사 로고 표시 - 무조건 3초간 표시
      yield SplashResult.success(
        'ITZ 회사 로고 표시 중...',
        SplashState.companyLogo(SplashConstants.companyLogoPath),
      );
      
      // 회사 로고 3초 대기 (조건 없음, 무조건 대기)
      await Future.delayed(SplashConstants.logoDisplayDuration);

      // 3단계: 앱 로고 표시 - 무조건 3초간 표시
      yield SplashResult.success(
        'AI Pet 앱 로고 표시 중...',
        SplashState.appLogo(SplashConstants.appLogoPath),
      );
      
      // 앱 로고 3초 대기 (조건 없음, 무조건 대기)
      await Future.delayed(SplashConstants.logoDisplayDuration);

      // 4단계: 완료 - 온보딩으로 이동 준비
      yield SplashResult.success(
        '스플래시 시퀀스 완료 - 온보딩으로 이동',
        SplashState.completed(),
      );
    } catch (error) {
      // 에러 발생 시에도 순차적 진행 보장
      // 회사 로고 3초
      yield SplashResult.success(
        'ITZ 회사 로고 표시 중... (에러 복구)',
        SplashState.companyLogo(SplashConstants.companyLogoPath),
      );
      await Future.delayed(SplashConstants.logoDisplayDuration);
      
      // 앱 로고 3초
      yield SplashResult.success(
        'AI Pet 앱 로고 표시 중... (에러 복구)',
        SplashState.appLogo(SplashConstants.appLogoPath),
      );
      await Future.delayed(SplashConstants.logoDisplayDuration);
      
      // 최종 완료
      yield SplashResult.success(
        '스플래시 시퀀스 완료 (에러 복구)',
        SplashState.completed(),
      );
    }
  }

  /// 다음 화면 경로 결정 - 무조건 온보딩으로 이동
  Future<SplashResult<String>> determineNextRoute() async {
    // 스플래시 이후 무조건 온보딩 화면으로 이동
    // 다른 조건이나 분기 없이 고정 경로 반환
    return SplashResult.success(
      '온보딩 화면으로 이동',
      '/onboarding',
    );
  }
}