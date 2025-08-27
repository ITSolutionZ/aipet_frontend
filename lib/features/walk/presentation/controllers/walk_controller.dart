import 'dart:math';

import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../domain/usecases/update_walk_record_usecase.dart';

/// 산책 작업 결과
class WalkResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const WalkResult._(this.isSuccess, this.message, this.data);

  factory WalkResult.success(String message, [dynamic data]) =>
      WalkResult._(true, message, data);
  factory WalkResult.failure(String message) =>
      WalkResult._(false, message, null);
}

class WalkController extends BaseController {
  WalkController(super.ref);

  // Repository 및 UseCase 인스턴스
  late final WalkRepository _repository = WalkRepositoryImpl();
  late final GetAllWalkRecordsUseCase _getAllWalkRecordsUseCase =
      GetAllWalkRecordsUseCase(_repository);
  late final GetWalkRecordsByPetUseCase _getWalkRecordsByPetUseCase =
      GetWalkRecordsByPetUseCase(_repository);
  late final StartWalkUseCase _startWalkUseCase = StartWalkUseCase(_repository);
  late final EndWalkUseCase _endWalkUseCase = EndWalkUseCase(_repository);
  late final UpdateWalkRecordUseCase _updateWalkRecordUseCase =
      UpdateWalkRecordUseCase(_repository);

  /// 산책 기록 목록 로드
  Future<WalkResult> loadWalkRecords() async {
    try {
      final walkRecords = await _getAllWalkRecordsUseCase();
      ref
          .read(walkRecordsNotifierProvider.notifier)
          .setWalkRecords(walkRecords);
      return WalkResult.success('散歩記録が読み込まれました', walkRecords);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 새 산책 시작
  Future<WalkResult> startNewWalk({
    required String title,
    required String petId,
    String? petName,
    String? petImage,
  }) async {
    try {
      final newWalkRecord = WalkRecordEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        startTime: DateTime.now(),
        route: [],
        petId: petId,
        petName: petName,
        petImage: petImage,
        ownerName: 'Sarah',
        ownerAvatar: 'assets/images/placeholder.png',
        status: WalkStatus.inProgress,
        createdAt: DateTime.now(),
      );

      final newWalk = await _startWalkUseCase(newWalkRecord);

      // Provider에 결과 저장
      ref.read(currentWalkNotifierProvider.notifier).startWalk(newWalk);
      ref.read(walkRecordsNotifierProvider.notifier).addWalkRecord(newWalk);
      return WalkResult.success('散歩が開始されました', newWalk);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 종료
  Future<WalkResult> endCurrentWalk({double? distance, String? notes}) async {
    try {
      final currentWalk = ref.read(currentWalkNotifierProvider);
      if (currentWalk == null) {
        return WalkResult.failure('進行中の散歩がありません');
      }

      final completedWalk = await _endWalkUseCase(
        currentWalk.id,
        distance: distance,
        notes: notes,
      );

      // Provider에 결과 저장
      ref.read(currentWalkNotifierProvider.notifier).endWalk();
      ref
          .read(walkRecordsNotifierProvider.notifier)
          .updateWalkRecord(completedWalk);
      return WalkResult.success('散歩が終了しました', completedWalk);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 기록 수정
  Future<WalkResult> updateWalkRecord(WalkRecordEntity walkRecord) async {
    try {
      await _updateWalkRecordUseCase(walkRecord);

      // Provider에 결과 저장
      ref
          .read(walkRecordsNotifierProvider.notifier)
          .updateWalkRecord(walkRecord);

      return WalkResult.success('散歩記録が更新されました', walkRecord);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 일시정지
  WalkResult pauseCurrentWalk() {
    try {
      ref.read(currentWalkNotifierProvider.notifier).pauseWalk();
      return WalkResult.success('散歩が一時停止されました');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 재개
  WalkResult resumeCurrentWalk() {
    try {
      ref.read(currentWalkNotifierProvider.notifier).resumeWalk();
      return WalkResult.success('散歩が再開されました');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 기록 삭제
  Future<WalkResult> deleteWalkRecord(String recordId) async {
    try {
      // Repository에서 실제 삭제 수행
      await _repository.deleteWalkRecord(recordId);

      // Provider에서도 제거
      ref.read(walkRecordsNotifierProvider.notifier).removeWalkRecord(recordId);
      return WalkResult.success('散歩記録が削除されました');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 선택된 반려동물 설정
  WalkResult setSelectedPet(PetInfo pet) {
    try {
      ref.read(selectedPetNotifierProvider.notifier).setSelectedPet(pet);
      return WalkResult.success('ペットが選択されました');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 지도 확장 상태 토글
  WalkResult toggleMapExpanded() {
    try {
      ref.read(mapExpandedNotifierProvider.notifier).toggleExpanded();
      return WalkResult.success('地図の拡大状態が変更されました');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 현재 진행 중인 산책 가져오기
  WalkRecordEntity? getCurrentWalk() {
    return ref.read(currentWalkNotifierProvider);
  }

  /// 산책 기록 목록 가져오기
  List<WalkRecordEntity> getWalkRecords() {
    return ref.read(walkRecordsNotifierProvider);
  }

  /// 특정 반려동물의 산책 기록 가져오기
  Future<WalkResult> getWalkRecordsByPet(String petId) async {
    try {
      final records = await _getWalkRecordsByPetUseCase(petId);
      return WalkResult.success('ペットの散歩記録を取得しました', records);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 최근 산책 기록 가져오기
  List<WalkRecordEntity> getRecentWalkRecords({int limit = 10}) {
    return ref
        .read(walkRecordsNotifierProvider.notifier)
        .getRecentWalkRecords(limit: limit);
  }

  /// 위치 정보 추가
  WalkResult addLocationToCurrentWalk(WalkLocation location) {
    try {
      ref
          .read(currentWalkNotifierProvider.notifier)
          .addLocationToCurrentWalk(location);
      return WalkResult.success('位置情報が追加されました');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return WalkResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 거리 계산 (간단한 유클리드 거리)
  double calculateDistance(List<WalkLocation> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < route.length; i++) {
      final prev = route[i - 1];
      final curr = route[i];

      final latDiff = curr.latitude - prev.latitude;
      final lonDiff = curr.longitude - prev.longitude;

      // 간단한 유클리드 거리 (실제로는 Haversine 공식 사용 권장)
      totalDistance += sqrt(latDiff * latDiff + lonDiff * lonDiff);
    }

    // 대략적인 km 변환 (1도 ≈ 111km)
    return totalDistance * 111.0;
  }
}
