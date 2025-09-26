import 'package:aipet_frontend/features/home/data/data.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_usecase_providers.g.dart';

/// Home Repository Provider
@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepositoryImpl();
}

/// GetDashboardDataUseCase Provider
@riverpod
GetDashboardDataUseCase getDashboardDataUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetDashboardDataUseCase(repository);
}

/// GetPetSummaryUseCase Provider
@riverpod
GetPetSummaryUseCase getPetSummaryUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetPetSummaryUseCase(repository);
}

/// GetWeatherDataUseCase Provider
@riverpod
GetWeatherDataUseCase getWeatherDataUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetWeatherDataUseCase(repository);
}

/// GetWalkSummaryUseCase Provider
@riverpod
GetWalkSummaryUseCase getWalkSummaryUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetWalkSummaryUseCase(repository);
}

/// GetHealthSummaryUseCase Provider
@riverpod
GetHealthSummaryUseCase getHealthSummaryUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHealthSummaryUseCase(repository);
}

/// GetAppointmentSummaryUseCase Provider
@riverpod
GetAppointmentSummaryUseCase getAppointmentSummaryUseCase(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetAppointmentSummaryUseCase(repository);
}
