import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/onboarding/data/data.dart';
import 'package:aipet_frontend/features/onboarding/domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';

class SplashController extends BaseController {
  SplashController(super.ref);

  // UseCases
  late final ManageSplashSequenceUseCase _manageSplashSequenceUseCase =
      ManageSplashSequenceUseCase(ref.read(splashRepositoryProvider));
  late final GetSplashConfigUseCase _getSplashConfigUseCase =
      GetSplashConfigUseCase(ref.read(splashRepositoryProvider));

  /// 스플래시 시퀀스 시작
  Stream<Result<SplashState>> startSplashSequence() {
    return _manageSplashSequenceUseCase.execute();
  }

  /// 다음 화면 경로 결정
  Future<Result<String>> determineNextRoute() async {
    try {
      final result = await _manageSplashSequenceUseCase.determineNextRoute();
      return result;
    } catch (error) {
      handleError(error);
      return failure(
        'ルート決定に失敗しました',
        error is Exception ? error : Exception(error.toString()),
      );
    }
  }

  /// 스플래시 설정 로드
  Future<Result<SplashEntity>> loadSplashConfig() async {
    try {
      final result = await _getSplashConfigUseCase.call();
      return result;
    } catch (error) {
      handleError(error);
      return failure(
        '設定読み込みに失敗しました',
        error is Exception ? error : Exception(error.toString()),
      );
    }
  }
}
