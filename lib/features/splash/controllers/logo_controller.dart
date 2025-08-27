import '../../../app/controllers/base_controller.dart';
import '../data/repositories/logo_repository_impl.dart';
import '../domain/domain.dart';

class LogoController extends BaseController {
  LogoController(super.ref);

  // Repository 및 UseCase 인스턴스
  late final LogoRepository _repository = LogoRepositoryImpl();
  late final GetLogoConfigUseCase _getLogoConfigUseCase = GetLogoConfigUseCase(
    _repository,
  );

  /// 로고 설정 로드
  Future<LogoResult> loadLogoConfig() async {
    try {
      final logoConfig = await _getLogoConfigUseCase.call();
      return LogoResult.success('로고 설정이 로드되었습니다', logoConfig);
    } catch (error) {
      handleError(error);
      return LogoResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 회사 로고 이미지 로드
  Future<LogoResult> loadCompanyLogo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      const imagePath = 'assets/icons/itz.png';
      return LogoResult.success('회사 로고를 로드했습니다', imagePath);
    } catch (error) {
      handleError(error);
      return LogoResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 로고 이미지 로드
  Future<LogoResult> loadAppLogo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      const imagePath = 'assets/icons/aipet_logo.png';
      return LogoResult.success('앱 로고를 로드했습니다', imagePath);
    } catch (error) {
      handleError(error);
      return LogoResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 로고 이미지 로드 (기본 - 앱 로고 반환)
  Future<LogoResult> loadLogoImage() async {
    return loadAppLogo();
  }

  /// 순차적 로고 표시 (회사 로고 3초 → 앱 로고 3초)
  Stream<LogoResult> loadLogosSequentially() async* {
    try {
      // 1단계: 회사 로고 표시 (3초)
      yield LogoResult.success('회사 로고 표시 중...', {
        'type': 'company',
        'imagePath': 'assets/icons/itz.png',
        'phase': 1,
        'totalPhases': 2,
      });

      await Future.delayed(const Duration(seconds: 3));

      // 2단계: 앱 로고 표시 (3초)
      yield LogoResult.success('앱 로고 표시 중...', {
        'type': 'app',
        'imagePath': 'assets/icons/aipet_logo.png',
        'phase': 2,
        'totalPhases': 2,
      });

      await Future.delayed(const Duration(seconds: 3));

      // 완료
      yield LogoResult.success('로고 표시 완료', {
        'type': 'completed',
        'imagePath': 'assets/icons/aipet_logo.png',
        'phase': 2,
        'totalPhases': 2,
      });
    } catch (error) {
      handleError(error);
      yield LogoResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}

class LogoResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const LogoResult._(this.isSuccess, this.message, this.data);

  factory LogoResult.success(String message, [dynamic data]) =>
      LogoResult._(true, message, data);
  factory LogoResult.failure(String message) =>
      LogoResult._(false, message, null);
}
