import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/home/data/data.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';

class HomeDashboardController extends BaseController {
  HomeDashboardController(super.ref);

  // Repository 및 UseCase 인스턴스
  late final HomeRepository _repository = HomeRepositoryImpl();
  late final GetDashboardDataUseCase _getDashboardDataUseCase =
      GetDashboardDataUseCase(_repository);
  late final GetPetSummaryUseCase _getPetSummaryUseCase = GetPetSummaryUseCase(
    _repository,
  );
  late final GetWeatherDataUseCase _getWeatherDataUseCase =
      GetWeatherDataUseCase(_repository);

  /// 홈 화면 초기화
  Future<Result<HomeDashboardEntity>> initializeHome() async {
    try {
      final dashboardData = await _getDashboardDataUseCase.call();
      return Result.success('ホーム画面がロードされました', dashboardData);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 펫 목록 확인
  Future<Result<bool>> hasPets() async {
    try {
      final petSummaries = await _getPetSummaryUseCase.call();
      return Result.success('ペットリストの確認が完了しました', petSummaries.isNotEmpty);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 날씨 정보 로드
  /// [userTriggered] 사용자가 직접 요청한 경우 true
  Future<Result<WeatherEntity>> loadWeatherInfo({
    bool userTriggered = false,
  }) async {
    try {
      final weather = await _getWeatherDataUseCase.call(
        userTriggered: userTriggered,
      );
      return Result.success('天気情報がロードされました', weather);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 정보 로드
  Future<Result<WalkSummary>> loadWalkInfo() async {
    try {
      final walkSummary = await _repository.getWalkSummary();
      return Result.success('散歩情報がロードされました', walkSummary);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 건강 정보 로드
  Future<Result<HealthSummary>> loadHealthInfo() async {
    try {
      final healthSummary = await _repository.getPetHealthSummary();
      return Result.success('健康情報がロードされました', healthSummary);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 예약 정보 로드
  Future<Result<List<AppointmentSummary>>> loadAppointmentInfo() async {
    try {
      final appointments = await _repository.getUpcomingAppointments();
      return Result.success('予約情報がロードされました', appointments);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 프로필 업데이트
  Future<Result<Map<String, dynamic>>> updateProfile() async {
    try {
      // 펫 프로필 정보를 다시 로드하여 최신 상태로 업데이트
      final petSummaries = await _getPetSummaryUseCase.call();
      final dashboardData = await _getDashboardDataUseCase.call();

      final result = {
        'pets': petSummaries,
        'dashboard': dashboardData,
        'petCount': petSummaries.length,
      };

      return Result.success('プロフィールが更新されました', result);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
