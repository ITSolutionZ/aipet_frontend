import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notification_by_id_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../repositories/notification_repository_impl.dart';

part 'notification_providers.g.dart';

// Repository 프로바이더
@riverpod
NotificationRepositoryImpl notificationRepository(Ref ref) {
  return NotificationRepositoryImpl();
}

// UseCase 프로바이더들
@riverpod
GetNotificationsUseCase getNotificationsUseCase(Ref ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetNotificationsUseCase(repository);
}

@riverpod
GetNotificationByIdUseCase getNotificationByIdUseCase(Ref ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetNotificationByIdUseCase(repository);
}

@riverpod
MarkNotificationAsReadUseCase markNotificationAsReadUseCase(Ref ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return MarkNotificationAsReadUseCase(repository);
}

@riverpod
DeleteNotificationUseCase deleteNotificationUseCase(Ref ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return DeleteNotificationUseCase(repository);
}

// 알림 목록 프로바이더
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<List<NotificationModel>> build() async {
    final useCase = ref.watch(getNotificationsUseCaseProvider);
    return useCase();
  }

  /// 알림 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getNotificationsUseCaseProvider);
      return useCase();
    });
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    final useCase = ref.read(markNotificationAsReadUseCaseProvider);
    await useCase(id);
    await refresh();
  }

  /// 알림 삭제
  Future<void> deleteNotification(String id) async {
    final useCase = ref.read(deleteNotificationUseCaseProvider);
    await useCase(id);
    await refresh();
  }
}

// 개별 알림 프로바이더
@riverpod
Future<NotificationModel?> notificationById(Ref ref, String id) async {
  final useCase = ref.watch(getNotificationByIdUseCaseProvider);
  return useCase(id);
}

// 읽지 않은 알림 개수 프로바이더
@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
}

// 알림 설정 프로바이더
@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  Future<NotificationSettings> build() async {
    final repository = ref.watch(notificationRepositoryProvider);
    return repository.getNotificationSettings();
  }

  /// 설정 저장
  Future<void> saveSettings(NotificationSettings settings) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.saveNotificationSettings(settings);
    state = AsyncValue.data(settings);
  }

  /// 권한 요청
  Future<bool> requestPermission() async {
    final repository = ref.read(notificationRepositoryProvider);
    return repository.requestNotificationPermission();
  }

  /// 테스트 알림 전송
  Future<void> sendTestNotification() async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.sendTestNotification();
  }
}
