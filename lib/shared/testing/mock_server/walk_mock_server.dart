import 'package:aipet_frontend/shared/testing/mock_data/features/walk/walk_mock_service.dart';

/// Walk API Mock 서버
/// 개발 및 테스트 환경에서 실제 API 서버 없이 동작하도록 Mock 응답 제공
class WalkMockServer {
  static final WalkMockServer _instance = WalkMockServer._();
  static WalkMockServer get instance => _instance;

  WalkMockServer._();

  // Mock 데이터 저장소 (메모리)
  final List<Map<String, dynamic>> _walkRecords = [];
  Map<String, dynamic>? _currentWalk;

  /// 초기화 (Mock 데이터 로드)
  void initialize() {
    _walkRecords.clear();
    _walkRecords.addAll(WalkMockService.getMockWalkRecords());
  }

  /// 모든 산책 기록 조회
  Map<String, dynamic> getAllWalkRecords() {
    return {
      'success': true,
      'walks': _walkRecords,
      'total': _walkRecords.length,
    };
  }

  /// ID로 산책 기록 조회
  Map<String, dynamic> getWalkRecordById(String id) {
    try {
      final record = _walkRecords.firstWhere((r) => r['id'] == id);
      return {'success': true, 'walk': record};
    } catch (e) {
      return {'success': false, 'error': '산책 기록을 찾을 수 없습니다'};
    }
  }

  /// 펫별 산책 기록 조회
  Map<String, dynamic> getWalkRecordsByPetId(String petId) {
    final records = _walkRecords.where((r) => r['petId'] == petId).toList();
    return {'success': true, 'walks': records, 'total': records.length};
  }

  /// 산책 시작
  Map<String, dynamic> startWalk(Map<String, dynamic> walkData) {
    final now = DateTime.now();
    final newRecord = {
      ...walkData,
      'id': 'mock-${now.millisecondsSinceEpoch}',
      'status': 'inProgress',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    _walkRecords.add(newRecord);
    _currentWalk = newRecord;

    return {'success': true, 'walk': newRecord};
  }

  /// 산책 종료
  Map<String, dynamic> endWalk(String walkId, Map<String, dynamic> updateData) {
    try {
      final index = _walkRecords.indexWhere((r) => r['id'] == walkId);
      if (index == -1) {
        return {'success': false, 'error': '산책 기록을 찾을 수 없습니다'};
      }

      final record = _walkRecords[index];
      final updatedRecord = {
        ...record,
        ...updateData,
        'status': 'completed',
        'endTime': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      _walkRecords[index] = updatedRecord;
      _currentWalk = null;

      return {'success': true, 'walk': updatedRecord};
    } catch (e) {
      return {'success': false, 'error': '산책 종료 실패: ${e.toString()}'};
    }
  }

  /// 산책 기록 업데이트
  Map<String, dynamic> updateWalkRecord(
    String walkId,
    Map<String, dynamic> updateData,
  ) {
    try {
      final index = _walkRecords.indexWhere((r) => r['id'] == walkId);
      if (index == -1) {
        return {'success': false, 'error': '산책 기록을 찾을 수 없습니다'};
      }

      final record = _walkRecords[index];
      final updatedRecord = {
        ...record,
        ...updateData,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      _walkRecords[index] = updatedRecord;

      return {'success': true, 'walk': updatedRecord};
    } catch (e) {
      return {'success': false, 'error': '산책 기록 업데이트 실패: ${e.toString()}'};
    }
  }

  /// 산책 기록 삭제
  Map<String, dynamic> deleteWalkRecord(String walkId) {
    try {
      final index = _walkRecords.indexWhere((r) => r['id'] == walkId);
      if (index == -1) {
        return {'success': false, 'error': '산책 기록을 찾을 수 없습니다'};
      }

      _walkRecords.removeAt(index);

      return {'success': true, 'message': '산책 기록이 삭제되었습니다'};
    } catch (e) {
      return {'success': false, 'error': '산책 기록 삭제 실패: ${e.toString()}'};
    }
  }

  /// 현재 진행 중인 산책 조회
  Map<String, dynamic> getCurrentWalk() {
    if (_currentWalk != null) {
      return {'success': true, 'walk': _currentWalk};
    }

    // 메모리에 없으면 inProgress 상태인 것 찾기
    try {
      final currentWalk = _walkRecords.firstWhere(
        (r) => r['status'] == 'inProgress',
      );
      return {'success': true, 'walk': currentWalk};
    } catch (e) {
      return {
        'success': true,
        'walk': null, // 진행 중인 산책 없음
      };
    }
  }

  /// 산책 통계 조회
  Map<String, dynamic> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var records = _walkRecords;

    // 펫 필터링
    if (petId != null) {
      records = records.where((r) => r['petId'] == petId).toList();
    }

    // 날짜 필터링
    if (startDate != null || endDate != null) {
      records = records.where((r) {
        final startTime = DateTime.parse(r['startTime'] as String);
        if (startDate != null && startTime.isBefore(startDate)) return false;
        if (endDate != null && startTime.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // 통계 계산
    final totalWalks = records.length;
    final totalDistance = records.fold<double>(
      0.0,
      (sum, r) => sum + ((r['distance'] as num?)?.toDouble() ?? 0.0),
    );
    final totalDuration = records.fold<int>(0, (sum, r) {
      if (r['duration'] != null) {
        return sum + (r['duration'] as int);
      }
      return sum;
    });

    return {
      'success': true,
      'statistics': {
        'totalWalks': totalWalks,
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
        'averageDistance': totalWalks > 0 ? totalDistance / totalWalks : 0.0,
        'averageDuration': totalWalks > 0 ? totalDuration / totalWalks : 0,
      },
    };
  }

  /// Mock 서버 상태 초기화
  void reset() {
    _walkRecords.clear();
    _currentWalk = null;
    initialize();
  }
}
