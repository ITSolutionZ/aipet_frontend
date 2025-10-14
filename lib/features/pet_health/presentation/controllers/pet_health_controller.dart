import 'package:aipet_frontend/features/pet_health/data/services/pet_health_local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 건강 컨트롤러
class PetHealthController extends StateNotifier<PetHealthState> {
  PetHealthController() : super(const PetHealthState());

  /// 건강 기록 로드
  Future<void> loadHealthRecords(String petId) async {
    final vaccineRecords = await PetHealthLocalStorageService.getVaccineRecords(
      petId: petId,
    );
    final weightRecords = await PetHealthLocalStorageService.getWeightRecords(
      petId: petId,
    );

    final healthData = {'vaccines': vaccineRecords, 'weights': weightRecords};

    state = state.copyWith(petId: petId, healthRecords: [healthData]);
  }

  /// 건강 기록 추가
  void addHealthRecord(Map<String, dynamic> record) {
    final newRecords = List<Map<String, dynamic>>.from(state.healthRecords);
    newRecords.add(record);
    state = state.copyWith(healthRecords: newRecords);
  }

  /// 건강 기록 삭제
  void deleteHealthRecord(String recordId) {
    final newRecords = state.healthRecords
        .where((record) => record['id'] != recordId)
        .toList();
    state = state.copyWith(healthRecords: newRecords);
  }
}

/// 펫 건강 상태
class PetHealthState {
  final String petId;
  final List<Map<String, dynamic>> healthRecords;

  const PetHealthState({this.petId = '', this.healthRecords = const []});

  PetHealthState copyWith({
    String? petId,
    List<Map<String, dynamic>>? healthRecords,
  }) {
    return PetHealthState(
      petId: petId ?? this.petId,
      healthRecords: healthRecords ?? this.healthRecords,
    );
  }
}

/// 컨트롤러 프로바이더
final petHealthControllerProvider =
    StateNotifierProvider<PetHealthController, PetHealthState>((ref) {
      return PetHealthController();
    });
