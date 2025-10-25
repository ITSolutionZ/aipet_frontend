import 'package:aipet_frontend/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'pet_health_state.dart';

part 'pet_health_controller.g.dart';

/// Pet Health Tab 컨트롤러
///
/// 건강 정보 CRUD 작업을 관리합니다.
@riverpod
class PetHealthController extends _$PetHealthController {
  static const _uuid = Uuid();

  @override
  PetHealthState build(String tabId) {
    return const PetHealthState();
  }

  /// 펫 정보로 초기화
  void initialize(PetProfileEntity pet) {
    LoggerService.debug('🏥 PetHealthController: 초기화 시작');

    final additionalInfo = pet.additionalInfo ?? {};

    // 예방접종 기록 로드
    final vaccinationData =
        additionalInfo['vaccinationRecords'] as List<dynamic>?;
    final vaccinationRecords = vaccinationData
            ?.map((e) => VaccinationRecord.fromMap(e as Map<String, dynamic>))
            .toList() ??
        _getDefaultVaccinationRecords();

    // 진료 기록 로드
    final medicalData = additionalInfo['medicalRecords'] as List<dynamic>?;
    final medicalRecords = medicalData
            ?.map((e) => MedicalRecord.fromMap(e as Map<String, dynamic>))
            .toList() ??
        _getDefaultMedicalRecords();

    // 예약/스케줄 로드
    final appointmentData = additionalInfo['appointments'] as List<dynamic>?;
    final appointments = appointmentData
            ?.map((e) => AppointmentRecord.fromMap(e as Map<String, dynamic>))
            .toList() ??
        _getDefaultAppointments();

    // 체중 정보 로드
    final idealWeight = additionalInfo['idealWeight'] as double?;

    state = state.copyWith(
      vaccinationRecords: vaccinationRecords,
      medicalRecords: medicalRecords,
      appointments: appointments,
      currentWeight: pet.weight,
      idealWeight: idealWeight ?? pet.weight + 0.5,
    );

    LoggerService.debug(
      '✅ PetHealthController: 초기화 완료 - 예방접종: ${vaccinationRecords.length}, 진료: ${medicalRecords.length}, 예약: ${appointments.length}',
    );
  }

  // ==================== 예방접종 기록 CRUD ====================

  /// 예방접종 기록 추가
  void addVaccinationRecord(VaccinationRecord record) {
    final updated = [...state.vaccinationRecords, record];
    state = state.copyWith(vaccinationRecords: updated);
    LoggerService.debug('✅ 예방접종 기록 추가: ${record.name}');
  }

  /// 예방접종 기록 업데이트
  void updateVaccinationRecord(String id, VaccinationRecord updated) {
    final updatedList = state.vaccinationRecords.map((record) {
      return record.id == id ? updated : record;
    }).toList();
    state = state.copyWith(vaccinationRecords: updatedList);
    LoggerService.debug('✅ 예방접종 기록 업데이트: ${updated.name}');
  }

  /// 예방접종 기록 삭제
  void deleteVaccinationRecord(String id) {
    final updated =
        state.vaccinationRecords.where((record) => record.id != id).toList();
    state = state.copyWith(vaccinationRecords: updated);
    LoggerService.debug('✅ 예방접종 기록 삭제: $id');
  }

  // ==================== 진료 기록 CRUD ====================

  /// 진료 기록 추가
  void addMedicalRecord(MedicalRecord record) {
    final updated = [...state.medicalRecords, record];
    state = state.copyWith(medicalRecords: updated);
    LoggerService.debug('✅ 진료 기록 추가: ${record.title}');
  }

  /// 진료 기록 업데이트
  void updateMedicalRecord(String id, MedicalRecord updated) {
    final updatedList = state.medicalRecords.map((record) {
      return record.id == id ? updated : record;
    }).toList();
    state = state.copyWith(medicalRecords: updatedList);
    LoggerService.debug('✅ 진료 기록 업데이트: ${updated.title}');
  }

  /// 진료 기록 삭제
  void deleteMedicalRecord(String id) {
    final updated =
        state.medicalRecords.where((record) => record.id != id).toList();
    state = state.copyWith(medicalRecords: updated);
    LoggerService.debug('✅ 진료 기록 삭제: $id');
  }

  // ==================== 예약/스케줄 CRUD ====================

  /// 예약 추가
  void addAppointment(AppointmentRecord record) {
    final updated = [...state.appointments, record];
    state = state.copyWith(appointments: updated);
    LoggerService.debug('✅ 예약 추가: ${record.title}');
  }

  /// 예약 업데이트
  void updateAppointment(String id, AppointmentRecord updated) {
    final updatedList = state.appointments.map((record) {
      return record.id == id ? updated : record;
    }).toList();
    state = state.copyWith(appointments: updatedList);
    LoggerService.debug('✅ 예약 업데이트: ${updated.title}');
  }

  /// 예약 삭제
  void deleteAppointment(String id) {
    final updated =
        state.appointments.where((record) => record.id != id).toList();
    state = state.copyWith(appointments: updated);
    LoggerService.debug('✅ 예약 삭제: $id');
  }

  // ==================== 체중 관리 ====================

  /// 현재 체중 업데이트
  void updateCurrentWeight(double weight) {
    state = state.copyWith(currentWeight: weight);
    LoggerService.debug('✅ 현재 체중 업데이트: $weight kg');
  }

  /// 이상 체중 업데이트
  void updateIdealWeight(double weight) {
    state = state.copyWith(idealWeight: weight);
    LoggerService.debug('✅ 이상 체중 업데이트: $weight kg');
  }

  // ==================== 데이터 변환 ====================

  /// 변경사항을 Map으로 변환 (저장용)
  Map<String, dynamic> getChanges() {
    return {
      'vaccinationRecords':
          state.vaccinationRecords.map((e) => e.toMap()).toList(),
      'medicalRecords': state.medicalRecords.map((e) => e.toMap()).toList(),
      'appointments': state.appointments.map((e) => e.toMap()).toList(),
      'idealWeight': state.idealWeight,
    };
  }

  /// 상태 초기화
  void reset() {
    state = const PetHealthState();
  }

  // ==================== 기본 데이터 ====================

  /// 기본 예방접종 기록 (저장된 데이터가 없을 때)
  List<VaccinationRecord> _getDefaultVaccinationRecords() {
    return [
      VaccinationRecord(
        id: _uuid.v4(),
        name: 'コアワクチン',
        status: '接種中', // 次回接種日があるため「接種中」
        lastDate: DateTime(2024, 3, 15),
        nextDate: DateTime(2025, 3, 15),
        iconName: 'vaccines',
        colorName: 'green',
        history: [
          VaccinationHistory(
            id: _uuid.v4(),
            round: 1,
            date: DateTime(2023, 3, 15),
            memo: '初回接種完了',
          ),
          VaccinationHistory(
            id: _uuid.v4(),
            round: 2,
            date: DateTime(2024, 3, 15),
            memo: '2回目接種完了',
          ),
        ],
      ),
      VaccinationRecord(
        id: _uuid.v4(),
        name: '狂犬病予防接種',
        status: '接種中', // 次回接種日があるため「接種中」
        lastDate: DateTime(2024, 4, 10),
        nextDate: DateTime(2025, 4, 10),
        iconName: 'healing',
        colorName: 'blue',
        history: [
          VaccinationHistory(
            id: _uuid.v4(),
            round: 1,
            date: DateTime(2023, 4, 10),
            memo: '初回接種完了',
          ),
          VaccinationHistory(
            id: _uuid.v4(),
            round: 2,
            date: DateTime(2024, 4, 10),
          ),
        ],
      ),
      VaccinationRecord(
        id: _uuid.v4(),
        name: 'フィラリア予防',
        status: '接種中', // 次回接種日があるため「接種中」
        lastDate: DateTime(2024, 8, 1),
        nextDate: DateTime(2024, 9, 1),
        iconName: 'bug_report',
        colorName: 'pink',
        history: [
          VaccinationHistory(
            id: _uuid.v4(),
            round: 1,
            date: DateTime(2024, 5, 1),
            memo: '5月開始',
          ),
          VaccinationHistory(
            id: _uuid.v4(),
            round: 2,
            date: DateTime(2024, 6, 1),
          ),
          VaccinationHistory(
            id: _uuid.v4(),
            round: 3,
            date: DateTime(2024, 7, 1),
          ),
          VaccinationHistory(
            id: _uuid.v4(),
            round: 4,
            date: DateTime(2024, 8, 1),
          ),
        ],
      ),
    ];
  }

  /// 기본 진료 기록
  List<MedicalRecord> _getDefaultMedicalRecords() {
    return [
      MedicalRecord(
        id: _uuid.v4(),
        title: '定期健康診断',
        date: DateTime(2024, 7, 20),
        hospital: '田中動物病院',
        status: '正常',
        iconName: 'local_hospital',
        colorName: 'pink',
      ),
      MedicalRecord(
        id: _uuid.v4(),
        title: 'デンタルケア',
        date: DateTime(2024, 6, 5),
        hospital: '田中動物病院',
        status: '完了',
        iconName: 'cleaning_services',
        colorName: 'blue',
      ),
    ];
  }

  /// 기본 예약/스케줄
  List<AppointmentRecord> _getDefaultAppointments() {
    return [
      AppointmentRecord(
        id: _uuid.v4(),
        title: '次回健康診断',
        dateTime: DateTime(2025, 1, 20, 10, 0),
        location: '田中動物病院',
        status: '予約済み',
        iconName: 'schedule',
        colorName: 'blue',
      ),
      AppointmentRecord(
        id: _uuid.v4(),
        title: 'グルーミング',
        dateTime: DateTime(2024, 9, 25, 14, 0),
        location: 'ペットサロン花',
        status: '予約済み',
        iconName: 'content_cut',
        colorName: 'pink',
      ),
    ];
  }
}
