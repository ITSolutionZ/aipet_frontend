import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import '../repositories/notification_repository_impl.dart';

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
    // TODO: 캘린더 이벤트 연동 (추후 구현)
    // 현재는 빈 리스트 반환
    debugPrint('🔔 알림 리스트 로드 (현재는 빈 리스트)');
    
    return [];
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
