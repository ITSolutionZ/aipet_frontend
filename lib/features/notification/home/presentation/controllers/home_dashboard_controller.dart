import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/home/data/data.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/shared/core/services/error_handling_service.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart'
    as app_result;

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
  Future<app_result.Result<HomeDashboardEntity>> initializeHome() async {
    return await ErrorHandlingService.handleAsync(
          _getDashboardDataUseCase.call(),
          context: '홈 화면 초기화',
        ) ??
        app_result.ResultFactory.failure('홈 화면 초기화에 실패했습니다');
  }

  /// 펫 목록 확인
  Future<app_result.Result<bool>> hasPets() async {
    final result = await ErrorHandlingService.handleAsync(
      _getPetSummaryUseCase.call(),
      context: '펫 목록 확인',
    );

    if (result == null || result.isFailure) {
      return app_result.ResultFactory.failure(
        result?.errorOrNull ?? '펫 목록 확인에 실패했습니다',
      );
    }

    final petSummaries = result.dataOrNull ?? [];
    return app_result.ResultFactory.success(
      petSummaries.isNotEmpty,
      'ペットリストの確認が完了しました',
    );
  }

  /// 날씨 정보 로드
  /// [userTriggered] 사용자가 직접 요청한 경우 true
  Future<app_result.Result<WeatherEntity?>> loadWeatherInfo({
    bool userTriggered = false,
  }) async {
    try {
      final result = await _getWeatherDataUseCase.call(
        userTriggered: userTriggered,
      );

      if (result.isFailure) {
        return app_result.ResultFactory.failure(
          result.errorOrNull ?? '날씨 정보 로드에 실패했습니다',
        );
      }

      return app_result.ResultFactory.success(
        result.dataOrNull,
        '天気情報がロードされました',
      );
    } catch (error) {
      handleError(error);
      return app_result.ResultFactory.failure(
        getUserFriendlyErrorMessage(error),
      );
    }
  }

  /// 산책 정보 로드
  Future<app_result.Result<WalkSummary>> loadWalkInfo() async {
    final walkSummary = await ErrorHandlingService.handleAsync(
      _repository.getWalkSummary(),
      context: '산책 정보 로드',
    );

    if (walkSummary == null) {
      return app_result.ResultFactory.failure('산책 정보 로드에 실패했습니다');
    }

    return app_result.ResultFactory.success(walkSummary, '散歩情報がロードされました');
  }

  /// 건강 정보 로드
  Future<app_result.Result<HealthSummary>> loadHealthInfo() async {
    final healthSummary = await ErrorHandlingService.handleAsync(
      _repository.getPetHealthSummary(),
      context: '건강 정보 로드',
    );

    if (healthSummary == null) {
      return app_result.ResultFactory.failure('건강 정보 로드에 실패했습니다');
    }

    return app_result.ResultFactory.success(healthSummary, '健康情報がロードされました');
  }

  /// 예약 정보 로드
  Future<app_result.Result<List<AppointmentSummary>>>
  loadAppointmentInfo() async {
    final appointments = await ErrorHandlingService.handleAsync(
      _repository.getUpcomingAppointments(),
      context: '예약 정보 로드',
    );

    if (appointments == null) {
      return app_result.ResultFactory.failure('예약 정보 로드에 실패했습니다');
    }

    return app_result.ResultFactory.success(appointments, '予約情報がロードされました');
  }

  /// 프로필 업데이트
  Future<app_result.Result<Map<String, dynamic>>> updateProfile() async {
    final petsResult = await ErrorHandlingService.handleAsync(
      _getPetSummaryUseCase.call(),
      context: '펫 정보 조회',
    );

    if (petsResult == null || petsResult.isFailure) {
      return app_result.ResultFactory.failure(
        petsResult?.errorOrNull ?? '펫 정보 조회에 실패했습니다',
      );
    }

    final dashboardResult = await ErrorHandlingService.handleAsync(
      _getDashboardDataUseCase.call(),
      context: '대시보드 데이터 조회',
    );

    if (dashboardResult == null || dashboardResult.isFailure) {
      return app_result.ResultFactory.failure(
        dashboardResult?.errorOrNull ?? '대시보드 데이터 조회에 실패했습니다',
      );
    }

    final petSummaries = petsResult.dataOrNull ?? [];
    final dashboardData = dashboardResult.dataOrNull;

    final result = {
      'pets': petSummaries,
      'dashboard': dashboardData,
      'petCount': petSummaries.length,
    };

    return app_result.ResultFactory.success(result, 'プロフィールが更新されました');
  }
}
