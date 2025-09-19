import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
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
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 스플래시 설정 로드
  Future<Result<SplashEntity>> loadSplashConfig() async {
    try {
      final result = await _getSplashConfigUseCase.call();
      return result;
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
