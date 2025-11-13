import 'package:aipet_frontend/shared/shared.dart';

import '../entities/entities.dart';
import '../repositories/notification_repository.dart';

/// 알림 생성 UseCase
class CreateNotificationUseCase {
  final NotificationRepository repository;

  CreateNotificationUseCase(this.repository);

  /// 새로운 알림 생성
  Future<Result<NotificationModel>> call(NotificationModel notification) async {
    try {
      // 알림 데이터 검증
      if (!_validateNotification(notification)) {
        return Result.failure('通知データが無効です');
      }

      // 실제 구현에서는 repository에 createNotification 메서드가 필요
      // 현재는 mock 데이터로 처리
      final createdNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title,
        body: notification.body,
        type: notification.type,
        priority: notification.priority,
        status: NotificationStatus.unread,
        createdAt: DateTime.now(),
        data: notification.data,
        actions: notification.actions,
        imageUrl: notification.imageUrl,
        icon: notification.icon,
      );

      return Result.success('通知を作成しました', createdNotification);
    } catch (error) {
      return Result.failure('通知の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 예약 알림 생성
  Future<Result<NotificationModel>> createScheduledNotification(
    NotificationModel notification,
    DateTime scheduledTime,
  ) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        return Result.failure('予約時間は現在時刻より後である必要があります');
      }

      final scheduledNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title,
        body: notification.body,
        type: NotificationType.reminder,
        priority: notification.priority,
        status: NotificationStatus.unread,
        createdAt: DateTime.now(),
        expiresAt: scheduledTime,
        data: notification.data,
        actions: notification.actions,
        imageUrl: notification.imageUrl,
        icon: notification.icon,
      );

      return Result.success('予約通知を作成しました', scheduledNotification);
    } catch (error) {
      return Result.failure('予約通知の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 반복 알림 생성
  Future<Result<List<NotificationModel>>> createRecurringNotification(
    NotificationModel baseNotification,
    DateTime startDate,
    DateTime endDate,
    String recurrenceRule,
  ) async {
    try {
      if (startDate.isAfter(endDate)) {
        return Result.failure('開始日は終了日より前である必要があります');
      }

      final notifications = <NotificationModel>[];
      DateTime current = startDate;

      // 간단한 일별 반복 구현
      while (current.isBefore(endDate)) {
        final notification = NotificationModel(
          id: '${baseNotification.id}_${current.millisecondsSinceEpoch}',
          title: baseNotification.title,
          body: baseNotification.body,
          type: NotificationType.reminder,
          priority: baseNotification.priority,
          status: NotificationStatus.unread,
          createdAt: DateTime.now(),
          expiresAt: current,
          data: baseNotification.data,
          actions: baseNotification.actions,
          imageUrl: baseNotification.imageUrl,
          icon: baseNotification.icon,
        );
        notifications.add(notification);
        current = current.add(const Duration(days: 1));
      }

      return Result.success('繰り返し通知を作成しました', notifications);
    } catch (error) {
      return Result.failure('繰り返し通知の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 펫 관련 알림 생성
  Future<Result<NotificationModel>> createPetNotification(
    String petId,
    String petName,
    NotificationType type,
    String message,
    Map<String, dynamic>? data,
  ) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _getPetNotificationTitle(type, petName),
        body: message,
        type: type,
        priority: NotificationPriority.normal,
        status: NotificationStatus.unread,
        createdAt: DateTime.now(),
        data: {
          ...?data,
          'userId': 'current_user', // 실제로는 현재 사용자 ID
        },
      );

      return Result.success('ペット通知を作成しました', notification);
    } catch (error) {
      return Result.failure('ペット通知の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 건강 관련 알림 생성
  Future<Result<NotificationModel>> createHealthNotification(
    String petId,
    String petName,
    String healthType,
    String message,
  ) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '健康チェック - $petName',
        body: message,
        type: NotificationType.health,
        priority: NotificationPriority.normal,
        status: NotificationStatus.unread,
        createdAt: DateTime.now(),
        data: {
          'petId': petId,
          'petName': petName,
          'healthType': healthType,
          'userId': 'current_user',
        },
      );

      return Result.success('健康通知を作成しました', notification);
    } catch (error) {
      return Result.failure('健康通知の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 산책 관련 알림 생성
  Future<Result<NotificationModel>> createWalkNotification(
    String petId,
    String petName,
    String message,
  ) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '散歩 - $petName',
        body: message,
        type: NotificationType.walk,
        priority: NotificationPriority.normal,
        status: NotificationStatus.unread,
        createdAt: DateTime.now(),
        data: {'petId': petId, 'petName': petName, 'userId': 'current_user'},
      );

      return Result.success('散歩通知を作成しました', notification);
    } catch (error) {
      return Result.failure('散歩通知の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 데이터 검증
  bool _validateNotification(NotificationModel notification) {
    return notification.title.isNotEmpty &&
        notification.body.isNotEmpty &&
        notification.data?['userId'] != null;
  }

  /// 펫 알림 제목 생성
  String _getPetNotificationTitle(NotificationType type, String petName) {
    switch (type) {
      case NotificationType.health:
        return '健康チェック - $petName';
      case NotificationType.walk:
        return '散歩 - $petName';
      case NotificationType.feeding:
        return '餌やり - $petName';
      case NotificationType.reminder:
        return 'リマインダー - $petName';
      default:
        return '通知 - $petName';
    }
  }
}
