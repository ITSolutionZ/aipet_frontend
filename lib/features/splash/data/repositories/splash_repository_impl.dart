import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 스플래시 Repository 구현체
class SplashRepositoryImpl implements SplashRepository {
  @override
  Future<Result<SplashEntity>> getSplashConfig() async {
    try {
      // 실제로는 API나 로컬 저장소에서 설정을 가져올 수 있음
      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      const config = SplashEntity(
        logoPath: 'assets/icons/aipet_logo.png',
        animationDuration: Duration(milliseconds: 2000),
        displayDuration: Duration(seconds: 3),
        nextRoute: '/onboarding',
      );

      return const Success(config, 'スプラッシュ設定を取得しました');
    } catch (error) {
      return Failure(
        'スプラッシュ設定の取得に失敗しました: ${error.toString()}',
        exception: error is Exception ? error : Exception(error.toString()),
      );
    }
  }

  @override
  Future<Result<void>> initializeApp() async {
    try {
      // 앱 초기화 로직 (예: 설정 로드, 캐시 정리 등)
      await Future.delayed(const Duration(milliseconds: 200));
      return const Success(null, 'アプリ初期化が完了しました');
    } catch (error) {
      return Failure(
        'アプリ初期化に失敗しました: ${error.toString()}',
        exception: error is Exception ? error : Exception(error.toString()),
      );
    }
  }

  @override
  Stream<Result<SplashState>> executeSplashSequence() async* {
    try {
      // 1단계: 초기화 (로딩 애니메이션 준비)
      yield Success(SplashState.initializing(), 'スプラッシュ初期化中...');

      // 앱 초기화 작업 수행
      final initResult = await initializeApp();
      if (!initResult.isSuccess) {
        // 초기화 실패 시에도 시퀀스는 계속 진행
      }

      // 2단계: 로딩 애니메이션 표시 - 1.5초간 표시
      yield Success(SplashState.loading(), 'ローディングアニメーション表示中...');

      // 로딩 애니메이션 1.5초 대기
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3단계: 앱 로고 표시 - 무조건 2초간 표시 (회사 로고 포함)
      yield Success(
        SplashState.appLogo(AppConstants.splashAppLogoPath),
        'AI Petアプリロゴ表示中...',
      );

      // 앱 로고 2초 대기 (조건 없음, 무조건 대기)
      await Future.delayed(AppConstants.splashLogoDisplayDuration);

      // 4단계: 완료 - 온보딩으로 이동 준비
      yield Success(SplashState.completed(), 'スプラッシュシーケンス完了 - オンボーディングへ移動');
    } catch (error) {
      // 에러 발생 시에도 순차적 진행 보장
      // 로딩 애니메이션 1.5초
      yield Success(SplashState.loading(), 'ローディングアニメーション表示中... (エラー復旧)');
      await Future.delayed(const Duration(milliseconds: 1500));

      // 앱 로고 2초 (회사 로고 포함)
      yield Success(
        SplashState.appLogo(AppConstants.splashAppLogoPath),
        'AI Petアプリロゴ表示中... (エラー復旧)',
      );
      await Future.delayed(AppConstants.splashLogoDisplayDuration);

      // 최종 완료
      yield Success(SplashState.completed(), 'スプラッシュシーケンス完了 (エラー復旧)');
    }
  }

  @override
  Future<Result<String>> determineNextRoute() async {
    try {
      // 스플래시 이후 무조건 온보딩 화면으로 이동
      // 다른 조건이나 분기 없이 고정 경로 반환
      return const Success('/onboarding', 'オンボーディング画面へ移動');
    } catch (error) {
      return Failure(
        'ルート決定に失敗しました: ${error.toString()}',
        exception: error is Exception ? error : Exception(error.toString()),
      );
    }
  }
}
