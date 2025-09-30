import 'package:aipet_frontend/features/pet_feeding/domain/domain.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet_feeding/pet_feeding_mock_service.dart'
    as PetFeedingMock;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 급여 컨트롤러
class PetFeedingController extends StateNotifier<PetFeedingState> {
  PetFeedingController() : super(const PetFeedingState());

  /// 급여 기록 로드
  void loadFeedingRecords(String petId) {
    final mockRecords = PetFeedingMock.PetFeedingMockService.getMockFeedingRecords(petId: petId);
    final records = mockRecords
        .map(
          (recordData) => FeedingRecordEntity(
            id: recordData['id'] as String,
            petId: recordData['petId'] as String,
            petName: '펫', // Mock 데이터에 petName이 없으므로 기본값 사용
            fedTime: recordData['feedTime'] as DateTime,
            amount: double.tryParse((recordData['amount'] as String).replaceAll('g', '')) ?? 0.0,
            foodType: recordData['foodType'] as String,
            foodBrand: recordData['foodBrand'] as String,
            status: FeedingStatus.completed, // Mock 데이터에 status가 없으므로 기본값 사용
            notes: recordData['notes'] as String,
            createdAt: recordData['feedTime'] as DateTime,
          ),
        )
        .toList();
    final petRecords = records.where((record) => record.petId == petId).toList();
    state = state.copyWith(
      petId: petId,
      feedingRecords: petRecords
          .map(
            (record) => {
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
            },
          )
          .toList(),
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

  const PetFeedingState({this.petId = '', this.feedingRecords = const []});

  PetFeedingState copyWith({String? petId, List<Map<String, dynamic>>? feedingRecords}) {
    return PetFeedingState(
      petId: petId ?? this.petId,
      feedingRecords: feedingRecords ?? this.feedingRecords,
    );
  }
}

/// 컨트롤러 프로바이더
final petFeedingControllerProvider = StateNotifierProvider<PetFeedingController, PetFeedingState>((
  ref,
) {
  return PetFeedingController();
});
