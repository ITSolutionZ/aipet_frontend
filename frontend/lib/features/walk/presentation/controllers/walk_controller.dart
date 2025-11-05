import 'package:flutter/foundation.dart';


import '../../../../shared/shared.dart';
import '../../../../app/controllers/base_controller.dart';
import '../../../../../features/walk/data/data.dart';
import '../../../../../features/walk/domain/domain.dart';
import '../../../../../features/walk/domain/usecases/update_walk_record_usecase.dart';

/// 산책 작업 결과 (shared의 Result 패턴 사용)
typedef WalkResult<T> = Result<T>;

class WalkController extends BaseController {
  WalkController(super.ref) {
    // Hybrid Repository 사용 (API, 로컬, Mock 통합)
    _repository = ref.read(hybridWalkRepositoryProvider);
    _initializeUseCases();
  }

  // Repository 및 UseCase 인스턴스
  late final WalkRepository _repository;
  late final GetAllWalkRecordsUseCase _getAllWalkRecordsUseCase;
  late final GetWalkRecordsByPetUseCase _getWalkRecordsByPetUseCase;
  late final StartWalkUseCase _startWalkUseCase;
  late final EndWalkUseCase _endWalkUseCase;
  late final UpdateWalkRecordUseCase _updateWalkRecordUseCase;

  void _initializeUseCases() {
    _getAllWalkRecordsUseCase = GetAllWalkRecordsUseCase(_repository);
    _getWalkRecordsByPetUseCase = GetWalkRecordsByPetUseCase(_repository);
    _startWalkUseCase = StartWalkUseCase(_repository);
    _endWalkUseCase = EndWalkUseCase(_repository);
    _updateWalkRecordUseCase = UpdateWalkRecordUseCase(_repository);
  }

  /// 모든 산책 기록 조회 (Hybrid Repository 사용)
  Future<Result<List<WalkRecordEntity>>> getAll() async {
    try {
      LoggerService.debug('🔄 WalkController: 산책 기록 조회 시작 (Hybrid Repository)');

      // Hybrid Repository가 자동으로 API, 로컬, Mock 순서로 시도
      final walkRecords = await _getAllWalkRecordsUseCase();

      ref.read(walkRecordsProvider.notifier).setWalkRecords(walkRecords);

      LoggerService.debug('✅ WalkController: ${walkRecords.length}개 산책 기록 로드 완료');
      return Result.success('散歩記録をロードしました', walkRecords);
    } catch (e) {
      LoggerService.debug('❌ WalkController: 산책 기록 로드 실패 - $e');
      return Result.failure('散歩記録のロードに失敗しました: ${e.toString()}');
    }
  }

  /// ID로 산책 기록 조회
  Future<Result<WalkRecordEntity>> getById(String id) async {
    try {
      final walkRecord = await _repository.getWalkRecordById(id);
      if (walkRecord != null) {
        return Result.success('산책 기록을 가져왔습니다', walkRecord);
      } else {
        return Result.failure('해당 ID의 산책 기록을 찾을 수 없습니다');
      }
    } catch (e) {
      return Result.failure('산책 기록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  /// 새 산책 기록 생성
  Future<Result<WalkRecordEntity>> create(WalkRecordEntity item) async {
    try {
      LoggerService.debug('🔄 WalkController: 산책 생성 시작 (Hybrid Repository)');

      // Repository가 로컬 저장 및 API 동기화 처리
      final newWalk = await _startWalkUseCase(item);
      ref.read(walkRecordsProvider.notifier).addWalkRecord(newWalk);

      LoggerService.debug('✅ WalkController: 산책 생성 완료 - ID: ${newWalk.id}');
      return Result.success('散歩が開始されました', newWalk);
    } catch (e) {
      LoggerService.debug('❌ WalkController: 산책 시작 실패 - $e');
      return Result.failure('散歩の開始に失敗しました: ${e.toString()}');
    }
  }

  /// 산책 기록 업데이트
  Future<Result<WalkRecordEntity>> update(WalkRecordEntity item) async {
    try {
      LoggerService.debug('🔄 WalkController: 산책 업데이트 시작 (Hybrid Repository)');

      // Repository가 로컬 업데이트 및 API 동기화 처리
      await _updateWalkRecordUseCase(item);
      ref.read(walkRecordsProvider.notifier).updateWalkRecord(item);

      LoggerService.debug('✅ WalkController: 산책 업데이트 완료 - ID: ${item.id}');
      return Result.success('散歩記録が更新されました', item);
    } catch (e) {
      LoggerService.debug('❌ WalkController: 산책 업데이트 실패 - $e');
      return Result.failure('散歩記録の更新に失敗しました: ${e.toString()}');
    }
  }

  /// 산책 기록 삭제
  Future<Result<void>> delete(String id) async {
    try {
      LoggerService.debug('🔄 WalkController: 산책 삭제 시작 (Hybrid Repository)');

      // Repository가 로컬 삭제 및 API 동기화 처리
      await _repository.deleteWalkRecord(id);
      ref.read(walkRecordsProvider.notifier).removeWalkRecord(id);

      LoggerService.debug('✅ WalkController: 산책 삭제 완료 - ID: $id');
      return Result.success('散歩記録が削除されました');
    } catch (e) {
      LoggerService.debug('❌ WalkController: 산책 삭제 실패 - $e');
      return Result.failure('散歩記録の削除に失敗しました: ${e.toString()}');
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
      LoggerService.debug('🔄 WalkController: 새 산책 시작 (Hybrid Repository)');

      // Repository가 로컬 저장 및 API 동기화 처리
      final walkRecord = await _startWalkUseCase.call(newWalkRecord);

      // Provider에 결과 저장
      ref.read(currentWalkProvider.notifier).startWalk(walkRecord);
      ref.read(walkRecordsProvider.notifier).addWalkRecord(walkRecord);

      // 실시간 위치 추적 시작
      _startLocationTrackingWithRecovery();

      LoggerService.debug('✅ WalkController: 산책 시작 완료 - ID: ${walkRecord.id}');
      return Result.success('散歩を開始しました', walkRecord);
    } catch (e) {
      LoggerService.debug('❌ WalkController: 산책 시작 실패 - $e');
      return Result.failure('散歩の開始に失敗しました: ${e.toString()}');
    }
  }

  /// 위치 추적 시작 (복구 기능 포함)
  void _startLocationTrackingWithRecovery() {
    safeExecute(() async {
      ref.read(locationTrackingProvider.notifier).startTracking();
      return true;
    }, errorMessage: '位置追跡開始');
  }

  /// 산책 종료
  Future<WalkResult> endCurrentWalk({double? distance, String? notes}) async {
    final currentWalk = ref.read(currentWalkProvider);
    if (currentWalk == null) {
      LoggerService.debug('⚠️ WalkController: 진행 중인 산책 없음');
      return Result.failure('進行中の散歩がありません');
    }

    LoggerService.debug('🔄 WalkController: 산책 종료 시작 (Hybrid Repository)');

    final result = await safeExecuteWithTimeout(
      () async {
        // Repository가 로컬 저장 및 API 동기화 처리
        final completedWalk = await _endWalkUseCase(
          currentWalk.id,
          distance: distance,
          notes: notes,
        );

        // 실시간 위치 추적 중지
        ref.read(locationTrackingProvider.notifier).stopTracking();

        // Provider에 결과 저장
        ref.read(currentWalkProvider.notifier).endWalk();
        ref.read(walkRecordsProvider.notifier).updateWalkRecord(completedWalk);

        LoggerService.debug('✅ WalkController: 산책 종료 완료 - ID: ${currentWalk.id}');
        return completedWalk;
      },
      timeout: const Duration(seconds: 15),
      errorMessage: '散歩終了',
    );

    if (result != null) {
      return Result.success('散歩が終了されました', result);
    } else {
      LoggerService.debug('❌ WalkController: 산책 종료 실패');
      return Result.failure('散歩の終了に失敗しました');
    }
  }

  /// 산책 기록 수정
  Future<WalkResult> updateWalkRecord(WalkRecordEntity walkRecord) async {
    LoggerService.debug('🔄 WalkController: 산책 기록 수정 시작 (Hybrid Repository)');
    LoggerService.debug('🔄 수정 데이터 - ID: ${walkRecord.id}, 거리: ${walkRecord.distance}m');

    final result = await safeExecuteWithRetry(
      () async {
        // Repository가 로컬 저장 및 API 동기화 처리
        await _updateWalkRecordUseCase(walkRecord);
        LoggerService.debug('✅ Repository 업데이트 완료');

        // Provider에 결과 저장
        ref.read(walkRecordsProvider.notifier).updateWalkRecord(walkRecord);
        LoggerService.debug('✅ Provider 상태 업데이트 완료');

        return walkRecord;
      },
      maxRetries: 2,
      errorMessage: '散歩記録の更新',
    );

    if (result != null) {
      LoggerService.debug('✅ 산책 기록 수정 완료 - ID: ${walkRecord.id}');
      return Result.success('散歩記録が更新されました', result);
    } else {
      LoggerService.debug('❌ 산책 기록 수정 실패 - ID: ${walkRecord.id}');
      return Result.failure('散歩記録の更新に失敗しました');
    }
  }

  /// 산책 일시정지
  Result<bool> pauseCurrentWalk() {
    try {
      ref.read(currentWalkProvider.notifier).pauseWalk();
      return Result.success('산책이 일시정지되었습니다', true);
    } catch (e) {
      return Result.failure('산책 일시정지에 실패했습니다: ${e.toString()}');
    }
  }

  /// 산책 재개
  Result<bool> resumeCurrentWalk() {
    try {
      ref.read(currentWalkProvider.notifier).resumeWalk();
      return Result.success('산책이 재개되었습니다', true);
    } catch (e) {
      return Result.failure('산책 재개에 실패했습니다: ${e.toString()}');
    }
  }

  /// 산책 기록 삭제
  Future<WalkResult> deleteWalkRecord(String recordId) async {
    LoggerService.debug(
      '🔄 WalkController: 산책 기록 삭제 (Hybrid Repository) - ID: $recordId',
    );

    final result = await safeExecute(() async {
      // Repository가 로컬 삭제 및 API 동기화 처리
      await _repository.deleteWalkRecord(recordId);

      // Provider에서도 제거
      ref.read(walkRecordsProvider.notifier).removeWalkRecord(recordId);

      LoggerService.debug('✅ 산책 기록 삭제 완료 - ID: $recordId');
      return true;
    }, errorMessage: '散歩記録の削除');

    if (result != null && result) {
      return Result.success('散歩記録が削除されました');
    } else {
      LoggerService.debug('❌ 산책 기록 삭제 실패 - ID: $recordId');
      return Result.failure('散歩記録の削除に失敗しました');
    }
  }

  /// 펫 선택 토글 (다중 선택 지원)
  Result<bool> togglePet(WalkPetInfo pet) {
    try {
      if (kDebugMode) {
        print('🔧 WalkController.togglePet 시작: ${pet.name} (${pet.id})');
      }

      ref.read(selectedPetsProvider.notifier).togglePet(pet);

      if (kDebugMode) {
        final current = ref.read(selectedPetsProvider);
        print('🔧 현재 선택된 펫: ${current.map((p) => p.name).join(', ')}');
      }

      final isSelected = ref
          .read(selectedPetsProvider)
          .any((p) => p.id == pet.id);
      return Result.success(
        isSelected ? '${pet.name}を選択しました' : '${pet.name}の選択を解除しました',
        true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ WalkController.togglePet 에러: $e');
      }
      return Result.failure('ペット選択に失敗しました: ${e.toString()}');
    }
  }

  /// 선택된 반려동물 설정 (기존 호환성)
  Result<bool> setSelectedPet(WalkPetInfo pet) {
    try {
      if (kDebugMode) {
        print('🔧 WalkController.setSelectedPet 시작: ${pet.name} (${pet.id})');
      }

      ref.read(selectedPetsProvider.notifier).setSelectedPet(pet);

      if (kDebugMode) {
        final current = ref.read(selectedPetsProvider);
        print('🔧 현재 Provider 값: ${current.map((p) => p.name).join(', ')}');
      }

      return Result.success('ペットが選択されました', true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ WalkController.setSelectedPet 에러: $e');
      }
      return Result.failure('ペット선택에 실패했습니다: ${e.toString()}');
    }
  }

  /// 지도 확장 상태 토글
  Result<bool> toggleMapExpanded() {
    try {
      ref.read(mapExpandedProvider.notifier).toggleExpanded();
      return Result.success('地図の拡大状態が変更されました', true);
    } catch (e) {
      return Result.failure('지도 상태 변경에 실패했습니다: ${e.toString()}');
    }
  }

  /// 현재 진행 중인 산책 가져오기
  WalkRecordEntity? getCurrentWalk() {
    return ref.read(currentWalkProvider);
  }

  /// 산책 기록 목록 가져오기
  List<WalkRecordEntity> getWalkRecords() {
    return ref.read(walkRecordsProvider);
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
      return Result.failure('반려동물 산책 기록 가져오기에 실패했습니다');
    }
  }

  /// 최근 산책 기록 가져오기
  List<WalkRecordEntity> getRecentWalkRecords({int limit = 10}) {
    return ref.read(walkRecordsProvider.notifier).getRecentWalkRecords();
  }

  /// 위치 정보 추가
  Result<bool> addLocationToCurrentWalk(WalkLocation location) {
    try {
      ref.read(currentWalkProvider.notifier).addLocationToCurrentWalk(location);
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
