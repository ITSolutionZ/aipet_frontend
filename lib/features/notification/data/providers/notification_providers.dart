import 'package:aipet_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/scheduling/data/services/calendar_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

// Repository 프로바이더
@riverpod
NotificationRepositoryImpl notificationRepository(Ref ref) {
  return NotificationRepositoryImpl();
}

// 알림 목록 프로바이더 (캘린더 이벤트의 알람 데이터 사용)
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<List<NotificationModel>> build() async {
    // 캘린더 이벤트에서 알람이 설정된 이벤트만 가져오기
    final calendarEvents = await CalendarEventService.instance
        .getCalendarEvents();

    debugPrint('📅 캘린더 이벤트 총 개수: ${calendarEvents.length}');

    // 알람이 설정된 이벤트를 NotificationModel로 변환
    final notifications = <NotificationModel>[];

    for (final event in calendarEvents) {
      debugPrint(
        '📌 이벤트: ${event.title}, hasAlarm: ${event.hasAlarm}, alarmSettings 개수: ${event.alarmSettings.length}',
      );

      if (event.hasAlarm && event.alarmSettings.isNotEmpty) {
        // 각 알람 설정마다 알림 생성
        for (int i = 0; i < event.alarmSettings.length; i++) {
          final alarmSetting = event.alarmSettings[i];
          debugPrint(
            '  ⏰ 알람 $i: enabled=${alarmSetting.isEnabled}, minutesBefore=${alarmSetting.minutesBefore}',
          );

          if (alarmSetting.isEnabled) {
            final alarmTime = event.startTime.subtract(
              Duration(minutes: alarmSetting.minutesBefore),
            );

            notifications.add(
              NotificationModel(
                id: '${event.id}_alarm_$i',
                title: event.title,
                body:
                    alarmSetting.message ??
                    '${alarmSetting.minutesBefore}分前にお知らせします',
                type: _mapEventTypeToNotificationType(event.type),
                createdAt: event.createdAt ?? DateTime.now(),
                expiresAt: alarmTime.add(
                  const Duration(hours: 1),
                ), // 알람 시간 1시간 후 만료
                data: {
                  'userId': 'local_user',
                  'eventId': event.id,
                  'eventType': event.type.name,
                  'alarmIndex': i,
                  'alarmTime': alarmTime.toIso8601String(),
                  'petId': event.petId,
                  'petName': event.petName,
                },
              ),
            );
          }
        }
      }
    }

    // 알람 시간 순으로 정렬 (data에서 alarmTime 추출)
    notifications.sort((a, b) {
      final aAlarmTime = a.data?['alarmTime'] as String?;
      final bAlarmTime = b.data?['alarmTime'] as String?;

      if (aAlarmTime != null && bAlarmTime != null) {
        return DateTime.parse(aAlarmTime).compareTo(DateTime.parse(bAlarmTime));
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    debugPrint('🔔 생성된 알림 개수: ${notifications.length}');

    return notifications;
  }

  /// 캘린더 이벤트 타입을 알림 타입으로 매핑
  NotificationType _mapEventTypeToNotificationType(dynamic eventType) {
    final typeString = eventType.toString().split('.').last;
    switch (typeString) {
      case 'feeding':
        return NotificationType.feeding;
      case 'medication':
        return NotificationType.medication;
      case 'walking':
      case 'exercise':
        return NotificationType.walk;
      case 'veterinary':
        return NotificationType.health;
      default:
        return NotificationType.system;
    }
  }

  /// 알림 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return build();
    });
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    const String userId = 'local_user'; // 로컬 사용자 ID

    final result = await repository.markAsRead(
      userId: userId,
      notificationId: id,
      isRead: true,
    );

    if (result.isSuccess) {
      await refresh();
    } else {
      throw Exception('알림 읽음 처리 실패: ${result.error}');
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    const String userId = 'local_user'; // 로컬 사용자 ID

    final result = await repository.deleteNotification(
      userId: userId,
      notificationId: id,
    );

    if (result.isSuccess) {
      await refresh();
    } else {
      throw Exception('알림 삭제 실패: ${result.error}');
    }
  }
}

// 개별 알림 프로바이더
@riverpod
Future<NotificationModel?> notificationById(Ref ref, String id) async {
  final repository = ref.watch(notificationRepositoryProvider);
  const String userId = 'local_user'; // 로컬 사용자 ID

  final result = await repository.getNotificationById(
    userId: userId,
    notificationId: id,
  );

  if (result.isSuccess) {
    return result.dataOrNull;
  }
  return null; // 에러 발생 시 null 반환
}

// 읽지 않은 알림 개수 프로바이더
@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  const String userId = 'local_user'; // 로컬 사용자 ID

  final result = await repository.getNotificationStats(userId);
  if (result.isSuccess) {
    final stats = result.dataOrNull;
    return stats?['unreadCount'] ?? 0;
  }
  return 0;
}

// 알림 설정 프로바이더
@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    final repository = ref.watch(notificationRepositoryProvider);
    const String userId = 'local_user'; // 로컬 사용자 ID

    final result = await repository.getNotificationSettings(userId);
    if (result.isSuccess) {
      return result.dataOrNull ?? {};
    }
    throw Exception('알림 설정 조회 실패: ${result.error}');
  }

  /// 설정 저장
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final repository = ref.read(notificationRepositoryProvider);
    const String userId = 'local_user'; // 로컬 사용자 ID

    final result = await repository.updateNotificationSettings(
      userId: userId,
      settings: settings,
    );

    if (result.isSuccess) {
      state = AsyncValue.data(settings);
    } else {
      state = AsyncValue.error(
        Exception('설정 저장 실패: ${result.error}'),
        StackTrace.current,
      );
    }
  }
}
