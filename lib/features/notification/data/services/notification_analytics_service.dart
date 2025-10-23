import 'dart:async';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import 'package:flutter/foundation.dart';

import '../../domain/domain.dart';
import 'helpers/notification_analytics_calculator_helper.dart';
import 'helpers/notification_analytics_storage_helper.dart';
import 'helpers/notification_analytics_trend_helper.dart';
import 'notification_stats_factory.dart' as data_factory;

/// 알림 통계 분석 서비스
class NotificationAnalyticsService {
  bool _isInitialized = false;

  // 통계 스트림
  final StreamController<List<NotificationStats>> _statsController =
      StreamController<List<NotificationStats>>.broadcast();

  final StreamController<NotificationAnalytics> _analyticsController =
      StreamController<NotificationAnalytics>.broadcast();

  final StreamController<List<UserEngagement>> _userEngagementController =
      StreamController<List<UserEngagement>>.broadcast();

  Stream<List<NotificationStats>> get statsStream => _statsController.stream;
  Stream<NotificationAnalytics> get analyticsStream =>
      _analyticsController.stream;
  Stream<List<UserEngagement>> get userEngagementStream =>
      _userEngagementController.stream;

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
      final mockStats =
          await data_factory.NotificationStatsFactory.generateMockStats();
      await NotificationAnalyticsStorageHelper.saveStats(mockStats);
      _statsController.add(mockStats);

      // 모의 사용자 참여도 데이터 생성
      final mockUserEngagement = await data_factory
          .NotificationStatsFactory.generateMockUserEngagement();
      await NotificationAnalyticsStorageHelper.saveUserEngagement(
        mockUserEngagement,
      );
      _userEngagementController.add(mockUserEngagement);

      // 분석 데이터 생성
      final analytics = NotificationAnalyticsCalculatorHelper.createAnalytics(
        mockStats,
      );
      await NotificationAnalyticsStorageHelper.saveAnalytics(analytics);
      _analyticsController.add(analytics);

      if (kDebugMode) {
        LoggerService.debug(
          '모의 통계 데이터 생성 완료: ${mockStats.length}개 통계, ${mockUserEngagement.length}개 사용자 참여도',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('통계 데이터 생성 실패: $e');
      }
    }
  }

  /// 통계 추가
  Future<void> addStats(NotificationStats stats) async {
    try {
      final allStats = await getStats();
      allStats.add(stats);
      await NotificationAnalyticsStorageHelper.saveStats(allStats);
      _statsController.add(allStats);

      // 분석 업데이트
      final analytics = NotificationAnalyticsCalculatorHelper.createAnalytics(
        allStats,
      );
      await NotificationAnalyticsStorageHelper.saveAnalytics(analytics);
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
        await NotificationAnalyticsStorageHelper.saveStats(allStats);
        _statsController.add(allStats);

        // 분석 업데이트
        final analytics = NotificationAnalyticsCalculatorHelper.createAnalytics(
          allStats,
        );
        await NotificationAnalyticsStorageHelper.saveAnalytics(analytics);
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
      await NotificationAnalyticsStorageHelper.saveStats(allStats);
      _statsController.add(allStats);

      // 분석 업데이트
      final analytics = NotificationAnalyticsCalculatorHelper.createAnalytics(
        allStats,
      );
      await NotificationAnalyticsStorageHelper.saveAnalytics(analytics);
      _analyticsController.add(analytics);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모든 통계 가져오기
  Future<List<NotificationStats>> getStats() async {
    return NotificationAnalyticsStorageHelper.getStats();
  }

  /// 특정 기간의 통계 가져오기
  Future<List<NotificationStats>> getStatsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allStats = await getStats();
      return NotificationAnalyticsCalculatorHelper.filterByDateRange(
        allStats,
        startDate,
        endDate,
      );
    } catch (e) {
      if (kDebugMode) {}
      return [];
    }
  }

  /// 특정 타입의 통계 가져오기
  Future<List<NotificationStats>> getStatsByType(NotificationType type) async {
    try {
      final allStats = await getStats();
      return NotificationAnalyticsCalculatorHelper.filterByType(allStats, type);
    } catch (e) {
      if (kDebugMode) {}
      return [];
    }
  }

  /// 분석 데이터 가져오기
  Future<NotificationAnalytics?> getAnalytics() async {
    return NotificationAnalyticsStorageHelper.getAnalytics();
  }

  /// 사용자 참여도 데이터 가져오기
  Future<List<UserEngagement>> getUserEngagement() async {
    return NotificationAnalyticsStorageHelper.getUserEngagement();
  }

  /// 사용자 참여도 추가
  Future<void> addUserEngagement(UserEngagement engagement) async {
    try {
      final allEngagement = await getUserEngagement();
      allEngagement.add(engagement);
      await NotificationAnalyticsStorageHelper.saveUserEngagement(
        allEngagement,
      );
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

      return NotificationAnalyticsCalculatorHelper.createPerformanceMetrics(
        analytics,
      );
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 트렌드 분석 가져오기
  Future<Map<String, dynamic>> getTrendAnalysis() async {
    try {
      final stats = await getStats();
      return NotificationAnalyticsTrendHelper.createTrendAnalysis(stats);
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAllData() async {
    try {
      await NotificationAnalyticsStorageHelper.clearAllData();

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
