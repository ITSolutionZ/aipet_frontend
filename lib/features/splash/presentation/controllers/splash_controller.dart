import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/splash/data/data.dart';
import 'package:aipet_frontend/features/splash/domain/domain.dart';
import 'package:aipet_frontend/shared/constants/splash_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 스플래시 화면 컨트롤러
///
/// 앱 시작 시 스플래시 시퀀스를 관리하고 다음 화면으로의 네비게이션을 처리합니다.
/// BaseController를 상속받아 에러 처리와 리소스 관리를 자동화합니다.
class SplashController extends BaseController {
  SplashController(super.ref);

  // ✅ Riverpod Provider를 통한 의존성 주입 (Mockito 데이터 사용)
  late final ManageSplashSequenceUseCase _manageSplashSequenceUseCase = ref.read(
    manageSplashSequenceUseCaseProvider,
  );
  late final GetSplashConfigUseCase _getSplashConfigUseCase = ref.read(
    getSplashConfigUseCaseProvider,
  );

  /// 스플래시 시퀀스 시작
  Stream<Result<SplashState>> startSplashSequence() {
    try {
      return _manageSplashSequenceUseCase.execute();
    } catch (error) {
      handleError(error);
      // 에러 발생 시에도 기본 시퀀스 제공
      return _getDefaultSplashSequence();
    }
  }

  /// 기본 스플래시 시퀀스 (에러 복구용)
  Stream<Result<SplashState>> _getDefaultSplashSequence() async* {
    yield Result.success('スプラッシュ初期化中...', SplashState.initializing());
    await Future.delayed(const Duration(milliseconds: 500));

    yield Result.success('ローディング中...', SplashState.loading());
    await Future.delayed(const Duration(milliseconds: 1500));

    yield Result.success('AI Petアプリロゴ表示中...', SplashState.appLogo(SplashConstants.logoImagePath));
    await Future.delayed(SplashConstants.splashDurationMs as Duration);

    yield Result.success('スプラッシュ完了', SplashState.completed());
  }

  /// 다음 화면 경로 결정
  Future<Result<String>> determineNextRoute() async {
    return await safeExecute(() async {
          final result = await _manageSplashSequenceUseCase.determineNextRoute();
          if (result.isSuccess) {
            // 성공 메시지는 필요시 UI에서 처리
          }
          return result;
        }) ??
        Result.success('オンボーディング画面へ移動', '/onboarding');
  }

  /// 스플래시 설정 로드
  Future<Result<SplashEntity>> loadSplashConfig() async {
    return await safeExecute(() async {
          final result = await _getSplashConfigUseCase.call();
          if (result.isSuccess) {
            // 성공 메시지는 필요시 UI에서 처리
          }
          return result;
        }) ??
        Result.success('デフォルト設定を使用します', SplashEntity.defaultConfig());
  }

  /// 스플래시 상태 업데이트
  void updateSplashState(SplashState newState) {
    try {
      ref.read(splashStateNotifierProvider.notifier).updateState(newState);
    } catch (error) {
      handleError(error);
    }
  }

  /// 스플래시 상태 초기화
  void resetSplashState() {
    try {
      ref.read(splashStateNotifierProvider.notifier).reset();
    } catch (error) {
      handleError(error);
    }
  }
}
