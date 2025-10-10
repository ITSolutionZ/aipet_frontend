import 'package:aipet_frontend/features/pet_feeding/data/services/pet_feeding_local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 급여 컨트롤러
class PetFeedingController extends StateNotifier<PetFeedingState> {
  PetFeedingController() : super(const PetFeedingState());

  /// 급여 기록 로드
  Future<void> loadFeedingRecords(String petId) async {
    final recordsData = await PetFeedingLocalStorageService.getFeedingRecords(
      petId: petId,
    );

    state = state.copyWith(petId: petId, feedingRecords: recordsData);
  }

  /// 급여 기록 추가
  Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    await PetFeedingLocalStorageService.addFeedingRecord(record);
    await loadFeedingRecords(state.petId);
  }

  /// 급여 기록 삭제
  Future<void> deleteFeedingRecord(String recordId) async {
    await PetFeedingLocalStorageService.deleteFeedingRecord(recordId);
    await loadFeedingRecords(state.petId);
  }
}

/// 펫 급여 상태
class PetFeedingState {
  final String petId;
  final List<Map<String, dynamic>> feedingRecords;

  const PetFeedingState({this.petId = '', this.feedingRecords = const []});

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
