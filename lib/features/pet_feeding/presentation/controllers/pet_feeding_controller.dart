import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';

/// 펫 급여 컨트롤러
class PetFeedingController extends StateNotifier<PetFeedingState> {
  PetFeedingController() : super(const PetFeedingState());

  /// 급여 기록 로드
  void loadFeedingRecords(String petId) {
    final records = MockDataService.getMockFeedingRecords();
    final petRecords = records.where((record) => record.petId == petId).toList();
    state = state.copyWith(
      petId: petId,
      feedingRecords: petRecords.map((record) => {
        'id': record.id,
        'petId': record.petId,
        'petName': record.petName,
        'fedTime': record.fedTime,
        'amount': record.amount,
        'foodType': record.foodType,
        'foodBrand': record.foodBrand,
        'status': record.status,
        'notes': record.notes,
        'createdAt': record.createdAt,
      }).toList(),
    );
  }

  /// 급여 기록 추가
  void addFeedingRecord(Map<String, dynamic> record) {
    final newRecords = List<Map<String, dynamic>>.from(state.feedingRecords);
    newRecords.add(record);
    state = state.copyWith(feedingRecords: newRecords);
  }

  /// 급여 기록 삭제
  void deleteFeedingRecord(String recordId) {
    final newRecords = state.feedingRecords.where((record) => record['id'] != recordId).toList();
    state = state.copyWith(feedingRecords: newRecords);
  }
}

/// 펫 급여 상태
class PetFeedingState {
  final String petId;
  final List<Map<String, dynamic>> feedingRecords;

  const PetFeedingState({
    this.petId = '',
    this.feedingRecords = const [],
  });

  PetFeedingState copyWith({
    String? petId,
    List<Map<String, dynamic>>? feedingRecords,
  }) {
    return PetFeedingState(
      petId: petId ?? this.petId,
      feedingRecords: feedingRecords ?? this.feedingRecords,
    );
  }
}

/// 컨트롤러 프로바이더
final petFeedingControllerProvider =
    StateNotifierProvider<PetFeedingController, PetFeedingState>((ref) {
  return PetFeedingController();
});
