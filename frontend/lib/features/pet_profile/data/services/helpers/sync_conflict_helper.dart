import '../../../../../shared/shared.dart';

import '../pet_sync_service.dart';


/// 동기화 충돌 해결 헬퍼
class SyncConflictHelper {
  /// 충돌 해결
  static Future<void> resolveConflicts(List<PetProfileEntity> pets) async {
    final conflictResolutionStrategy = await getConflictResolutionStrategy();

    switch (conflictResolutionStrategy) {
      case ConflictResolution.remoteWins:
        break;
      case ConflictResolution.localWins:
        break;
      case ConflictResolution.lastModifiedWins:
        pets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
  }

  /// 충돌 해결 전략 가져오기
  static Future<ConflictResolution> getConflictResolutionStrategy() async {
    try {
      final strategy = await SecureStorageService.getString(
        'conflict_resolution_strategy',
      );
      switch (strategy) {
        case 'remote_wins':
          return ConflictResolution.remoteWins;
        case 'local_wins':
          return ConflictResolution.localWins;
        case 'last_modified_wins':
        default:
          return ConflictResolution.lastModifiedWins;
      }
    } catch (e) {
      return ConflictResolution.lastModifiedWins;
    }
  }
}
