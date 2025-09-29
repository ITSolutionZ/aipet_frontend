import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/walk/data/data.dart';
import 'package:aipet_frontend/features/walk/domain/domain.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart' as domain;
import 'package:aipet_frontend/features/walk/domain/usecases/update_walk_record_usecase.dart';
import 'package:aipet_frontend/shared/core/utils/geo_utils.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 산책 작업 결과 (shared의 Result 패턴 사용)
typedef WalkResult<T> = Result<T>;

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

  /// 모든 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getAll() async {
    try {
      final walkRecords = await _getAllWalkRecordsUseCase();
      ref
          .read(walkRecordsNotifierProvider.notifier)
          .setWalkRecords(walkRecords);
      return Result.success('산책 기록이 로드되었습니다', walkRecords);
    } catch (e) {
      return Result.failure('산책 기록 로드에 실패했습니다: ${e.toString()}');
    }
  }

  /// ID로 산책 기록 조회
  Future<Result<WalkRecordEntity>> getById(String id) async {
    try {
      final walkRecord = await _repository.getWalkRecordById(id);
      if (walkRecord != null) {
        return Result.success('산책 기록을 가져왔습니다', walkRecord);
      } else {
        return const Failure('해당 ID의 산책 기록을 찾을 수 없습니다');
      }
    } catch (e) {
      return Result.failure('산책 기록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  /// 새 산책 기록 생성
  Future<Result<WalkRecordEntity>> create(WalkRecordEntity item) async {
    try {
      final newWalk = await _startWalkUseCase(item);
      ref.read(walkRecordsNotifierProvider.notifier).addWalkRecord(newWalk);
      return Result.success('산책이 시작되었습니다', newWalk);
    } catch (e) {
      return Result.failure('산책 시작에 실패했습니다: ${e.toString()}');
    }
  }

  /// 산책 기록 업데이트
  Future<Result<WalkRecordEntity>> update(WalkRecordEntity item) async {
    try {
      await _updateWalkRecordUseCase(item);
      ref.read(walkRecordsNotifierProvider.notifier).updateWalkRecord(item);
      return Result.success('산책 기록이 업데이트되었습니다', item);
    } catch (e) {
      return Result.failure('산책 기록 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  /// 산책 기록 삭제
  Future<Result<void>> delete(String id) async {
    try {
      await _repository.deleteWalkRecord(id);
      ref.read(walkRecordsNotifierProvider.notifier).removeWalkRecord(id);
      return Result.success('산책 기록이 삭제되었습니다');
    } catch (e) {
      return Result.failure('산책 기록 삭제에 실패했습니다: ${e.toString()}');
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
      petId: petId,
      petName: petName ?? '알 수 없는 펫',
      startTime: DateTime.now(),
      route: [],
      status: WalkStatus.inProgress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final walkRecord = await _startWalkUseCase.call(newWalkRecord);

      // Provider에 결과 저장
      ref.read(currentWalkNotifierProvider.notifier).startWalk(walkRecord);

      // 실시간 위치 추적 시작 (별도 처리)
      _startLocationTrackingWithRecovery();

      return Result.success('산책을 시작했습니다', walkRecord);
    } catch (e) {
      return Result.failure('산책 시작에 실패했습니다: ${e.toString()}');
    }
  }

  /// 위치 추적 시작 (복구 기능 포함)
  void _startLocationTrackingWithRecovery() {
    safeExecute(() async {
      await ref.read(locationTrackingNotifierProvider.notifier).startTracking();
      return true;
    }, errorMessage: '位置追跡開始');
  }

  /// 산책 종료
  Future<WalkResult> endCurrentWalk({double? distance, String? notes}) async {
    final currentWalk = ref.read(currentWalkNotifierProvider);
    if (currentWalk == null) {
      return const Failure('진행 중인 산책이 없습니다');
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
      return Result.success('산책이 종료되었습니다', result);
    } else {
      return const Failure('산책 종료에 실패했습니다');
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
      return Result.success('산책 기록이 업데이트되었습니다', result);
    } else {
      return const Failure('산책 기록 업데이트에 실패했습니다');
    }
  }

  /// 산책 일시정지
  Result<bool> pauseCurrentWalk() {
    try {
      ref.read(currentWalkNotifierProvider.notifier).pauseWalk();
      return Result.success('산책이 일시정지되었습니다', true);
    } catch (e) {
      return Result.failure('산책 일시정지에 실패했습니다: ${e.toString()}');
    }
  }

  /// 산책 재개
  Result<bool> resumeCurrentWalk() {
    try {
      ref.read(currentWalkNotifierProvider.notifier).resumeWalk();
      return Result.success('산책이 재개되었습니다', true);
    } catch (e) {
      return Result.failure('산책 재개에 실패했습니다: ${e.toString()}');
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
      return Result.success('산책 기록이 삭제되었습니다');
    } else {
      return const Failure('산책 기록 삭제에 실패했습니다');
    }
  }

  /// 선택된 반려동물 설정
  Result<bool> setSelectedPet(domain.PetInfo? pet) {
    try {
      // domain.PetInfo를 data.PetInfo로 변환 (같은 구조이므로 안전)
      if (pet != null) {
        ref.read(selectedPetNotifierProvider.notifier).setSelectedPet(pet as dynamic);
      } else {
        ref.read(selectedPetNotifierProvider.notifier).setSelectedPet(null);
      }
      return Result.success('ペットが選択されました', true);
    } catch (e) {
      return Result.failure('ペット선택에 실패했습니다: ${e.toString()}');
    }
  }

  /// 지도 확장 상태 토글
  Result<bool> toggleMapExpanded() {
    try {
      ref.read(mapExpandedNotifierProvider.notifier).toggleExpanded();
      return Result.success('地図の拡大状態が変更されました', true);
    } catch (e) {
      return Result.failure('지도 상태 변경에 실패했습니다: ${e.toString()}');
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
      return Result.success('반려동물 산책 기록을 가져왔습니다', result);
    } else {
      return const Failure('반려동물 산책 기록 가져오기에 실패했습니다');
    }
  }

  /// 최근 산책 기록 가져오기
  List<WalkRecordEntity> getRecentWalkRecords({int limit = 10}) {
    return ref
        .read(walkRecordsNotifierProvider.notifier)
        .getRecentWalkRecords(limit: limit);
  }

  /// 위치 정보 추가
  Result<bool> addLocationToCurrentWalk(WalkLocation location) {
    try {
      ref
          .read(currentWalkNotifierProvider.notifier)
          .addLocationToCurrentWalk(location);
      return Result.success('位置情報が追加されました', true);
    } catch (e) {
      return Result.failure('위치 정보 추가에 실패했습니다: ${e.toString()}');
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
