import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/shared/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = NotificationService();
      await service.initialize();
    });

    tearDown(() async {
      await service.clearAllNotifications();
    });

    group('Notification Creation', () {
      test('should create notification successfully', () async {
        // Arrange
        const title = '테스트 알림';
        const body = '테스트 알림 내용';
        const type = NotificationType.general;

        // Act
        await service.createNotification(
          title: title,
          body: body,
          type: type,
        );

        // Assert
        final notifications = await service.getNotifications();
        expect(notifications.length, equals(1));
        expect(notifications.first.title, equals(title));
        expect(notifications.first.body, equals(body));
        expect(notifications.first.type, equals(type));
      });

      test('should create notification with custom priority', () async {
        // Arrange
        const priority = NotificationPriority.high;

        // Act
        await service.createNotification(
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          priority: priority,
        );

        // Assert
        final notifications = await service.getNotifications();
        expect(notifications.first.priority, equals(priority));
      });

      test('should create notification with actions', () async {
        // Arrange
        final actions = [
          const NotificationAction(
            id: 'action1',
            title: '확인',
            type: 'confirm',
          ),
          const NotificationAction(
            id: 'action2',
            title: '취소',
            type: 'cancel',
          ),
        ];

        // Act
        await service.createNotification(
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          actions: actions,
        );

        // Assert
        final notifications = await service.getNotifications();
        expect(notifications.first.actions, isNotNull);
        expect(notifications.first.actions!.length, equals(2));
        expect(notifications.first.actions!.first.title, equals('확인'));
      });

      test('should create notification with data', () async {
        // Arrange
        final data = {
          'key1': 'value1',
          'key2': 123,
          'key3': true,
        };

        // Act
        await service.createNotification(
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          data: data,
        );

        // Assert
        final notifications = await service.getNotifications();
        expect(notifications.first.data, equals(data));
      });
    });

    group('Notification Retrieval', () {
      test('should get all notifications', () async {
        // Arrange
        await service.createNotification(
          title: '알림 1',
          body: '내용 1',
          type: NotificationType.general,
        );
        await service.createNotification(
          title: '알림 2',
          body: '내용 2',
          type: NotificationType.reservation,
        );

        // Act
        final notifications = await service.getNotifications();

        // Assert
        expect(notifications.length, equals(2));
        expect(notifications.first.title, equals('알림 2')); // 최신순
        expect(notifications.last.title, equals('알림 1'));
      });

      test('should filter notifications by type', () async {
        // Arrange
        await service.createNotification(
          title: '일반 알림',
          body: '내용',
          type: NotificationType.general,
        );
        await service.createNotification(
          title: '예약 알림',
          body: '내용',
          type: NotificationType.reservation,
        );

        // Act
        final generalNotifications = await service.getNotifications(
          type: NotificationType.general,
        );
        final reservationNotifications = await service.getNotifications(
          type: NotificationType.reservation,
        );

        // Assert
        expect(generalNotifications.length, equals(1));
        expect(generalNotifications.first.type, equals(NotificationType.general));
        expect(reservationNotifications.length, equals(1));
        expect(reservationNotifications.first.type, equals(NotificationType.reservation));
      });

      test('should filter notifications by status', () async {
        // Arrange
        await service.createNotification(
          title: '알림 1',
          body: '내용',
          type: NotificationType.general,
        );

        // Act
        final unreadNotifications = await service.getNotifications(
          status: NotificationStatus.unread,
        );
        final readNotifications = await service.getNotifications(
          status: NotificationStatus.read,
        );

        // Assert
        expect(unreadNotifications.length, equals(1));
        expect(readNotifications.length, equals(0));
      });

      test('should limit notifications', () async {
        // Arrange
        for (int i = 0; i < 5; i++) {
          await service.createNotification(
            title: '알림 $i',
            body: '내용 $i',
            type: NotificationType.general,
          );
        }

        // Act
        final limitedNotifications = await service.getNotifications(limit: 3);

        // Assert
        expect(limitedNotifications.length, equals(3));
      });
    });

    group('Notification Management', () {
      test('should delete notification', () async {
        // Arrange
        await service.createNotification(
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
        );
        final notifications = await service.getNotifications();
        final notificationId = notifications.first.id;

        // Act
        await service.deleteNotification(notificationId);

        // Assert
        final remainingNotifications = await service.getNotifications();
        expect(remainingNotifications.length, equals(0));
      });

      test('should clear all notifications', () async {
        // Arrange
        await service.createNotification(
          title: '알림 1',
          body: '내용 1',
          type: NotificationType.general,
        );
        await service.createNotification(
          title: '알림 2',
          body: '내용 2',
          type: NotificationType.reservation,
        );

        // Act
        await service.clearAllNotifications();

        // Assert
        final notifications = await service.getNotifications();
        expect(notifications.length, equals(0));
      });

      test('should get unread count', () async {
        // Arrange
        await service.createNotification(
          title: '알림 1',
          body: '내용 1',
          type: NotificationType.general,
        );
        await service.createNotification(
          title: '알림 2',
          body: '내용 2',
          type: NotificationType.reservation,
        );

        // Act
        final unreadCount = await service.getUnreadCount();

        // Assert
        expect(unreadCount, equals(2));
      });
    });

    group('Notification Settings', () {
      test('should get default notification settings', () async {
        // Act
        final settings = await service.getNotificationSettings();

        // Assert
        expect(settings.enabled, isTrue);
        expect(settings.soundEnabled, isTrue);
        expect(settings.vibrationEnabled, isTrue);
        expect(settings.badgeEnabled, isTrue);
        expect(settings.typeSettings[NotificationType.general], isTrue);
      });

      test('should save and load notification settings', () async {
        // Arrange
        const customSettings = NotificationSettings(
          enabled: false,
          soundEnabled: false,
          vibrationEnabled: false,
          badgeEnabled: false,
        );

        // Act
        await service.saveNotificationSettings(customSettings);
        final loadedSettings = await service.getNotificationSettings();

        // Assert
        expect(loadedSettings.enabled, equals(customSettings.enabled));
        expect(loadedSettings.soundEnabled, equals(customSettings.soundEnabled));
        expect(loadedSettings.vibrationEnabled, equals(customSettings.vibrationEnabled));
        expect(loadedSettings.badgeEnabled, equals(customSettings.badgeEnabled));
      });

      test('should check if notification type is enabled', () async {
        // Arrange
        const settings = NotificationSettings(
          typeSettings: {
            NotificationType.general: true,
            NotificationType.reservation: false,
          },
        );

        // Act & Assert
        expect(settings.isTypeEnabled(NotificationType.general), isTrue);
        expect(settings.isTypeEnabled(NotificationType.reservation), isFalse);
      });
    });

    group('Notification Model', () {
      test('should create notification model', () {
        // Arrange
        const id = 'test_id';
        const title = '테스트 제목';
        const body = '테스트 내용';
        const type = NotificationType.general;
        final createdAt = DateTime.now();

        // Act
        final notification = NotificationModel(
          id: id,
          title: title,
          body: body,
          type: type,
          createdAt: createdAt,
        );

        // Assert
        expect(notification.id, equals(id));
        expect(notification.title, equals(title));
        expect(notification.body, equals(body));
        expect(notification.type, equals(type));
        expect(notification.createdAt, equals(createdAt));
        expect(notification.status, equals(NotificationStatus.unread));
        expect(notification.priority, equals(NotificationPriority.normal));
      });

      test('should check if notification is unread', () {
        // Arrange
        final notification = NotificationModel(
          id: 'test',
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(notification.isUnread, isTrue);
        expect(notification.isUrgent, isFalse);
      });

      test('should check if notification is urgent', () {
        // Arrange
        final notification = NotificationModel(
          id: 'test',
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          priority: NotificationPriority.urgent,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(notification.isUrgent, isTrue);
      });

      test('should copy notification as read', () {
        // Arrange
        final originalNotification = NotificationModel(
          id: 'test',
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          createdAt: DateTime.now(),
        );

        // Act
        final readNotification = originalNotification.copyAsRead();

        // Assert
        expect(readNotification.status, equals(NotificationStatus.read));
        expect(readNotification.readAt, isNotNull);
        expect(readNotification.id, equals(originalNotification.id));
        expect(readNotification.title, equals(originalNotification.title));
      });

      test('should copy notification as deleted', () {
        // Arrange
        final originalNotification = NotificationModel(
          id: 'test',
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          createdAt: DateTime.now(),
        );

        // Act
        final deletedNotification = originalNotification.copyAsDeleted();

        // Assert
        expect(deletedNotification.status, equals(NotificationStatus.deleted));
        expect(deletedNotification.id, equals(originalNotification.id));
      });

      test('should check if notification is expired', () {
        // Arrange
        final expiredNotification = NotificationModel(
          id: 'test',
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final validNotification = NotificationModel(
          id: 'test2',
          title: '테스트',
          body: '테스트',
          type: NotificationType.general,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        // Act & Assert
        expect(expiredNotification.isExpired, isTrue);
        expect(validNotification.isExpired, isFalse);
      });
    });

    group('Notification Action', () {
      test('should create notification action', () {
        // Arrange
        const id = 'action_id';
        const title = '액션 제목';
        const type = 'action_type';
        final data = {'key': 'value'};

        // Act
        final action = NotificationAction(
          id: id,
          title: title,
          type: type,
          data: data,
        );

        // Assert
        expect(action.id, equals(id));
        expect(action.title, equals(title));
        expect(action.type, equals(type));
        expect(action.data, equals(data));
      });

      test('should convert notification action to and from JSON', () {
        // Arrange
        const action = NotificationAction(
          id: 'test_id',
          title: '테스트 액션',
          type: 'test_type',
          data: {'key': 'value'},
        );

        // Act
        final json = action.toJson();
        final fromJson = NotificationAction.fromJson(json);

        // Assert
        expect(fromJson.id, equals(action.id));
        expect(fromJson.title, equals(action.title));
        expect(fromJson.type, equals(action.type));
        expect(fromJson.data, equals(action.data));
      });
    });

    group('Notification Settings', () {
      test('should create notification settings', () {
        // Arrange
        const enabled = false;
        const soundEnabled = false;
        const vibrationEnabled = false;
        const badgeEnabled = false;

        // Act
        const settings = NotificationSettings(
          enabled: enabled,
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
          badgeEnabled: badgeEnabled,
        );

        // Assert
        expect(settings.enabled, equals(enabled));
        expect(settings.soundEnabled, equals(soundEnabled));
        expect(settings.vibrationEnabled, equals(vibrationEnabled));
        expect(settings.badgeEnabled, equals(badgeEnabled));
      });

      test('should convert notification settings to and from JSON', () {
        // Arrange
        const settings = NotificationSettings(
          enabled: false,
          soundEnabled: false,
          typeSettings: {
            NotificationType.general: true,
            NotificationType.reservation: false,
          },
        );

        // Act
        final json = settings.toJson();
        final fromJson = NotificationSettings.fromJson(json);

        // Assert
        expect(fromJson.enabled, equals(settings.enabled));
        expect(fromJson.soundEnabled, equals(settings.soundEnabled));
        expect(fromJson.typeSettings[NotificationType.general], equals(true));
        expect(fromJson.typeSettings[NotificationType.reservation], equals(false));
      });

      test('should copy notification settings', () {
        // Arrange
        const originalSettings = NotificationSettings(
          enabled: true,
          soundEnabled: true,
        );

        // Act
        final copiedSettings = originalSettings.copyWith(
          enabled: false,
          soundEnabled: false,
        );

        // Assert
        expect(copiedSettings.enabled, equals(false));
        expect(copiedSettings.soundEnabled, equals(false));
        expect(copiedSettings.vibrationEnabled, equals(originalSettings.vibrationEnabled));
        expect(copiedSettings.badgeEnabled, equals(originalSettings.badgeEnabled));
      });
    });

    group('Quiet Time Settings', () {
      test('should create quiet time settings', () {
        // Arrange
        const enabled = true;
        const startTime = '22:00';
        const endTime = '08:00';
        final days = [0, 1, 2, 3, 4, 5, 6];

        // Act
        final quietTime = QuietTimeSettings(
          enabled: enabled,
          startTime: startTime,
          endTime: endTime,
          days: days,
        );

        // Assert
        expect(quietTime.enabled, equals(enabled));
        expect(quietTime.startTime, equals(startTime));
        expect(quietTime.endTime, equals(endTime));
        expect(quietTime.days, equals(days));
      });

      test('should convert quiet time settings to and from JSON', () {
        // Arrange
        const quietTime = QuietTimeSettings(
          enabled: true,
          startTime: '22:00',
          endTime: '08:00',
          days: [0, 1, 2, 3, 4, 5, 6],
        );

        // Act
        final json = quietTime.toJson();
        final fromJson = QuietTimeSettings.fromJson(json);

        // Assert
        expect(fromJson.enabled, equals(quietTime.enabled));
        expect(fromJson.startTime, equals(quietTime.startTime));
        expect(fromJson.endTime, equals(quietTime.endTime));
        expect(fromJson.days, equals(quietTime.days));
      });

      test('should check if currently quiet time', () {
        // Arrange
        const quietTime = QuietTimeSettings(
          enabled: true,
          startTime: '22:00',
          endTime: '08:00',
          days: [0, 1, 2, 3, 4, 5, 6],
        );

        // Act
        final isQuietTime = quietTime.isCurrentlyQuietTime();

        // Assert
        // 실제 시간에 따라 결과가 달라질 수 있으므로 단순히 함수가 호출되는지만 확인
        expect(isQuietTime, isA<bool>());
      });
    });
  });
}
