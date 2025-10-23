import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/notification_storage_defaults_helper.dart';

/// 알림 로컬 저장소 서비스
///
/// 알림, 알림 설정, 알림 통계를 SharedPreferences에 저장/관리합니다
class NotificationLocalStorageService {
  static const String _keyNotifications = 'notifications';
  static const String _keySettings = 'notification_settings';
  static const String _keyStats = 'notification_stats';
  static const String _keyUserEngagement = 'user_engagement';

  // ✅ SharedPreferences 인스턴스 재사용
  static SharedPreferences? _prefs;
  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 알림 가져오기
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      await _init();
      final notificationsJson = prefs.getStringList(_keyNotifications) ?? [];

      if (notificationsJson.isEmpty) {
        return await NotificationStorageDefaultsHelper.initializeDefaultNotifications(
          prefs,
          _keyNotifications,
        );
      }

      return notificationsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      LoggerService.debug('알림 로드 실패: $e');
      return [];
    }
  }

  /// 알림 추가
  static Future<void> addNotification(Map<String, dynamic> notification) async {
    try {
      await _init();
      final notifications = prefs.getStringList(_keyNotifications) ?? [];

      if (notification['id'] == null ||
          (notification['id'] as String).isEmpty) {
        notification['id'] =
            'notification-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (notification['createdAt'] == null) {
        notification['createdAt'] = DateTime.now().toIso8601String();
      }

      notifications.add(jsonEncode(notification));
      await prefs.setStringList(_keyNotifications, notifications);

      LoggerService.debug('알림 추가 성공: ${notification['id']}');
    } catch (e) {
      LoggerService.debug('알림 추가 실패: $e');
    }
  }

  /// 알림 업데이트
  static Future<void> updateNotification(
    Map<String, dynamic> notification,
  ) async {
    try {
      await _init();
      final notifications = prefs.getStringList(_keyNotifications) ?? [];

      final index = notifications.indexWhere((n) {
        final notificationData = jsonDecode(n) as Map<String, dynamic>;
        return notificationData['id'] == notification['id'];
      });

      if (index != -1) {
        notification['updatedAt'] = DateTime.now().toIso8601String();
        notifications[index] = jsonEncode(notification);
        await prefs.setStringList(_keyNotifications, notifications);
        LoggerService.debug('알림 업데이트 성공: ${notification['id']}');
      }
    } catch (e) {
      LoggerService.debug('알림 업데이트 실패: $e');
    }
  }

  /// 알림 삭제
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _init();
      final notifications = prefs.getStringList(_keyNotifications) ?? [];

      notifications.removeWhere((n) {
        final notificationData = jsonDecode(n) as Map<String, dynamic>;
        return notificationData['id'] == notificationId;
      });

      await prefs.setStringList(_keyNotifications, notifications);
      LoggerService.debug('알림 삭제 성공: $notificationId');
    } catch (e) {
      LoggerService.debug('알림 삭제 실패: $e');
    }
  }

  /// 모든 알림 삭제
  static Future<void> clearAllNotifications() async {
    try {
      await _init();
      await prefs.remove(_keyNotifications);
      LoggerService.debug('모든 알림 삭제 성공');
    } catch (e) {
      LoggerService.debug('모든 알림 삭제 실패: $e');
    }
  }

  /// 알림 설정 가져오기
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      await _init();
      final settingsJson = prefs.getString(_keySettings);

      if (settingsJson == null || settingsJson.isEmpty) {
        return await NotificationStorageDefaultsHelper.initializeDefaultSettings(
          prefs,
          _keySettings,
        );
      }

      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      LoggerService.debug('알림 설정 로드 실패: $e');
      await _init();
      return NotificationStorageDefaultsHelper.initializeDefaultSettings(
        prefs,
        _keySettings,
      );
    }
  }

  /// 알림 설정 저장
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _init();
      await prefs.setString(_keySettings, jsonEncode(settings));
      LoggerService.debug('알림 설정 저장 성공');
    } catch (e) {
      LoggerService.debug('알림 설정 저장 실패: $e');
    }
  }

  /// 알림 통계 가져오기
  static Future<List<Map<String, dynamic>>> getStats({int days = 30}) async {
    try {
      await _init();
      final statsJson = prefs.getStringList(_keyStats) ?? [];

      if (statsJson.isEmpty) {
        return await NotificationStorageDefaultsHelper.initializeDefaultStats(
          prefs,
          _keyStats,
          days: days,
        );
      }

      final stats = statsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      // 최근 n일 데이터만 반환
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return stats.where((stat) {
        final date = DateTime.parse(stat['date'] as String);
        return date.isAfter(cutoffDate);
      }).toList();
    } catch (e) {
      LoggerService.debug('알림 통계 로드 실패: $e');
      return [];
    }
  }

  /// 알림 통계 추가
  static Future<void> addStats(Map<String, dynamic> stats) async {
    try {
      await _init();
      final statsList = prefs.getStringList(_keyStats) ?? [];

      statsList.add(jsonEncode(stats));
      await prefs.setStringList(_keyStats, statsList);

      LoggerService.debug('알림 통계 추가 성공');
    } catch (e) {
      LoggerService.debug('알림 통계 추가 실패: $e');
    }
  }

  /// 사용자 참여도 가져오기
  static Future<List<Map<String, dynamic>>> getUserEngagement({
    int days = 30,
  }) async {
    try {
      await _init();
      final engagementJson = prefs.getStringList(_keyUserEngagement) ?? [];

      if (engagementJson.isEmpty) {
        return await NotificationStorageDefaultsHelper.initializeDefaultUserEngagement(
          prefs,
          _keyUserEngagement,
          days: days,
        );
      }

      final engagement = engagementJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      // 최근 n일 데이터만 반환
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return engagement.where((eng) {
        final date = DateTime.parse(eng['date'] as String);
        return date.isAfter(cutoffDate);
      }).toList();
    } catch (e) {
      LoggerService.debug('사용자 참여도 로드 실패: $e');
      return [];
    }
  }

  /// 사용자 참여도 추가
  static Future<void> addUserEngagement(Map<String, dynamic> engagement) async {
    try {
      await _init();
      final engagementList = prefs.getStringList(_keyUserEngagement) ?? [];

      engagementList.add(jsonEncode(engagement));
      await prefs.setStringList(_keyUserEngagement, engagementList);

      LoggerService.debug('사용자 참여도 추가 성공');
    } catch (e) {
      LoggerService.debug('사용자 참여도 추가 실패: $e');
    }
  }
}
