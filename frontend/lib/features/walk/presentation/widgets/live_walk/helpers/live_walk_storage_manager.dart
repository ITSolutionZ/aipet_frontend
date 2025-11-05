import '../../../../../../shared/shared.dart';

import '../../../../../../../features/walk/data/services/local_walk_storage_service.dart';
import '../../../../../../../features/walk/domain/entities/walk_record_entity.dart';

/// Live Walk 저장 관리자
class LiveWalkStorageManager {
  /// 저장된 산책 불러오기
  static Future<WalkRecordEntity?> loadSavedWalk() async {
    try {
      final savedWalk = await LocalWalkStorageService.loadCurrentWalk();
      if (savedWalk != null && savedWalk.isActive) {
        LoggerService.debug('💾 저장된 산책 복원: ${savedWalk.id}');
        return savedWalk;
      }
      return null;
    } catch (e) {
      LoggerService.debug('❌ 저장된 산책 불러오기 실패: $e');
      return null;
    }
  }

  /// 현재 산책 저장
  static Future<void> saveCurrentWalk(WalkRecordEntity? walkRecord) async {
    try {
      if (walkRecord != null) {
        await LocalWalkStorageService.saveCurrentWalk(walkRecord);
        LoggerService.debug('💾 현재 산책 저장: ${walkRecord.id}');
      }
    } catch (e) {
      LoggerService.debug('❌ 현재 산책 저장 실패: $e');
    }
  }

  /// 완료된 산책 저장
  static Future<void> saveCompletedWalk(
    WalkRecordEntity walkRecord,
    double distanceInMeters,
  ) async {
    try {
      final completedWalk = walkRecord.copyWith(
        status: WalkStatus.completed,
        endTime: DateTime.now(),
        distance: distanceInMeters / 1000, // m -> km 변환
        updatedAt: DateTime.now(),
      );

      // 완료된 산책을 기록 목록에 추가
      await LocalWalkStorageService.addWalkRecord(completedWalk);

      // 현재 산책 제거
      await LocalWalkStorageService.saveCurrentWalk(null);

      LoggerService.debug('💾 산책 완료 저장: ${completedWalk.id}');
    } catch (e) {
      LoggerService.debug('❌ 완료된 산책 저장 실패: $e');
    }
  }

  /// 산책 취소
  static Future<void> cancelWalk() async {
    try {
      await LocalWalkStorageService.saveCurrentWalk(null);
      LoggerService.debug('💾 산책 취소됨');
    } catch (e) {
      LoggerService.debug('❌ 산책 취소 실패: $e');
    }
  }
}
