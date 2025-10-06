import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_input_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily Health Input 폼의 상태를 관리하는 StateNotifier
class DailyHealthFormController extends StateNotifier<DailyHealthFormData> {
  final Ref ref;
  final DailyHealthRecord? existingRecord;
  late final DailyHealthInputLogic _logic;
  late final TextEditingController _temperatureController;
  late final TextEditingController _notesController;

  DailyHealthFormController({
    required this.ref,
    this.existingRecord,
  }) : super(DailyHealthFormData.initial()) {
    _logic = DailyHealthInputLogic(ref: ref, existingRecord: existingRecord);
    _temperatureController = TextEditingController();
    _notesController = TextEditingController();

    _initializeForm();
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

  @override
  void dispose() {
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

/// DailyHealthFormController Provider
final dailyHealthFormControllerProvider = StateNotifierProvider.autoDispose
    .family<DailyHealthFormController, DailyHealthFormData, DailyHealthRecord?>(
  (ref, existingRecord) => DailyHealthFormController(
    ref: ref,
    existingRecord: existingRecord,
  ),
);

/// 로딩 상태 관리 Provider
final dailyHealthInputLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);