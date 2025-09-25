import 'package:aipet_frontend/features/home/data/providers/home_data_service_provider.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/features/home/presentation/services/home_data_service.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart'
    as app_result;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_home_dashboard_controller.g.dart';

/// Riverpod 기반 홈 대시보드 컨트롤러
@riverpod
class RiverpodHomeDashboardController
    extends _$RiverpodHomeDashboardController {
  @override
  HomeDataService build() {
    return ref.watch(homeDataServiceProvider);
  }

  /// 홈 화면 초기화
  Future<app_result.Result<HomeDashboardEntity>> initializeHome() async {
    return state.initializeHome();
  }

  /// 펫 목록 확인
  Future<app_result.Result<bool>> hasPets() async {
    return state.hasPets();
  }

  /// 날씨 정보 로드
  Future<app_result.Result<WeatherEntity?>> loadWeatherInfo({
    bool userTriggered = false,
  }) async {
    return state.loadWeatherInfo(userTriggered: userTriggered);
  }

  /// 산책 정보 로드
  Future<app_result.Result<WalkSummary>> loadWalkInfo() async {
    return state.loadWalkInfo();
  }

  /// 건강 정보 로드
  Future<app_result.Result<HealthSummary>> loadHealthInfo() async {
    return state.loadHealthInfo();
  }

  /// 예약 정보 로드
  Future<app_result.Result<List<AppointmentSummary>>>
  loadAppointmentInfo() async {
    return state.loadAppointmentInfo();
  }

  /// 프로필 업데이트
  Future<app_result.Result<Map<String, dynamic>>> updateProfile() async {
    return state.updateProfile();
  }

  /// 통합 데이터 로드 (모든 정보를 한 번에)
  Future<app_result.Result<Map<String, dynamic>>> loadAllData({
    bool userTriggered = false,
  }) async {
    return state.loadAllData(userTriggered: userTriggered);
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
        final weatherResult = await state.loadWeatherInfo(
          userTriggered: userTriggered,
        );
        if (weatherResult.isSuccess) {
          results['weather'] = weatherResult.dataOrNull;
        }
      }

      if (loadPets) {
        final petsResult = await state.hasPets();
        if (petsResult.isSuccess) {
          results['hasPets'] = petsResult.dataOrNull;
        }
      }

      if (loadWalk) {
        final walkResult = await state.loadWalkInfo();
        if (walkResult.isSuccess) {
          results['walk'] = walkResult.dataOrNull;
        }
      }

      if (loadHealth) {
        final healthResult = await state.loadHealthInfo();
        if (healthResult.isSuccess) {
          results['health'] = healthResult.dataOrNull;
        }
      }

      if (loadAppointments) {
        final appointmentResult = await state.loadAppointmentInfo();
        if (appointmentResult.isSuccess) {
          results['appointments'] = appointmentResult.dataOrNull;
        }
      }

      return app_result.ResultFactory.success(
        results,
        '선택된 데이터가 성공적으로 로드되었습니다',
      );
    } catch (error) {
      return app_result.ResultFactory.failure(
        '데이터 로드 중 오류가 발생했습니다: ${error.toString()}',
      );
    }
  }
}
