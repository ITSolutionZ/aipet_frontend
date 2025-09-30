import 'dart:async';
import 'dart:convert';

import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import 'notification_stats_factory.dart' as data_factory;

/// 알림 통계 분석 서비스
class NotificationAnalyticsService {
  static const String _statsKey = 'notification_stats';
  static const String _analyticsKey = 'notification_analytics';
  static const String _userEngagementKey = 'user_engagement';

  bool _isInitialized = false;

  // 통계 스트림
  final StreamController<List<NotificationStats>> _statsController =
      StreamController<List<NotificationStats>>.broadcast();

  final StreamController<NotificationAnalytics> _analyticsController =
      StreamController<NotificationAnalytics>.broadcast();

  final StreamController<List<UserEngagement>> _userEngagementController =
      StreamController<List<UserEngagement>>.broadcast();

  Stream<List<NotificationStats>> get statsStream => _statsController.stream;
  Stream<NotificationAnalytics> get analyticsStream => _analyticsController.stream;
  Stream<List<UserEngagement>> get userEngagementStream => _userEngagementController.stream;

  NotificationAnalyticsService();

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 모의 데이터가 없으면 생성
      final stats = await getStats();
      if (stats.isEmpty) {
        await _createMockData();
      }

      _isInitialized = true;
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모의 데이터 생성
  Future<void> _createMockData() async {
    try {
      // 모의 통계 데이터 생성 (데이터 레이어의 팩토리 사용)
      final mockStats = data_factory.NotificationStatsFactory.generateMockStats();
      await _saveStats(mockStats);
      _statsController.add(mockStats);

      // 모의 사용자 참여도 데이터 생성
      final mockUserEngagement = data_factory.NotificationStatsFactory.generateMockUserEngagement();
      await _saveUserEngagement(mockUserEngagement);
      _userEngagementController.add(mockUserEngagement);

      // 분석 데이터 생성
      final analytics = await _createAnalytics(mockStats);
      await _saveAnalytics(analytics);
      _analyticsController.add(analytics);

      if (kDebugMode) {
        debugPrint(
          '모의 통계 데이터 생성 완료: ${mockStats.length}개 통계, ${mockUserEngagement.length}개 사용자 참여도',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('통계 데이터 생성 실패: $e');
      }
    }
  }

  /// 통계 추가
  Future<void> addStats(NotificationStats stats) async {
    try {
      final allStats = await getStats();
      allStats.add(stats);
      await _saveStats(allStats);
      _statsController.add(allStats);

      // 분석 업데이트
      final analytics = await _createAnalytics(allStats);
      await _saveAnalytics(analytics);
      _analyticsController.add(analytics);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 통계 업데이트
  Future<void> updateStats(NotificationStats stats) async {
    try {
      final allStats = await getStats();
      final index = allStats.indexWhere((s) => s.id == stats.id);

      if (index != -1) {
        allStats[index] = stats;
        await _saveStats(allStats);
        _statsController.add(allStats);

        // 분석 업데이트
        final analytics = await _createAnalytics(allStats);
        await _saveAnalytics(analytics);
        _analyticsController.add(analytics);

        if (kDebugMode) {}
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 통계 삭제
  Future<void> deleteStats(String statsId) async {
    try {
      final allStats = await getStats();
      allStats.removeWhere((s) => s.id == statsId);
      await _saveStats(allStats);
      _statsController.add(allStats);

      // 분석 업데이트
      final analytics = await _createAnalytics(allStats);
      await _saveAnalytics(analytics);
      _analyticsController.add(analytics);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모든 통계 가져오기
  Future<List<NotificationStats>> getStats() async {
    try {
      final statsJson = await SecureStorageService.getString(_statsKey);
      if (statsJson != null) {
        final List<dynamic> statsList = jsonDecode(statsJson);
        return statsList.map((json) => NotificationStats.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {}
    }
    return [];
  }

  /// 특정 기간의 통계 가져오기
  Future<List<NotificationStats>> getStatsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allStats = await getStats();
      return allStats.where((stat) {
        return stat.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            stat.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      if (kDebugMode) {}
      return [];
    }
  }

  /// 특정 타입의 통계 가져오기
  Future<List<NotificationStats>> getStatsByType(NotificationType type) async {
    try {
      final allStats = await getStats();
      return allStats.where((stat) => stat.type == type).toList();
    } catch (e) {
      if (kDebugMode) {}
      return [];
    }
  }

  /// 분석 데이터 생성
  Future<NotificationAnalytics> _createAnalytics(List<NotificationStats> stats) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final endDate = now;

      // 타입별 통계 그룹화
      final statsByType = <NotificationType, List<NotificationStats>>{};
      for (final stat in stats) {
        if (!statsByType.containsKey(stat.type)) {
          statsByType[stat.type] = [];
        }
        statsByType[stat.type]!.add(stat);
      }

      // 요약 생성
      final summary = _generateSummary(stats);

      return NotificationAnalytics(
        id: 'analytics_${now.millisecondsSinceEpoch}',
        startDate: startDate,
        endDate: endDate,
        stats: stats,
        statsByType: statsByType,
        summary: summary,
      );
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// 분석 데이터 가져오기
  Future<NotificationAnalytics?> getAnalytics() async {
    try {
      final analyticsJson = await SecureStorageService.getString(_analyticsKey);
      if (analyticsJson != null) {
        final analyticsData = jsonDecode(analyticsJson);
        return NotificationAnalytics.fromJson(analyticsData);
      }
    } catch (e) {
      if (kDebugMode) {}
    }
    return null;
  }

  /// 사용자 참여도 데이터 가져오기
  Future<List<UserEngagement>> getUserEngagement() async {
    try {
      final engagementJson = await SecureStorageService.getString(_userEngagementKey);
      if (engagementJson != null) {
        final List<dynamic> engagementList = jsonDecode(engagementJson);
        return engagementList.map((json) => UserEngagement.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {}
    }
    return [];
  }

  /// 사용자 참여도 추가
  Future<void> addUserEngagement(UserEngagement engagement) async {
    try {
      final allEngagement = await getUserEngagement();
      allEngagement.add(engagement);
      await _saveUserEngagement(allEngagement);
      _userEngagementController.add(allEngagement);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 통계 요약 가져오기
  Future<Map<String, double>> getSummary() async {
    try {
      final analytics = await getAnalytics();
      return analytics?.summary ?? {};
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 성과 지표 가져오기
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final analytics = await getAnalytics();
      if (analytics == null) return {};

      return {
        'totalSent': analytics.totalSent,
        'totalOpened': analytics.totalOpened,
        'totalClicked': analytics.totalClicked,
        'averageOpenRate': analytics.averageOpenRate,
        'averageClickRate': analytics.averageClickRate,
        'averageEngagementRate': analytics.averageEngagementRate,
        'bestPerformingType': analytics.bestPerformingType?.name,
        'period':
            '${analytics.startDate.toString().substring(0, 10)} ~ ${analytics.endDate.toString().substring(0, 10)}',
      };
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 트렌드 분석 가져오기
  Future<Map<String, dynamic>> getTrendAnalysis() async {
    try {
      final stats = await getStats();
      if (stats.isEmpty) return {};

      // 최근 7일 vs 이전 7일 비교
      final now = DateTime.now();
      final recentStats = stats
          .where((s) => s.date.isAfter(now.subtract(const Duration(days: 7))))
          .toList();

      final previousStats = stats
          .where(
            (s) =>
                s.date.isAfter(now.subtract(const Duration(days: 14))) &&
                s.date.isBefore(now.subtract(const Duration(days: 7))),
          )
          .toList();

      final recentSummary = _generateSummary(recentStats);
      final previousSummary = _generateSummary(previousStats);

      return {
        'recent': recentSummary,
        'previous': previousSummary,
        'trend': {
          'openRateChange': _calculateChange(
            recentSummary['averageOpenRate'] ?? 0.0,
            previousSummary['averageOpenRate'] ?? 0.0,
          ),
          'clickRateChange': _calculateChange(
            recentSummary['averageClickRate'] ?? 0.0,
            previousSummary['averageClickRate'] ?? 0.0,
          ),
          'engagementRateChange': _calculateChange(
            recentSummary['totalEngagementRate'] ?? 0.0,
            previousSummary['totalEngagementRate'] ?? 0.0,
          ),
        },
      };
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 변화율 계산
  double _calculateChange(double current, double previous) {
    if (previous == 0.0) return current > 0.0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100.0;
  }

  /// 통계 요약 생성 (data layer에서 구현)
  Map<String, double> _generateSummary(List<NotificationStats> stats) {
    if (stats.isEmpty) return {};

    final totalSent = stats.fold<int>(0, (sum, stat) => sum + stat.sentCount);
    final totalOpened = stats.fold<int>(0, (sum, stat) => sum + stat.openedCount);
    final totalClicked = stats.fold<int>(0, (sum, stat) => sum + stat.clickedCount);
    final totalDismissed = stats.fold<int>(0, (sum, stat) => sum + stat.dismissedCount);

    final openRate = totalSent > 0 ? (totalOpened / totalSent) * 100 : 0.0;
    final clickRate = totalOpened > 0 ? (totalClicked / totalOpened) * 100 : 0.0;
    final engagementRate = totalSent > 0 ? ((totalOpened + totalClicked) / totalSent) * 100 : 0.0;

    return {
      'totalSent': totalSent.toDouble(),
      'totalOpened': totalOpened.toDouble(),
      'totalClicked': totalClicked.toDouble(),
      'totalDismissed': totalDismissed.toDouble(),
      'averageOpenRate': openRate,
      'averageClickRate': clickRate,
      'totalEngagementRate': engagementRate,
    };
  }

  /// 통계 저장
  Future<void> _saveStats(List<NotificationStats> stats) async {
    try {
      final statsJson = jsonEncode(stats.map((s) => s.toJson()).toList());
      await SecureStorageService.setString(_statsKey, statsJson);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 분석 데이터 저장
  Future<void> _saveAnalytics(NotificationAnalytics analytics) async {
    try {
      final analyticsJson = jsonEncode(analytics.toJson());
      await SecureStorageService.setString(_analyticsKey, analyticsJson);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 사용자 참여도 저장
  Future<void> _saveUserEngagement(List<UserEngagement> engagement) async {
    try {
      final engagementJson = jsonEncode(engagement.map((e) => e.toJson()).toList());
      await SecureStorageService.setString(_userEngagementKey, engagementJson);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAllData() async {
    try {
      await SecureStorageService.remove(_statsKey);
      await SecureStorageService.remove(_analyticsKey);
      await SecureStorageService.remove(_userEngagementKey);

      _statsController.add([]);
      _analyticsController.add(
        NotificationAnalytics(
          id: 'empty',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          stats: [],
          statsByType: {},
          summary: {},
        ),
      );
      _userEngagementController.add([]);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 리소스 정리
  void dispose() {
    _statsController.close();
    _analyticsController.close();
    _userEngagementController.close();
  }
}
