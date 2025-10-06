import 'package:aipet_frontend/shared/testing/mock_data/features/pet_health/pet_health_mock_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vaccine_provider.g.dart';

/// 펫별 접종 예정 백신 프로바이더
@riverpod
Future<List<Map<String, dynamic>>> scheduledVaccines(
  ScheduledVaccinesRef ref,
  String petId,
) async {
  // Mock 데이터 반환 (추후 API 연동 시 변경)
  await Future.delayed(const Duration(milliseconds: 100));
  return PetHealthMockService.getScheduledVaccines(petId);
}

/// 펫별 접종 완료 백신 프로바이더
@riverpod
Future<List<Map<String, dynamic>>> completedVaccines(
  CompletedVaccinesRef ref,
  String petId,
) async {
  // Mock 데이터 반환 (추후 API 연동 시 변경)
  await Future.delayed(const Duration(milliseconds: 100));
  return PetHealthMockService.getCompletedVaccines(petId);
}

/// 펫별 전체 백신 기록 프로바이더
@riverpod
Future<List<Map<String, dynamic>>> petVaccineRecords(
  PetVaccineRecordsRef ref,
  String petId,
) async {
  // Mock 데이터 반환 (추후 API 연동 시 변경)
  await Future.delayed(const Duration(milliseconds: 100));
  return PetHealthMockService.getMockVaccineRecordsByPetId(petId);
}
