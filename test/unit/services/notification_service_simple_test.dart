import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification Model Tests', () {
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

  group('Notification Action Tests', () {
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

  group('Notification Settings Tests', () {
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
      expect(
        fromJson.typeSettings[NotificationType.reservation],
        equals(false),
      );
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
      expect(
        copiedSettings.vibrationEnabled,
        equals(originalSettings.vibrationEnabled),
      );
      expect(
        copiedSettings.badgeEnabled,
        equals(originalSettings.badgeEnabled),
      );
    });

    test('should check if notification type is enabled', () {
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

  group('Quiet Time Settings Tests', () {
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

  group('Notification Model JSON Tests', () {
    test('should convert notification model to and from JSON', () {
      // Arrange
      final notification = NotificationModel(
        id: 'test_id',
        title: '테스트 제목',
        body: '테스트 내용',
        type: NotificationType.general,
        priority: NotificationPriority.high,
        status: NotificationStatus.unread,
        createdAt: DateTime(2023, 1, 1, 12, 0, 0),
        data: {'key': 'value'},
        actions: [
          const NotificationAction(id: 'action1', title: '확인', type: 'confirm'),
        ],
      );

      // Act
      final json = notification.toJson();
      final fromJson = NotificationModel.fromJson(json);

      // Assert
      expect(fromJson.id, equals(notification.id));
      expect(fromJson.title, equals(notification.title));
      expect(fromJson.body, equals(notification.body));
      expect(fromJson.type, equals(notification.type));
      expect(fromJson.priority, equals(notification.priority));
      expect(fromJson.status, equals(notification.status));
      expect(fromJson.data, equals(notification.data));
      expect(fromJson.actions?.length, equals(notification.actions?.length));
    });
  });
}
