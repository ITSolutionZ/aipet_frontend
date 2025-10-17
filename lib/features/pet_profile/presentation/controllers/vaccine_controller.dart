import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vaccine_controller.freezed.dart';
part 'vaccine_controller.g.dart';

/// 백신 관리 상태 관리
@riverpod
class VaccineController extends _$VaccineController {
  @override
  VaccineState build(String petId) {
    _loadVaccines(petId);
    return const VaccineState();
  }

  /// 백신 데이터 로드
  Future<void> _loadVaccines(String petId) async {
    // Mock 백신 데이터 (실제 구현에서는 API에서 가져올 것)
    await Future.delayed(const Duration(milliseconds: 500));

    final vaccines = [
      VaccineRecord(
        id: '1',
        name: '狂犬病ワクチン',
        description: '狂犬病を予防するための必須ワクチン',
        isCompleted: true,
        lastDate: DateTime(2024, 3, 15),
        nextDue: DateTime(2025, 3, 15),
        interval: '年1回',
        veterinarian: const VeterinarianInfo(
          name: '田中獣医師',
          clinic: 'ペットクリニック田中',
        ),
      ),
      VaccineRecord(
        id: '2',
        name: '混合ワクチン（5種）',
        description: 'ジステンパー、パルボウイルスなど5種混合',
        isCompleted: true,
        lastDate: DateTime(2024, 2, 10),
        nextDue: DateTime(2025, 2, 10),
        interval: '年1回',
        veterinarian: const VeterinarianInfo(
          name: '田中獣医師',
          clinic: 'ペットクリニック田中',
        ),
      ),
      VaccineRecord(
        id: '3',
        name: 'フィラリア予防薬',
        description: 'フィラリア症を予防するための薬剤',
        isCompleted: false,
        lastDate: DateTime(2024, 5, 1),
        nextDue: DateTime(2024, 6, 1),
        interval: '月1回（4-11月）',
        veterinarian: const VeterinarianInfo(
          name: '田中獣医師',
          clinic: 'ペットクリニック田中',
        ),
      ),
    ];

    state = state.copyWith(vaccines: vaccines, isLoading: false);
  }

  /// 새 백신 추가
  Future<void> addVaccine(VaccineRecord vaccine) async {
    state = state.copyWith(isLoading: true);

    // Mock API 호출
    await Future.delayed(const Duration(seconds: 1));

    final updatedVaccines = [...state.vaccines, vaccine];
    state = state.copyWith(vaccines: updatedVaccines, isLoading: false);
  }

  /// 백신 완료 상태 업데이트
  Future<void> updateVaccineStatus(String vaccineId, bool isCompleted) async {
    state = state.copyWith(isLoading: true);

    // Mock API 호출
    await Future.delayed(const Duration(milliseconds: 500));

    final updatedVaccines = state.vaccines.map((vaccine) {
      if (vaccine.id == vaccineId) {
        return vaccine.copyWith(isCompleted: isCompleted);
      }
      return vaccine;
    }).toList();

    state = state.copyWith(vaccines: updatedVaccines, isLoading: false);
  }

  /// 백신 삭제
  Future<void> deleteVaccine(String vaccineId) async {
    state = state.copyWith(isLoading: true);

    // Mock API 호출
    await Future.delayed(const Duration(milliseconds: 500));

    final updatedVaccines = state.vaccines
        .where((v) => v.id != vaccineId)
        .toList();
    state = state.copyWith(vaccines: updatedVaccines, isLoading: false);
  }
}

/// 백신 관리 상태
@freezed
abstract class VaccineState with _$VaccineState {
  const factory VaccineState({
    @Default([]) List<VaccineRecord> vaccines,
    @Default(true) bool isLoading,
    String? error,
  }) = _VaccineState;

  const VaccineState._();
}

/// 백신 기록 엔티티
@freezed
abstract class VaccineRecord with _$VaccineRecord {
  const factory VaccineRecord({
    required String id,
    required String name,
    required String description,
    required bool isCompleted,
    required DateTime lastDate,
    required DateTime nextDue,
    required String interval,
    required VeterinarianInfo veterinarian,
  }) = _VaccineRecord;
}

/// 수의사 정보
@freezed
abstract class VeterinarianInfo with _$VeterinarianInfo {
  const factory VeterinarianInfo({
    required String name,
    required String clinic,
  }) = _VeterinarianInfo;
}
