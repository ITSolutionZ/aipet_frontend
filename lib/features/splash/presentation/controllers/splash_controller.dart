import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class SplashController extends BaseController {
  SplashController(super.ref);

  // UseCases
  late final ManageSplashSequenceUseCase _manageSplashSequenceUseCase =
      ManageSplashSequenceUseCase(ref.read(splashRepositoryProvider));
  late final GetSplashConfigUseCase _getSplashConfigUseCase =
      GetSplashConfigUseCase(ref.read(splashRepositoryProvider));

  /// 스플래시 시퀀스 시작
  Stream<SplashResult<SplashState>> startSplashSequence() {
    return _manageSplashSequenceUseCase.execute();
  }

  /// 다음 화면 경로 결정
  Future<SplashResult<String>> determineNextRoute() async {
    try {
      final result = await _manageSplashSequenceUseCase.determineNextRoute();
      return result;
    } catch (error) {
      handleError(error);
      return SplashResult.failure(
        getUserFriendlyErrorMessage(error),
        Exception(error.toString()),
      );
    }
  }

  /// 스플래시 설정 로드
  Future<SplashResult<SplashEntity>> loadSplashConfig() async {
    try {
      final splashConfig = await _getSplashConfigUseCase.call();
      return SplashResult.success('스플래시 설정이 로드되었습니다', splashConfig);
    } catch (error) {
      handleError(error);
      return SplashResult.failure(
        getUserFriendlyErrorMessage(error),
        Exception(error.toString()),
      );
    }
  }
}
