import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/walk_record_entity.dart';
import '../../domain/repositories/walk_repository.dart';

/// 산책 기록 관리 리포지토리 구현체
///
/// WalkRepository 인터페이스의 구체적인 구현을 제공합니다.
/// 현재는 메모리 기반 구현이며, 추후 API 연동으로 대체될 예정입니다.
class WalkRepositoryImpl implements WalkRepository {
  // 메모리 기반 데이터 저장소 (인스턴스 기반으로 변경하여 메모리 리크 방지)
  final List<WalkRecordEntity> _walkRecords = [];
  WalkRecordEntity? _currentWalk;
  bool _isInitialized = false;

  /// 테스트용: 메모리 데이터 초기화
  void clearData() {
    _walkRecords.clear();
    _currentWalk = null;
    _isInitialized = false;
  }

  /// 리소스 정리
  void dispose() {
    _walkRecords.clear();
    _currentWalk = null;
    _isInitialized = false;
  }

  /// 초기 목업 데이터 로드
  void _loadInitialMockData() {
    if (!_isInitialized && MockDataService.isEnabled) {
      _walkRecords.addAll(MockDataService.getMockWalkRecords());
      _isInitialized = true;
    }
  }

  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    _loadInitialMockData();
    return List.from(_walkRecords);
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecords() async {
    _loadInitialMockData();
    return List.from(_walkRecords);
  }

  @override
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
    _walkRecords.add(walkRecord);
  }

  @override
  Future<WalkRecordEntity?> getWalkRecordById(String recordId) async {
    try {
      return _walkRecords.firstWhere((record) => record.id == recordId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WalkRecordEntity>> getWalkRecordsByPetId(String petId) async {
    return _walkRecords.where((record) => record.petId == petId).toList();
  }

  Future<List<WalkRecordEntity>> getWalkRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _walkRecords
        .where(
          (record) =>
              record.startTime.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              record.startTime.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  Future<List<WalkRecordEntity>> getTodayWalkRecords() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _walkRecords
        .where(
          (record) =>
              record.startTime.isAfter(
                today.subtract(const Duration(seconds: 1)),
              ) &&
              record.startTime.isBefore(tomorrow),
        )
        .toList();
  }

  Future<List<WalkRecordEntity>> getThisWeekWalkRecords() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return getWalkRecordsByDateRange(startOfWeek, endOfWeek);
  }

  Future<List<WalkRecordEntity>> getThisMonthWalkRecords() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return getWalkRecordsByDateRange(startOfMonth, endOfMonth);
  }

  Future<WalkRecordEntity> createWalkRecord(WalkRecordEntity record) async {
    _walkRecords.add(record);
    return record;
  }

  @override
  Future<WalkRecordEntity> updateWalkRecord(WalkRecordEntity record) async {
    final index = _walkRecords.indexWhere((r) => r.id == record.id);
    if (index == -1) {
      throw Exception('산책 기록을 찾을 수 없습니다.');
    }

    _walkRecords[index] = record;
    return record;
  }

  @override
  Future<void> deleteWalkRecord(String recordId) async {
    _walkRecords.removeWhere((record) => record.id == recordId);
  }

  @override
  Future<WalkRecordEntity?> getCurrentWalk() async {
    return _currentWalk;
  }

  @override
  Future<WalkRecordEntity> startWalk(WalkRecordEntity record) async {
    final walkRecord = record.copyWith(
      status: WalkStatus.inProgress,
      createdAt: DateTime.now(),
    );

    _currentWalk = walkRecord;
    _walkRecords.add(walkRecord);
    return walkRecord;
  }

  @override
  Future<WalkRecordEntity> endWalk(
    String recordId, {
    double? distance,
    String? notes,
  }) async {
    final index = _walkRecords.indexWhere((r) => r.id == recordId);
    if (index == -1) {
      throw Exception('散歩記録を見つけることができませんでした。');
    }

    final record = _walkRecords[index];
    final endTime = DateTime.now();
    final duration = endTime.difference(record.startTime);

    final updatedRecord = record.copyWith(
      endTime: endTime,
      duration: duration,
      distance: distance,
      notes: notes,
      status: WalkStatus.completed,
      updatedAt: DateTime.now(),
    );

    _walkRecords[index] = updatedRecord;
    if (_currentWalk?.id == recordId) {
      _currentWalk = null;
    }

    return updatedRecord;
  }

  Future<WalkRecordEntity> pauseWalk(String recordId) async {
    final index = _walkRecords.indexWhere((r) => r.id == recordId);
    if (index == -1) {
      throw Exception('散歩記録を見つけることができませんでした。');
    }

    final record = _walkRecords[index];
    final updatedRecord = record.copyWith(
      status: WalkStatus.paused,
      updatedAt: DateTime.now(),
    );

    _walkRecords[index] = updatedRecord;
    if (_currentWalk?.id == recordId) {
      _currentWalk = updatedRecord;
    }

    return updatedRecord;
  }

  Future<WalkRecordEntity> resumeWalk(String recordId) async {
    final index = _walkRecords.indexWhere((r) => r.id == recordId);
    if (index == -1) {
      throw Exception('散歩記録を見つけることができませんでした。');
    }

    final record = _walkRecords[index];
    final updatedRecord = record.copyWith(
      status: WalkStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    _walkRecords[index] = updatedRecord;
    if (_currentWalk?.id == recordId) {
      _currentWalk = updatedRecord;
    }

    return updatedRecord;
  }

  Future<WalkRecordEntity> addLocationToWalk(
    String recordId,
    WalkLocation location,
  ) async {
    final index = _walkRecords.indexWhere((r) => r.id == recordId);
    if (index == -1) {
      throw Exception('散歩記録を見つけることができませんでした。');
    }

    final record = _walkRecords[index];
    final updatedRoute = [...record.route, location];
    final updatedRecord = record.copyWith(
      route: updatedRoute,
      updatedAt: DateTime.now(),
    );

    _walkRecords[index] = updatedRecord;
    if (_currentWalk?.id == recordId) {
      _currentWalk = updatedRecord;
    }

    return updatedRecord;
  }

  @override
  Future<WalkStatistics> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<WalkRecordEntity> records = _walkRecords;

    // 펫 ID로 필터링
    if (petId != null) {
      records = records.where((r) => r.petId == petId).toList();
    }

    // 날짜 범위로 필터링
    if (startDate != null && endDate != null) {
      records = records
          .where(
            (r) =>
                r.startTime.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                r.startTime.isBefore(endDate.add(const Duration(days: 1))),
          )
          .toList();
    }

    final totalWalks = records.length;
    final completedWalks = records
        .where((r) => r.status == WalkStatus.completed)
        .length;
    final cancelledWalks = records
        .where((r) => r.status == WalkStatus.cancelled)
        .length;

    final totalDuration = records
        .where((r) => r.duration != null)
        .fold<Duration>(Duration.zero, (sum, record) => sum + record.duration!);

    final totalDistance = records
        .where((r) => r.distance != null)
        .fold<double>(0.0, (sum, record) => sum + record.distance!);

    final averageDistance = totalWalks > 0 ? totalDistance / totalWalks : 0.0;
    final averageDuration = totalWalks > 0
        ? Duration(milliseconds: totalDuration.inMilliseconds ~/ totalWalks)
        : Duration.zero;

    return WalkStatistics(
      totalWalks: totalWalks,
      totalDuration: totalDuration,
      totalDistance: totalDistance,
      averageDistance: averageDistance,
      averageDuration: averageDuration,
      completedWalks: completedWalks,
      cancelledWalks: cancelledWalks,
    );
  }

  Future<List<WalkRecordEntity>> searchWalkRecords(String query) async {
    if (query.isEmpty) return getAllWalkRecords();

    return _walkRecords
        .where(
          (record) =>
              record.title.toLowerCase().contains(query.toLowerCase()) ||
              (record.petName?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }
}
