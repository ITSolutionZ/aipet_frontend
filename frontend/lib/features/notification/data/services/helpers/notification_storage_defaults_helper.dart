import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 알림 저장소 기본값 생성 헬퍼
class NotificationStorageDefaultsHelper {
  /// 초기 기본 알림 생성
  static Future<List<Map<String, dynamic>>> initializeDefaultNotifications(
    SharedPreferences prefs,
    String keyNotifications,
  ) async {
    final now = DateTime.now();

    final defaultNotifications = [
      {
        'id': 'notification-1',
        'title': '給餌時間です',
        'body': 'ペットの給餌時間になりました',
        'type': 'feeding',
        'priority': 'normal',
        'status': 'unread',
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'notification-2',
        'title': '散歩の時間です',
        'body': 'お散歩に行きましょう',
        'type': 'walk',
        'priority': 'normal',
        'status': 'unread',
        'createdAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'id': 'notification-3',
        'title': '健康チェック',
        'body': '定期健康チェックの時間です',
        'type': 'health',
        'priority': 'normal',
        'status': 'read',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    final notificationsJson = defaultNotifications
        .map((n) => jsonEncode(n))
        .toList();
    await prefs.setStringList(keyNotifications, notificationsJson);

    return defaultNotifications;
  }

  /// 초기 기본 설정 생성
  static Future<Map<String, dynamic>> initializeDefaultSettings(
    SharedPreferences prefs,
    String keySettings,
  ) async {
    final defaultSettings = {
      'isEnabled': true,
      'enabledTypes': {
        'feeding': true,
        'walk': true,
        'health': true,
        'medication': true,
        'reservation': true,
        'general': true,
        'system': true,
      },
      'quietTimeEnabled': false,
      'quietTimeStart': '22:00',
      'quietTimeEnd': '07:00',
      'soundEnabled': true,
      'vibrationEnabled': true,
      'badgeEnabled': true,
    };

    await prefs.setString(keySettings, jsonEncode(defaultSettings));

    return defaultSettings;
  }

  /// 초기 기본 통계 생성
  static Future<List<Map<String, dynamic>>> initializeDefaultStats(
    SharedPreferences prefs,
    String keyStats, {
    int days = 30,
  }) async {
    final stats = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final total = 3 + (i % 5);
      final read = (total * 0.7).round();

      stats.add({
        'date': date.toIso8601String(),
        'total': total,
        'read': read,
        'unread': total - read,
      });
    }

    final statsJson = stats.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList(keyStats, statsJson);

    return stats;
  }

  /// 초기 기본 사용자 참여도 생성
  static Future<List<Map<String, dynamic>>> initializeDefaultUserEngagement(
    SharedPreferences prefs,
    String keyUserEngagement, {
    int days = 30,
  }) async {
    final engagement = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final notificationsReceived = 3 + (i % 5);
      final notificationsRead = (notificationsReceived * 0.7).round();
      final actionsCompleted = (notificationsRead * 0.5).round();

      engagement.add({
        'date': date.toIso8601String(),
        'notificationsReceived': notificationsReceived,
        'notificationsRead': notificationsRead,
        'actionsCompleted': actionsCompleted,
      });
    }

    final engagementJson = engagement.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(keyUserEngagement, engagementJson);

    return engagement;
  }
}
