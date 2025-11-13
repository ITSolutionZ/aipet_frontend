import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_input_logic.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_health_form_controller.g.dart';

/// Daily Health Form Controller
///
/// **역할**: 일일 건강 입력 폼의 상태 관리
/// - 폼 데이터 상태 관리 (체온, 증상, 메모 등)
/// - TextEditingController 관리
/// - DailyHealthInputLogic 통합
///
/// **사용 위치**: DailyHealthInputScreen에서 사용
/// **관련 파일**: DailyHealthInputLogic (폼 검증 및 제출 로직)
@riverpod
class DailyHealthFormController extends _$DailyHealthFormController {
  late final DailyHealthInputLogic _logic;
  late final TextEditingController _temperatureController;
  late final TextEditingController _notesController;

  @override
  DailyHealthFormData build(DailyHealthRecord? existingRecord) {
    _logic = DailyHealthInputLogic(ref: ref, existingRecord: existingRecord);
    _temperatureController = TextEditingController();
    _notesController = TextEditingController();

    _initializeForm();

    return DailyHealthFormData.initial();
  }

  /// TextEditingController 접근자들
  TextEditingController get temperatureController => _temperatureController;
  TextEditingController get notesController => _notesController;

  /// 비즈니스 로직 접근자
  DailyHealthInputLogic get logic => _logic;

  void _initializeForm() {
    final formData = _logic.initializeFormData();
    state = formData;
    _updateControllers(formData);
  }

  /// 펫 선택 업데이트
  void updateSelectedPet(String? petId) {
    state = state.copyWith(selectedPetId: petId);
  }

  /// 체온 업데이트
  void updateTemperature(String temperatureText) {
    final temperature = temperatureText.isNotEmpty
        ? double.tryParse(temperatureText)
        : null;
    state = state.copyWith(temperature: temperature);
  }

  /// 헬스 상태 업데이트
  void updateHealthStatus(HealthStatus status) {
    state = state.copyWith(selectedHealthStatus: status);
  }

  /// 증상 목록 업데이트
  void updateSymptoms(List<String> symptoms) {
    state = state.copyWith(selectedSymptoms: symptoms);
  }

  /// 메모 업데이트
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// 헬스 레코드 저장
  Future<void> saveHealthRecord() async {
    // 컨트롤러의 현재 값으로 상태 업데이트
    _syncControllersToState();
    await _logic.saveHealthRecord(state);
  }

  /// TextEditingController의 값을 상태에 반영
  void _syncControllersToState() {
    updateTemperature(_temperatureController.text);
    updateNotes(_notesController.text);
  }

  /// 컨트롤러들을 폼 데이터로 초기화
  void _updateControllers(DailyHealthFormData formData) {
    _temperatureController.text = formData.temperature?.toString() ?? '';
    _notesController.text = formData.notes ?? '';
  }
}

/// 로딩 상태 관리 Provider
@riverpod
class DailyHealthInputLoading extends _$DailyHealthInputLoading {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}
