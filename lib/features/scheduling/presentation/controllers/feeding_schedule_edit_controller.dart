import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';

/// 급여 스케줄 편집 컨트롤러
class FeedingScheduleEditController
    extends StateNotifier<FeedingScheduleEditState> {
  FeedingScheduleEditController({
    required String mealType,
    required String currentTime,
    required String currentAmount,
    required String petId,
  }) : super(
         FeedingScheduleEditState(
           mealType: mealType,
           currentTime: currentTime,
           currentAmount: currentAmount,
           petId: petId,
         ),
       ) {
    _loadPetInfo();
  }

  /// 펫 정보 및 사이즈 가이드 로드
  void _loadPetInfo() {
    final petSizes = MockDataService.getMockPetSizesAndFeedingAmounts();
    final selectedPetInfo = petSizes[state.petId];
    Map<String, dynamic>? petSizeGuide;

    if (selectedPetInfo != null) {
      final size = selectedPetInfo['size'] as String;
      final sizeGuide = MockDataService.getPetSizeFeedingGuide();
      petSizeGuide = sizeGuide[size];
    }

    // 펫 현재 상태 로드
    final currentStatus = MockDataService.getPetCurrentStatus(state.petId);
    List<String> selectedStatuses = [];
    Map<String, String> statusValues = {};

    if (currentStatus != null) {
      selectedStatuses = List<String>.from(
        currentStatus['selectedStatuses'] ?? [],
      );
      statusValues = Map<String, String>.from(currentStatus);
      statusValues.remove('selectedStatuses');
      statusValues.remove('lastUpdated');
    }

    state = state.copyWith(
      selectedPetInfo: selectedPetInfo,
      petSizeGuide: petSizeGuide,
      selectedStatuses: selectedStatuses,
      statusValues: statusValues,
    );
  }

  /// 시간 선택
  void selectTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  /// 양 변경
  void updateAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  /// 식사 타입 변경
  void selectMealType(String mealType) {
    state = state.copyWith(mealType: mealType);
  }

  /// 펫 선택
  void selectPet(String petId) {
    state = state.copyWith(petId: petId);
    _loadPetInfo();
  }

  /// 상태 업데이트
  void updatePetStatus(
    String petId,
    List<String> selectedStatuses,
    Map<String, String> statusValues,
  ) {
    // MockDataService에 상태 업데이트
    MockDataService.updatePetStatus(petId, selectedStatuses, statusValues);

    state = state.copyWith(
      selectedStatuses: selectedStatuses,
      statusValues: statusValues,
    );
  }

  /// 저장 데이터 반환
  Map<String, dynamic> getSaveData() {
    return {
      'time': '${state.selectedTime.hour}:${state.selectedTime.minute}',
      'amount': '${state.amount}g',
      'mealType': state.mealType,
      'petId': state.petId,
    };
  }
}

/// 급여 스케줄 편집 상태
class FeedingScheduleEditState {
  final String mealType;
  final TimeOfDay selectedTime;
  final String amount;
  final String petId;
  final Map<String, dynamic>? selectedPetInfo;
  final Map<String, dynamic>? petSizeGuide;
  final List<String> selectedStatuses;
  final Map<String, String> statusValues;

  FeedingScheduleEditState({
    required this.mealType,
    required String currentTime,
    required String currentAmount,
    required this.petId,
    this.selectedPetInfo,
    this.petSizeGuide,
    this.selectedStatuses = const [],
    this.statusValues = const {},
  }) : selectedTime = _parseTime(currentTime),
       amount = currentAmount.replaceAll('g', '');

  static TimeOfDay _parseTime(String timeString) {
    final timeParts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  FeedingScheduleEditState copyWith({
    String? mealType,
    TimeOfDay? selectedTime,
    String? amount,
    String? petId,
    Map<String, dynamic>? selectedPetInfo,
    Map<String, dynamic>? petSizeGuide,
    List<String>? selectedStatuses,
    Map<String, String>? statusValues,
  }) {
    return FeedingScheduleEditState(
      mealType: mealType ?? this.mealType,
      currentTime: selectedTime != null
          ? '${selectedTime.hour}:${selectedTime.minute}'
          : '${this.selectedTime.hour}:${this.selectedTime.minute}',
      currentAmount: amount != null ? '${amount}g' : '${this.amount}g',
      petId: petId ?? this.petId,
      selectedPetInfo: selectedPetInfo ?? this.selectedPetInfo,
      petSizeGuide: petSizeGuide ?? this.petSizeGuide,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      statusValues: statusValues ?? this.statusValues,
    );
  }
}

/// 컨트롤러 프로바이더
final feedingScheduleEditControllerProvider =
    StateNotifierProvider.family<
      FeedingScheduleEditController,
      FeedingScheduleEditState,
      Map<String, String>
    >((ref, params) {
      return FeedingScheduleEditController(
        mealType: params['mealType'] ?? '',
        currentTime: params['currentTime'] ?? '',
        currentAmount: params['currentAmount'] ?? '',
        petId: params['petId'] ?? '1',
      );
    });
