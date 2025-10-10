import 'dart:convert';

import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_action_handler.dart';
import 'notification_local_operations.dart';

/// 알림 응답 처리 헬퍼
class NotificationResponseHelper {
  static const String _tag = 'NotificationResponseHelper';

  /// 알림 탭 응답 처리
  static void handleNotificationResponse(
    NotificationResponse response,
    Function(String) onDelete,
  ) {
    if (response.payload == null) return;

    try {
      final notificationData = jsonDecode(response.payload!);
      final notification = NotificationModel.fromJson(notificationData);

      // 액션 ID가 있는 경우 액션 처리
      if (response.actionId != null) {
        NotificationActionHandler.handleNotificationAction(
          notification,
          response.actionId!,
          NotificationLocalOperations.markAsRead,
          onDelete,
        );
      } else {
        // 일반 탭: 읽음 상태로 변경
        NotificationLocalOperations.markAsRead(notification.id);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 알림 응답 처리 실패: $e');
      }
    }
  }
}
