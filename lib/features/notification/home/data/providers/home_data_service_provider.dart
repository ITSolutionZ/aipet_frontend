import 'package:aipet_frontend/features/home/data/providers/home_usecase_providers.dart';
import 'package:aipet_frontend/features/home/presentation/services/home_data_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_data_service_provider.g.dart';

/// HomeDataService Provider
@riverpod
HomeDataService homeDataService(Ref ref) {
  return HomeDataService(
    getDashboardDataUseCase: ref.watch(getDashboardDataUseCaseProvider),
    getPetSummaryUseCase: ref.watch(getPetSummaryUseCaseProvider),
    getWeatherDataUseCase: ref.watch(getWeatherDataUseCaseProvider),
    getWalkSummaryUseCase: ref.watch(getWalkSummaryUseCaseProvider),
    getHealthSummaryUseCase: ref.watch(getHealthSummaryUseCaseProvider),
    getAppointmentSummaryUseCase: ref.watch(
      getAppointmentSummaryUseCaseProvider,
    ),
  );
}
