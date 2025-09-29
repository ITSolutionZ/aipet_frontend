import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 스플래시 시퀀스 관리 UseCase
class ManageSplashSequenceUseCase {
  final SplashRepository repository;

  const ManageSplashSequenceUseCase(this.repository);

  /// 스플래시 시퀀스 실행 - 무조건 순차적 진행
  /// 1단계: 초기화 (Lottie 애니메이션) → 2단계: 로딩 1.5초 → 3단계: 앱로고 2초 (회사로고 포함) → 4단계: 완료
  Stream<Result<SplashState>> execute() async* {
    try {
      // Repository의 executeSplashSequence 메서드 사용
      yield* repository.executeSplashSequence();
    } catch (error) {
      // 에러 발생 시에도 순차적 진행 보장
      yield Result.success(
        'ローディングアニメーション表示中... (エラー復旧, SplashState.loading())',
      );
      await Future.delayed(const Duration(milliseconds: 1500));

      yield Result.success(
        'AI Petアプリロゴ表示中... (エラー復旧)',
        SplashState.appLogo('assets/icons/aipet_logo.png'),
      );
      await Future.delayed(const Duration(seconds: 2));

      yield Result.success('スプラッシュシーケンス完了 (エラー復旧)', SplashState.completed());
    }
  }

  /// 다음 화면 경로 결정 - 무조건 온보딩으로 이동
  Future<Result<String>> determineNextRoute() async {
    try {
      return await repository.determineNextRoute();
    } catch (error) {
      return Result.failure(
        'ルート決定に失敗しました: ${error.toString()}',
        error is Exception ? error : Exception(error.toString()),
      );
    }
  }
}
