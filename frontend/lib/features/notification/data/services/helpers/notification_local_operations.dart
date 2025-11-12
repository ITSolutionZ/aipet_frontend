import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';

/// 알림 로컬 작업 헬퍼
class NotificationLocalOperations {
  static const String _tag = 'NotificationLocalOperations';
  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  static const String _notificationsKey = 'notifications';

  /// 알림 저장 (로그만 기록)
  static Future<void> saveNotification(NotificationModel notification) async {
    try {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] 📝 알림 수신 기록: ${notification.title}');
      }
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 알림 기록 중 오류: $error');
      }
    }
  }

  /// 알림 읽음 처리
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _init();
      final notificationsJson = _cache.getStringList(_notificationsKey) ?? [];

      final updatedNotifications = notificationsJson.map((json) {
        try {
          final notification = NotificationModel.fromJson(jsonDecode(json));
          if (notification.id == notificationId) {
            return jsonEncode(notification.copyAsRead().toJson());
          }
          return json;
        } catch (e) {
          return json;
        }
      }).toList();

      await _cache.setStringList(_notificationsKey, updatedNotifications);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 읽음 처리 실패: $e');
      }
    }
  }

  /// 알림 삭제
  static Future<void> deleteNotification(
    String notificationId,
    FlutterLocalNotificationsPlugin localNotifications,
  ) async {
    try {
      await _init();
      final notificationsJson = _cache.getStringList(_notificationsKey) ?? [];

      final updatedNotifications = notificationsJson.map((json) {
        try {
          final notification = NotificationModel.fromJson(jsonDecode(json));
          if (notification.id == notificationId) {
            return jsonEncode(notification.copyAsDeleted().toJson());
          }
          return json;
        } catch (e) {
          return json;
        }
      }).toList();

      await _cache.setStringList(_notificationsKey, updatedNotifications);

      // 로컬 알림도 취소 (ID가 숫자인 경우에만)
      try {
        final id = int.parse(notificationId);
        await localNotifications.cancel(id);
      } catch (e) {
        if (kDebugMode) {
          LoggerService.debug('[$_tag] ℹ️ 로컬 알림 취소 건너뛰기 (ID가 숫자가 아님)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 알림 삭제 실패: $e');
      }
    }
  }

  /// 모든 알림 삭제
  static Future<void> clearAllNotifications(
    FlutterLocalNotificationsPlugin localNotifications,
  ) async {
    try {
      await _init();
      await _cache.removeKey(_notificationsKey);
      await localNotifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 전체 알림 삭제 실패: $e');
      }
    }
  }

  /// 읽지 않은 알림 개수 가져오기
  static Future<int> getUnreadCount() async {
    try {
      await _init();
      final notificationsJson = _cache.getStringList(_notificationsKey) ?? [];

      int unreadCount = 0;
      for (final json in notificationsJson) {
        try {
          final notification = NotificationModel.fromJson(jsonDecode(json));
          if (notification.status == NotificationStatus.unread &&
              !notification.isExpired) {
            unreadCount++;
          }
        } catch (e) {
          // 파싱 실패한 알림은 무시
        }
      }

      return unreadCount;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 읽지 않은 알림 개수 조회 실패: $e');
      }
      return 0;
    }
  }
}
