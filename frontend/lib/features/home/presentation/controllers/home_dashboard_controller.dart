import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class HomeDashboardController extends BaseController {
  final HomeRepository _repository;
  final GetDashboardDataUseCase _getDashboardDataUseCase;
  final GetPetSummaryUseCase _getPetSummaryUseCase;
  final GetWeatherDataUseCase _getWeatherDataUseCase;

  HomeDashboardController(
    super.ref, {
    HomeRepository? repository,
    GetDashboardDataUseCase? getDashboardDataUseCase,
    GetPetSummaryUseCase? getPetSummaryUseCase,
    GetWeatherDataUseCase? getWeatherDataUseCase,
  }) : _repository = repository ?? HomeRepositoryImpl(),
       _getDashboardDataUseCase =
           getDashboardDataUseCase ??
           GetDashboardDataUseCase(repository ?? HomeRepositoryImpl()),
       _getPetSummaryUseCase =
           getPetSummaryUseCase ??
           GetPetSummaryUseCase(repository ?? HomeRepositoryImpl()),
       _getWeatherDataUseCase =
           getWeatherDataUseCase ??
           GetWeatherDataUseCase(repository ?? HomeRepositoryImpl());

  /// 홈 화면 초기화
  Future<Result<HomeDashboardEntity>> initializeHome() async {
    try {
      final dashboard = await _getDashboardDataUseCase.call();
      return Result.success('홈 화면 초기화가 완료되었습니다', dashboard.data);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 펫 목록 확인
  Future<Result<bool>> hasPets() async {
    try {
      final petSummaries = await _getPetSummaryUseCase.call();
      final hasPetsData = petSummaries.data?.isNotEmpty ?? false;
      return Result.success('ペットリストの確認が完了しました', hasPetsData);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 날씨 정보 로드
  /// [userTriggered] 사용자가 직접 요청한 경우 true
  Future<Result<WeatherEntity?>> loadWeatherInfo({
    bool userTriggered = false,
  }) async {
    try {
      final weather = await _getWeatherDataUseCase.call(
        userTriggered: userTriggered,
      );

      return Result.success('天気情報がロードされました', weather.data);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 정보 로드
  Future<Result<WalkSummary>> loadWalkInfo() async {
    final walkSummary = await ErrorHandlingService.handleAsync(
      _repository.getWalkSummary(),
      context: '산책 정보 로드',
    );

    if (walkSummary == null) {
      return Result.failure('산책 정보 로드에 실패했습니다');
    }

    return Result.success('散歩情報がロードされました', walkSummary);
  }

  /// 건강 정보 로드
  Future<Result<HealthSummary>> loadHealthInfo() async {
    final healthSummary = await ErrorHandlingService.handleAsync(
      _repository.getPetHealthSummary(),
      context: '건강 정보 로드',
    );

    if (healthSummary == null) {
      return Result.failure('건강 정보 로드에 실패했습니다');
    }

    return Result.success('健康情報がロードされました', healthSummary);
  }

  /// 예약 정보 로드
  Future<Result<List<AppointmentSummary>>> loadAppointmentInfo() async {
    final appointments = await ErrorHandlingService.handleAsync(
      _repository.getUpcomingAppointments(),
      context: '예약 정보 로드',
    );

    if (appointments == null) {
      return Result.failure('예약 정보 로드에 실패했습니다');
    }

    return Result.success('予約情報がロードされました', appointments);
  }

  /// 프로필 업데이트
  Future<Result<Map<String, dynamic>>> updateProfile() async {
    try {
      final petSummaries = await _getPetSummaryUseCase.call();
      final dashboardData = await _getDashboardDataUseCase.call();

      final result = {
        'pets': petSummaries.data,
        'dashboard': dashboardData.data,
        'petCount': petSummaries.data?.length ?? 0,
      };

      return Result.success('プロフィールが更新されました', result);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
