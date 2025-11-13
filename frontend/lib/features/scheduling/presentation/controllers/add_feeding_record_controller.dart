import 'dart:developer' as developer;

import 'package:aipet_frontend/features/scheduling/data/services/feeding_local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_feeding_record_controller.g.dart';

/// 급여 기록 추가 컨트롤러
@riverpod
class AddFeedingRecordController extends _$AddFeedingRecordController {
  @override
  AddFeedingRecordState build() {
    return AddFeedingRecordState();
  }

  /// 펫 정보 및 사이즈 가이드 로드
  Future<void> loadPetInfo(String petId) async {
    final petSizes = FeedingLocalStorageService.getPetSizeFeedingInfo();
    final selectedPetInfo = petSizes[petId];
    Map<String, dynamic>? petSizeGuide;

    if (selectedPetInfo != null) {
      final size = selectedPetInfo['size'] as String;
      final sizeGuide = FeedingLocalStorageService.getPetSizeFeedingGuide();
      petSizeGuide = sizeGuide[size];
    }

    // 펫 현재 상태 로드
    final currentStatus = await FeedingLocalStorageService.getPetStatus(petId);
    List<String> selectedStatuses = [];
    Map<String, String> statusValues = {};

    selectedStatuses = List<String>.from(
      currentStatus['selectedStatuses'] ?? [],
    );
    statusValues = Map<String, String>.from(currentStatus);
    statusValues.remove('selectedStatuses');
    statusValues.remove('lastUpdated');

    state = state.copyWith(
      selectedPetId: petId,
      selectedPetInfo: selectedPetInfo,
      petSizeGuide: petSizeGuide,
      selectedStatuses: selectedStatuses,
      statusValues: statusValues,
    );
  }

  /// 펫 선택
  Future<void> selectPet(String petId) async {
    await loadPetInfo(petId);
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 시간 선택
  void selectTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  /// 식사 타입 선택
  void selectMealType(String mealType) {
    state = state.copyWith(selectedMealType: mealType);
  }

  /// 상태 업데이트
  Future<void> updatePetStatus(
    String petId,
    List<String> selectedStatuses,
    Map<String, String> statusValues,
  ) async {
    // 로컬 저장소에 상태 업데이트
    await FeedingLocalStorageService.updatePetStatus(petId, statusValues);

    state = state.copyWith(
      selectedStatuses: selectedStatuses,
      statusValues: statusValues,
    );
  }

  /// 로컬 저장소에 새로운 급여 기록 추가
  Future<void> addMockFeedingRecord({
    required String petId,
    required String meal,
    required String amount,
    required String note,
  }) async {
    final newRecord = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'petId': petId,
      'petName': state.selectedPetInfo?['name'] ?? 'Max',
      'fedTime': state.selectedDate.toIso8601String(),
      'amount': double.tryParse(amount) ?? 0.0,
      'foodType': meal,
      'foodBrand': 'カスタム',
      'status': 'completed',
      'notes': note,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // 로컬 저장소에 기록 추가
    await FeedingLocalStorageService.addFeedingRecord(newRecord);

    // 추가된 기록 확인
    developer.log('새로운 급여 기록이 로컬 저장소에 추가되었습니다: $newRecord');
  }

  /// 저장 데이터 반환
  Map<String, dynamic> getSaveData({
    required String meal,
    required String amount,
    required String note,
  }) {
    return {
      'date': state.selectedDate,
      'time': state.selectedTime,
      'mealType': state.selectedMealType,
      'meal': meal,
      'amount': '${amount}g',
      'note': note,
    };
  }
}

/// 급여 기록 추가 상태
class AddFeedingRecordState {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedMealType;
  final String selectedPetId;
  final Map<String, dynamic>? selectedPetInfo;
  final Map<String, dynamic>? petSizeGuide;
  final List<String> selectedStatuses;
  final Map<String, String> statusValues;

  AddFeedingRecordState({
    DateTime? selectedDate,
    this.selectedTime = const TimeOfDay(hour: 10, minute: 0),
    this.selectedMealType = '朝食',
    this.selectedPetId = '1',
    this.selectedPetInfo,
    this.petSizeGuide,
    this.selectedStatuses = const [],
    this.statusValues = const {},
  }) : selectedDate = selectedDate ?? DateTime.now();

  AddFeedingRecordState copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? selectedMealType,
    String? selectedPetId,
    Map<String, dynamic>? selectedPetInfo,
    Map<String, dynamic>? petSizeGuide,
    List<String>? selectedStatuses,
    Map<String, String>? statusValues,
  }) {
    return AddFeedingRecordState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      selectedPetId: selectedPetId ?? this.selectedPetId,
      selectedPetInfo: selectedPetInfo ?? this.selectedPetInfo,
      petSizeGuide: petSizeGuide ?? this.petSizeGuide,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      statusValues: statusValues ?? this.statusValues,
    );
  }
}
