import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/home/data/data.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/features/home/presentation/services/home_data_service.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart'
    as app_result;

/// 리팩토링된 홈 대시보드 컨트롤러
///
/// HomeDataService를 사용하여 중복 코드를 제거하고
/// 일관된 에러 처리와 결과 반환을 제공합니다.
class RefactoredHomeDashboardController extends BaseController {
  final HomeDataService _dataService;

  RefactoredHomeDashboardController(
    super.ref, {
    HomeRepository? repository,
    GetDashboardDataUseCase? getDashboardDataUseCase,
    GetPetSummaryUseCase? getPetSummaryUseCase,
    GetWeatherDataUseCase? getWeatherDataUseCase,
    GetWalkSummaryUseCase? getWalkSummaryUseCase,
    GetHealthSummaryUseCase? getHealthSummaryUseCase,
    GetAppointmentSummaryUseCase? getAppointmentSummaryUseCase,
  }) : _dataService = HomeDataService(
         getDashboardDataUseCase:
             getDashboardDataUseCase ??
             GetDashboardDataUseCase(repository ?? HomeRepositoryImpl()),
         getPetSummaryUseCase:
             getPetSummaryUseCase ??
             GetPetSummaryUseCase(repository ?? HomeRepositoryImpl()),
         getWeatherDataUseCase:
             getWeatherDataUseCase ??
             GetWeatherDataUseCase(repository ?? HomeRepositoryImpl()),
         getWalkSummaryUseCase:
             getWalkSummaryUseCase ??
             GetWalkSummaryUseCase(repository ?? HomeRepositoryImpl()),
         getHealthSummaryUseCase:
             getHealthSummaryUseCase ??
             GetHealthSummaryUseCase(repository ?? HomeRepositoryImpl()),
         getAppointmentSummaryUseCase:
             getAppointmentSummaryUseCase ??
             GetAppointmentSummaryUseCase(repository ?? HomeRepositoryImpl()),
       );

  /// 홈 화면 초기화
  Future<app_result.Result<HomeDashboardEntity>> initializeHome() async {
    return _dataService.initializeHome();
  }

  /// 펫 목록 확인
  Future<app_result.Result<bool>> hasPets() async {
    return _dataService.hasPets();
  }

  /// 날씨 정보 로드
  Future<app_result.Result<WeatherEntity?>> loadWeatherInfo({
    bool userTriggered = false,
  }) async {
    return _dataService.loadWeatherInfo(userTriggered: userTriggered);
  }

  /// 산책 정보 로드
  Future<app_result.Result<WalkSummary>> loadWalkInfo() async {
    return _dataService.loadWalkInfo();
  }

  /// 건강 정보 로드
  Future<app_result.Result<HealthSummary>> loadHealthInfo() async {
    return _dataService.loadHealthInfo();
  }

  /// 예약 정보 로드
  Future<app_result.Result<List<AppointmentSummary>>>
  loadAppointmentInfo() async {
    return _dataService.loadAppointmentInfo();
  }

  /// 프로필 업데이트
  Future<app_result.Result<Map<String, dynamic>>> updateProfile() async {
    return _dataService.updateProfile();
  }

  /// 통합 데이터 로드 (모든 정보를 한 번에)
  Future<app_result.Result<Map<String, dynamic>>> loadAllData({
    bool userTriggered = false,
  }) async {
    return _dataService.loadAllData(userTriggered: userTriggered);
  }

  /// 특정 데이터만 로드 (선택적 로딩)
  Future<app_result.Result<Map<String, dynamic>>> loadSpecificData({
    bool loadWeather = true,
    bool loadPets = true,
    bool loadWalk = true,
    bool loadHealth = true,
    bool loadAppointments = true,
    bool userTriggered = false,
  }) async {
    try {
      final results = <String, dynamic>{};

      if (loadWeather) {
        final weatherResult = await _dataService.loadWeatherInfo(
          userTriggered: userTriggered,
        );
        if (weatherResult.isSuccess) {
          results['weather'] = weatherResult.dataOrNull;
        }
      }

      if (loadPets) {
        final petsResult = await _dataService.hasPets();
        if (petsResult.isSuccess) {
          results['hasPets'] = petsResult.dataOrNull;
        }
      }

      if (loadWalk) {
        final walkResult = await _dataService.loadWalkInfo();
        if (walkResult.isSuccess) {
          results['walk'] = walkResult.dataOrNull;
        }
      }

      if (loadHealth) {
        final healthResult = await _dataService.loadHealthInfo();
        if (healthResult.isSuccess) {
          results['health'] = healthResult.dataOrNull;
        }
      }

      if (loadAppointments) {
        final appointmentResult = await _dataService.loadAppointmentInfo();
        if (appointmentResult.isSuccess) {
          results['appointments'] = appointmentResult.dataOrNull;
        }
      }

      return app_result.ResultFactory.success(
        results,
        '선택된 데이터가 성공적으로 로드되었습니다',
      );
    } catch (error) {
      handleError(error);
      return app_result.ResultFactory.failure(
        getUserFriendlyErrorMessage(error),
      );
    }
  }
}
