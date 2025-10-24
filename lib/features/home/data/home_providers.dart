import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repositories/home_repository_impl.dart';
import 'services/weather_service.dart';

part 'home_providers.g.dart';

/// Home Repository Provider
@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepositoryImpl();
}

/// Weather Service Provider
@riverpod
WeatherService weatherService(Ref ref) {
  return WeatherService();
}

/// Get Dashboard Data UseCase Provider
@riverpod
GetDashboardDataUseCase getDashboardDataUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetDashboardDataUseCase(repository);
}

/// Get Pet Summary UseCase Provider
@riverpod
GetPetSummaryUseCase getPetSummaryUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetPetSummaryUseCase(repository);
}

/// Get Weather Data UseCase Provider
@riverpod
GetWeatherDataUseCase getWeatherDataUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetWeatherDataUseCase(repository);
}

/// Home Dashboard Notifier Provider
@riverpod
class HomeDashboardNotifier extends _$HomeDashboardNotifier {
  @override
  Future<HomeDashboardEntity> build() async {
    try {
      final getDashboardDataUseCase = ref.read(getDashboardDataUseCaseProvider);

      LoggerService.debug('🔍 HomeDashboardNotifier: 대시보드 데이터 요청 시작');
      final result = await getDashboardDataUseCase.call();
      LoggerService.debug(
        '📊 HomeDashboardNotifier: UseCase 결과 - Success: ${result.isSuccess}',
      );

      if (result.isSuccess && result.dataOrNull != null) {
        LoggerService.debug('✅ HomeDashboardNotifier: 대시보드 데이터 로드 성공');
        return result.dataOrNull!;
      } else {
        LoggerService.debug(
          '❌ HomeDashboardNotifier: UseCase 실패 - ${result.error}',
        );
        throw Exception(
          '대시보드 데이터 로드 실패: ${result.error?.toString() ?? 'Unknown error'}',
        );
      }
    } catch (error, stackTrace) {
      LoggerService.debug('💥 HomeDashboardNotifier: 예외 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 실시간 GPS 위치로 날씨 새로고침
  Future<void> refreshWeatherWithGPS() async {
    // Provider가 dispose된 경우 바로 종료
    if (!ref.mounted) {
      LoggerService.debug(
        '⚠️ HomeDashboardNotifier: Provider disposed, skipping weather refresh',
      );
      return;
    }

    try {
      LoggerService.debug('🌍 실시간 GPS 위치로 날씨 새로고침 시작');
      final repository = ref.read(homeRepositoryProvider);

      // userTriggered=true로 캐시 무시하고 실제 GPS 위치 가져오기
      final weather = await repository.getCurrentWeather(userTriggered: true);

      // API 호출 후 다시 mounted 확인
      if (!ref.mounted) {
        LoggerService.debug(
          '⚠️ HomeDashboardNotifier: Provider disposed after API call',
        );
        return;
      }

      if (weather != null) {
        LoggerService.debug('✅ GPS 날씨 업데이트 성공: ${weather.location}');

        // 현재 대시보드 데이터를 가져와서 날씨만 업데이트
        final currentDashboard = await future;

        // 상태 업데이트 전 마지막 mounted 확인
        if (!ref.mounted) {
          LoggerService.debug(
            '⚠️ HomeDashboardNotifier: Provider disposed before state update',
          );
          return;
        }

        final updatedDashboard = HomeDashboardEntity(
          currentTime: currentDashboard.currentTime,
          weather: weather,
          petProfiles: currentDashboard.petProfiles,
          upcomingAppointments: currentDashboard.upcomingAppointments,
          petHealthSummary: currentDashboard.petHealthSummary,
          walkSummary: currentDashboard.walkSummary,
        );

        state = AsyncValue.data(updatedDashboard);
      }
    } catch (e) {
      LoggerService.debug('❌ GPS 날씨 새로고침 실패: $e');
    }
  }
}
