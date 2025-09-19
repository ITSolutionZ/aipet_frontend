import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../domain/usecases/update_walk_record_usecase.dart';

/// 산책 작업 결과 (shared의 Result 패턴 사용)
typedef WalkResult<T> = Result<T>;

class WalkController extends CrudController<WalkRecordEntity> {
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

  @override
  Future<Result<List<WalkRecordEntity>>> getAll() async {
    try {
      final walkRecords = await _getAllWalkRecordsUseCase();
      ref
          .read(walkRecordsNotifierProvider.notifier)
          .setWalkRecords(walkRecords);
      return Result.success('散歩記録が読み込まれました', walkRecords);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('散歩記録の読み込みに失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<WalkRecordEntity>> getById(String id) async {
    try {
      final walkRecord = await _repository.getWalkRecordById(id);
      if (walkRecord != null) {
        return Result.success('散歩記録を取得しました', walkRecord);
      } else {
        return Result.failure('散歩記録が見つかりません');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('散歩記録の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<WalkRecordEntity>> create(WalkRecordEntity item) async {
    try {
      final newWalk = await _startWalkUseCase(item);
      ref.read(walkRecordsNotifierProvider.notifier).addWalkRecord(newWalk);
      return Result.success('散歩が開始されました', newWalk);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('散歩開始に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<WalkRecordEntity>> update(WalkRecordEntity item) async {
    try {
      await _updateWalkRecordUseCase(item);
      ref.read(walkRecordsNotifierProvider.notifier).updateWalkRecord(item);
      return Result.success('散歩記録が更新されました', item);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('散歩記録の更新に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _repository.deleteWalkRecord(id);
      ref.read(walkRecordsNotifierProvider.notifier).removeWalkRecord(id);
      return Result.success('散歩記録が削除されました', null);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('散歩記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 산책 기록 목록 로드
  Future<WalkResult<List<WalkRecordEntity>>> loadWalkRecords() async {
    return getAll();
  }

  /// 새 산책 시작
  Future<WalkResult<WalkRecordEntity>> startNewWalk({
    required String title,
    required String petId,
    String? petName,
    String? petImage,
  }) async {
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

    final result = await create(newWalkRecord);

    if (result.isSuccess) {
      // Provider에 결과 저장
      ref.read(currentWalkNotifierProvider.notifier).startWalk(result.data!);

      // 실시간 위치 추적 시작 (별도 처리)
      _startLocationTrackingWithRecovery();
    }

    return result;
  }

  /// 위치 추적 시작 (복구 기능 포함)
  void _startLocationTrackingWithRecovery() {
    safeExecute(() async {
      await ref.read(locationTrackingNotifierProvider.notifier).startTracking();
    }, errorMessage: '位置追跡開始');
  }

  /// 산책 종료
  Future<WalkResult> endCurrentWalk({double? distance, String? notes}) async {
    final currentWalk = ref.read(currentWalkNotifierProvider);
    if (currentWalk == null) {
      return WalkResult.failure('進行中の散歩がありません');
    }

    final result = await safeExecuteWithTimeout(
      () async {
        final completedWalk = await _endWalkUseCase(
          currentWalk.id,
          distance: distance,
          notes: notes,
        );

        // 실시간 위치 추적 중지
        ref.read(locationTrackingNotifierProvider.notifier).stopTracking();

        // Provider에 결과 저장
        ref.read(currentWalkNotifierProvider.notifier).endWalk();
        ref
            .read(walkRecordsNotifierProvider.notifier)
            .updateWalkRecord(completedWalk);

        return completedWalk;
      },
      timeout: const Duration(seconds: 15),
      errorMessage: '散歩終了',
    );

    if (result != null) {
      return WalkResult.success('散歩が終了しました', result);
    } else {
      return WalkResult.failure('散歩の終了に失敗しました');
    }
  }

  /// 산책 기록 수정
  Future<WalkResult> updateWalkRecord(WalkRecordEntity walkRecord) async {
    final result = await safeExecuteWithRetry(
      () async {
        await _updateWalkRecordUseCase(walkRecord);

        // Provider에 결과 저장
        ref
            .read(walkRecordsNotifierProvider.notifier)
            .updateWalkRecord(walkRecord);

        return walkRecord;
      },
      maxRetries: 2,
      errorMessage: '散歩記録の更新',
    );

    if (result != null) {
      return WalkResult.success('散歩記録が更新されました', result);
    } else {
      return WalkResult.failure('散歩記録の更新に失敗しました');
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
    final result = await safeExecute(() async {
      // Repository에서 실제 삭제 수행
      await _repository.deleteWalkRecord(recordId);

      // Provider에서도 제거
      ref.read(walkRecordsNotifierProvider.notifier).removeWalkRecord(recordId);
      return true;
    }, errorMessage: '散歩記録の削除');

    if (result != null && result) {
      return WalkResult.success('散歩記録が削除されました');
    } else {
      return WalkResult.failure('散歩記録の削除に失敗しました');
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
    final result = await safeExecuteWithRetry(
      () async {
        return _getWalkRecordsByPetUseCase(petId);
      },
      maxRetries: 2,
      errorMessage: 'ペットの散歩記録取得',
    );

    if (result != null) {
      return WalkResult.success('ペットの散歩記録を取得しました', result);
    } else {
      return WalkResult.failure('ペットの散歩記録の取得に失敗しました');
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

  /// 거리 계산 (Haversine 공식 사용)
  double calculateDistance(List<WalkLocation> route) {
    if (route.length < 2) return 0.0;

    double totalDistanceM = 0.0;
    for (int i = 1; i < route.length; i++) {
      final prev = route[i - 1];
      final curr = route[i];

      // Haversine 공식을 사용한 정확한 거리 계산 (미터 단위)
      totalDistanceM += GeoUtils.calculateDistanceM(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );
    }

    // km 단위로 변환
    return totalDistanceM / 1000.0;
  }
}
