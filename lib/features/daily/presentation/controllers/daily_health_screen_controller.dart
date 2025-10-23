import 'dart:async';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import 'package:aipet_frontend/features/daily/data/providers/vaccine_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/pet_profile/pet_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_health_screen_controller.g.dart';

/// Daily Health Screen의 상태 데이터
class DailyHealthScreenData {
  final String? selectedPetId;

  const DailyHealthScreenData({this.selectedPetId});

  DailyHealthScreenData copyWith({String? selectedPetId}) {
    return DailyHealthScreenData(
      selectedPetId: selectedPetId ?? this.selectedPetId,
    );
  }
}

/// Daily Health Screen Controller
///
/// **역할**: 일일 건강 화면의 상태 관리 및 초기화
/// - 선택된 펫 ID 상태 관리
/// - 펫 선택 초기화
/// - DailyHealthLogic 통합
///
/// **사용 위치**: DailyHealthScreen에서 사용
/// **관련 파일**: DailyHealthLogic (UI 로직), DailyHealthController (데이터 CRUD)
@riverpod
class DailyHealthScreenController extends _$DailyHealthScreenController {
  late final DailyHealthLogic _logic;

  @override
  DailyHealthScreenData build() {
    _logic = DailyHealthLogic();
    // build() 메서드에서는 ref.read() 사용 금지
    // 대신 WidgetsBinding.instance.addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePetSelection();
    });
    return const DailyHealthScreenData();
  }

  /// 로직 인스턴스 접근
  DailyHealthLogic get logic => _logic;

  /// 펫 선택 초기화
  void _initializePetSelection() {
    final pets = ref.read(petProfilesProvider).value;
    final selectedPetId = _logic.initializePetSelection(pets);
    if (selectedPetId != null) {
      state = state.copyWith(selectedPetId: selectedPetId);
    }
  }

  /// 선택된 펫 업데이트
  void updateSelectedPet(String? petId) {
    if (petId == null || petId == state.selectedPetId) return;

    LoggerService.debug('🔄 Updating selected pet: ${state.selectedPetId} → $petId');

    // 이전 펫의 provider 무효화
    if (state.selectedPetId != null) {
      ref.invalidate(dailyHealthRecordProvider(state.selectedPetId!));
      ref.invalidate(dailyHealthAnalysisProvider(state.selectedPetId!));
      ref.invalidate(scheduledVaccinesProvider(state.selectedPetId!));
      ref.invalidate(completedVaccinesProvider(state.selectedPetId!));
      LoggerService.debug('🗑️ Invalidated providers for pet: ${state.selectedPetId}');
    }

    // 상태 업데이트
    state = state.copyWith(selectedPetId: petId);

    // 새 펫의 provider들 무효화하여 강제 새로고침
    ref.invalidate(dailyHealthRecordProvider(petId));
    ref.invalidate(dailyHealthAnalysisProvider(petId));
    ref.invalidate(scheduledVaccinesProvider(petId));
    ref.invalidate(completedVaccinesProvider(petId));

    // 새 펫의 provider 미리 로드
    unawaited(ref.read(dailyHealthRecordProvider(petId).future));
    unawaited(ref.read(dailyHealthAnalysisProvider(petId).future));
    unawaited(ref.read(scheduledVaccinesProvider(petId).future));
    unawaited(ref.read(completedVaccinesProvider(petId).future));

    LoggerService.debug('✅ Selected pet updated to: $petId');
  }

  /// 펫 목록 새로고침
  void refreshPetSelection() {
    _initializePetSelection();
  }
}
