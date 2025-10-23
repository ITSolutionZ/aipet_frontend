import 'dart:convert';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/domain.dart';

/// 알림 분석 데이터 저장소 헬퍼
class NotificationAnalyticsStorageHelper {
  static const String _statsKey = 'notification_stats';
  static const String _analyticsKey = 'notification_analytics';
  static const String _userEngagementKey = 'user_engagement';

  /// 통계 저장
  static Future<void> saveStats(List<NotificationStats> stats) async {
    try {
      final statsJson = jsonEncode(stats.map((s) => s.toJson()).toList());
      await SecureStorageService.setString(_statsKey, statsJson);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('통계 저장 실패: $e');
      }
    }
  }

  /// 통계 조회
  static Future<List<NotificationStats>> getStats() async {
    try {
      final statsJson = await SecureStorageService.getString(_statsKey);
      if (statsJson != null) {
        final List<dynamic> statsList = jsonDecode(statsJson);
        return statsList
            .map((json) => NotificationStats.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('통계 조회 실패: $e');
      }
    }
    return [];
  }

  /// 분석 데이터 저장
  static Future<void> saveAnalytics(NotificationAnalytics analytics) async {
    try {
      final analyticsJson = jsonEncode(analytics.toJson());
      await SecureStorageService.setString(_analyticsKey, analyticsJson);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('분석 데이터 저장 실패: $e');
      }
    }
  }

  /// 분석 데이터 조회
  static Future<NotificationAnalytics?> getAnalytics() async {
    try {
      final analyticsJson = await SecureStorageService.getString(_analyticsKey);
      if (analyticsJson != null) {
        final analyticsData = jsonDecode(analyticsJson);
        return NotificationAnalytics.fromJson(analyticsData);
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('분석 데이터 조회 실패: $e');
      }
    }
    return null;
  }

  /// 사용자 참여도 저장
  static Future<void> saveUserEngagement(
    List<UserEngagement> engagement,
  ) async {
    try {
      final engagementJson = jsonEncode(
        engagement.map((e) => e.toJson()).toList(),
      );
      await SecureStorageService.setString(_userEngagementKey, engagementJson);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('사용자 참여도 저장 실패: $e');
      }
    }
  }

  /// 사용자 참여도 조회
  static Future<List<UserEngagement>> getUserEngagement() async {
    try {
      final engagementJson = await SecureStorageService.getString(
        _userEngagementKey,
      );
      if (engagementJson != null) {
        final List<dynamic> engagementList = jsonDecode(engagementJson);
        return engagementList
            .map((json) => UserEngagement.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('사용자 참여도 조회 실패: $e');
      }
    }
    return [];
  }

  /// 모든 데이터 삭제
  static Future<void> clearAllData() async {
    try {
      await SecureStorageService.remove(_statsKey);
      await SecureStorageService.remove(_analyticsKey);
      await SecureStorageService.remove(_userEngagementKey);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('데이터 삭제 실패: $e');
      }
    }
  }
}
