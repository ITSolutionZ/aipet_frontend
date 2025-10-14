import 'package:aipet_frontend/features/pet_health/data/services/pet_health_local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vaccine_provider.g.dart';

/// 펫별 접종 예정 백신 프로바이더
@riverpod
Future<List<Map<String, dynamic>>> scheduledVaccines(
  ScheduledVaccinesRef ref,
  String petId,
) async {
  // 로컬 저장소에서 백신 기록 조회
  final allVaccines = await PetHealthLocalStorageService.getVaccineRecords();

  // 해당 펫의 예정된 백신만 필터링 (아직 접종하지 않은 백신)
  final now = DateTime.now();
  final scheduledVaccines = allVaccines.where((vaccine) {
    final petIdMatch = vaccine['petId'] == petId;
    final vaccinatedDate = vaccine['vaccinatedDate'] as DateTime?;
    final nextDueDate = vaccine['nextDueDate'] as DateTime?;

    // vaccinatedDate가 null이고 nextDueDate가 미래인 경우
    return petIdMatch &&
        vaccinatedDate == null &&
        (nextDueDate?.isAfter(now) ?? false);
  }).toList();

  return scheduledVaccines;
}

/// 펫별 접종 완료 백신 프로바이더
@riverpod
Future<List<Map<String, dynamic>>> completedVaccines(
  CompletedVaccinesRef ref,
  String petId,
) async {
  // 로컬 저장소에서 백신 기록 조회
  final allVaccines = await PetHealthLocalStorageService.getVaccineRecords();

  // 해당 펫의 완료된 백신만 필터링 (vaccinatedDate가 있는 백신)
  final completedVaccines = allVaccines.where((vaccine) {
    final petIdMatch = vaccine['petId'] == petId;
    final vaccinatedDate = vaccine['vaccinatedDate'] as DateTime?;
    return petIdMatch && vaccinatedDate != null;
  }).toList();

  return completedVaccines;
}

/// 펫별 전체 백신 기록 프로바이더
@riverpod
Future<List<Map<String, dynamic>>> petVaccineRecords(
  PetVaccineRecordsRef ref,
  String petId,
) async {
  // 로컬 저장소에서 해당 펫의 모든 백신 기록 조회
  final allVaccines = await PetHealthLocalStorageService.getVaccineRecords();
  final petVaccines = allVaccines
      .where((vaccine) => vaccine['petId'] == petId)
      .toList();

  return petVaccines;
}
