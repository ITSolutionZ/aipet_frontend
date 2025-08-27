import '../entities/walk_record_entity.dart';

/// 산책 기록 리포지토리 인터페이스
abstract class WalkRepository {
  /// 모든 산책 기록 조회
  Future<List<WalkRecordEntity>> getAllWalkRecords();

  /// 산책 기록 목록 가져오기
  Future<List<WalkRecordEntity>> getWalkRecords();

  /// 특정 산책 기록 조회
  Future<WalkRecordEntity?> getWalkRecordById(String recordId);

  /// 펫별 산책 기록 조회
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId);

  /// 현재 진행 중인 산책 조회
  Future<WalkRecordEntity?> getCurrentWalk();

  /// 산책 시작
  Future<WalkRecordEntity> startWalk(WalkRecordEntity walkRecord);

  /// 산책 기록 저장
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord);

  /// 산책 기록 수정
  Future<void> updateWalkRecord(WalkRecordEntity walkRecord);

  /// 산책 기록 삭제
  Future<void> deleteWalkRecord(String id);

  /// 산책 종료
  Future<WalkRecordEntity> endWalk(
    String recordId, {
    double? distance,
    String? notes,
  });

  /// 산책 통계 조회
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// 산책 통계 데이터
class WalkStatistics {
  final int totalWalks;
  final Duration totalDuration;
  final double totalDistance;
  final double averageDistance;
  final Duration averageDuration;
  final int completedWalks;
  final int cancelledWalks;

  const WalkStatistics({
    required this.totalWalks,
    required this.totalDuration,
    required this.totalDistance,
    required this.averageDistance,
    required this.averageDuration,
    required this.completedWalks,
    required this.cancelledWalks,
  });
}
