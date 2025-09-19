import '../../../../shared/shared.dart';
import '../constants/splash_constants.dart';
import '../entities/splash_state.dart';
import '../repositories/splash_repository.dart';

/// 스플래시 시퀀스 관리 UseCase
class ManageSplashSequenceUseCase {
  final SplashRepository repository;

  const ManageSplashSequenceUseCase(this.repository);

  /// 스플래시 시퀀스 실행 - 무조건 순차적 진행
  /// 1단계: 초기화 (Lottie 애니메이션) → 2단계: 로딩 1.5초 → 3단계: 회사로고 2초 → 4단계: 앱로고 2초 → 5단계: 완료
  Stream<Result<SplashState>> execute() async* {
    try {
      // 1단계: 초기화 (로딩 애니메이션 준비)
      yield Result.success('スプラッシュ初期化中...', SplashState.initializing());

      // 앱 초기화 작업 수행
      final initResult = await repository.initializeApp();
      if (!initResult.isSuccess) {
        // 초기화 실패 시에도 시퀀스는 계속 진행
      }

      // 2단계: 로딩 애니메이션 표시 - 1.5초간 표시
      yield Result.success('ローディングアニメーション表示中...', SplashState.loading());

      // 로딩 애니메이션 1.5초 대기
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3단계: 회사 로고 표시 - 무조건 2초간 표시
      yield Result.success(
        'ITZ会社ロゴ表示中...',
        SplashState.companyLogo(SplashConstants.companyLogoPath),
      );

      // 회사 로고 2초 대기 (조건 없음, 무조건 대기)
      await Future.delayed(SplashConstants.logoDisplayDuration);

      // 4단계: 앱 로고 표시 - 무조건 2초간 표시
      yield Result.success(
        'AI Petアプリロゴ表示中...',
        SplashState.appLogo(SplashConstants.appLogoPath),
      );

      // 앱 로고 2초 대기 (조건 없음, 무조건 대기)
      await Future.delayed(SplashConstants.logoDisplayDuration);

      // 5단계: 완료 - 온보딩으로 이동 준비
      yield Result.success(
        'スプラッシュシーケンス完了 - オンボーディングへ移動',
        SplashState.completed(),
      );
    } catch (error) {
      // 에러 발생 시에도 순차적 진행 보장
      // 로딩 애니메이션 1.5초
      yield Result.success(
        'ローディングアニメーション表示中... (エラー復旧)',
        SplashState.loading(),
      );
      await Future.delayed(const Duration(milliseconds: 1500));

      // 회사 로고 2초
      yield Result.success(
        'ITZ会社ロゴ表示中... (エラー復旧)',
        SplashState.companyLogo(SplashConstants.companyLogoPath),
      );
      await Future.delayed(SplashConstants.logoDisplayDuration);

      // 앱 로고 2초
      yield Result.success(
        'AI Petアプリロゴ表示中... (エラー復旧)',
        SplashState.appLogo(SplashConstants.appLogoPath),
      );
      await Future.delayed(SplashConstants.logoDisplayDuration);

      // 최종 완료
      yield Result.success('スプラッシュシーケンス完了 (エラー復旧)', SplashState.completed());
    }
  }

  /// 다음 화면 경로 결정 - 무조건 온보딩으로 이동
  Future<Result<String>> determineNextRoute() async {
    // 스플래시 이후 무조건 온보딩 화면으로 이동
    // 다른 조건이나 분기 없이 고정 경로 반환
    return Result.success('オンボーディング画面へ移動', '/onboarding');
  }
}
