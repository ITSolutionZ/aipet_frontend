import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../../../../features/notification/data/services/notification_service.dart';
import '../../../../../features/notification/domain/repositories/notification_repository.dart';
import '../../../../../features/notification/domain/usecases/notification_usecases.dart';
import '../../../../../features/notification/presentation/controllers/notification_controller.dart';
import '../../../../../features/notification/presentation/controllers/notification_detail_controller.dart';
import '../../../../../features/notification/presentation/controllers/notification_ui_controller.dart';

part 'notification_controller_providers.g.dart';

// Service Provider
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

// Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl();
}

// UseCase Providers
@riverpod
GetNotificationsUseCase getNotificationsUseCase(Ref ref) {
  return GetNotificationsUseCase(ref.read(notificationRepositoryProvider));
}

@riverpod
GetNotificationByIdUseCase getNotificationByIdUseCase(Ref ref) {
  return GetNotificationByIdUseCase(ref.read(notificationRepositoryProvider));
}

@riverpod
MarkNotificationAsReadUseCase markNotificationAsReadUseCase(Ref ref) {
  return MarkNotificationAsReadUseCase(
    ref.read(notificationRepositoryProvider),
  );
}

@riverpod
DeleteNotificationUseCase deleteNotificationUseCase(Ref ref) {
  return DeleteNotificationUseCase(ref.read(notificationRepositoryProvider));
}

@riverpod
GetNotificationSettingsUseCase getNotificationSettingsUseCase(Ref ref) {
  return GetNotificationSettingsUseCase(
    ref.read(notificationRepositoryProvider),
  );
}

@riverpod
SaveNotificationSettingsUseCase saveNotificationSettingsUseCase(Ref ref) {
  return SaveNotificationSettingsUseCase(
    ref.read(notificationRepositoryProvider),
  );
}

@riverpod
RequestNotificationPermissionUseCase requestNotificationPermissionUseCase(
  Ref ref,
) {
  return RequestNotificationPermissionUseCase(
    ref.read(notificationServiceProvider),
  );
}

@riverpod
TestNotificationUseCase testNotificationUseCase(Ref ref) {
  return TestNotificationUseCase(ref.read(notificationServiceProvider));
}

// Controller Factory Providers - Consumer에서 WidgetRef를 받아서 사용
final notificationControllerFactoryProvider =
    Provider.family<NotificationController, WidgetRef>((ref, widgetRef) {
      return NotificationController(
        widgetRef,
        ref.read(getNotificationsUseCaseProvider),
        ref.read(getNotificationByIdUseCaseProvider),
        ref.read(markNotificationAsReadUseCaseProvider),
        ref.read(deleteNotificationUseCaseProvider),
        ref.read(getNotificationSettingsUseCaseProvider),
        ref.read(saveNotificationSettingsUseCaseProvider),
        ref.read(requestNotificationPermissionUseCaseProvider),
        ref.read(testNotificationUseCaseProvider),
      );
    });

final notificationDetailControllerFactoryProvider =
    Provider.family<NotificationDetailController, WidgetRef>((ref, widgetRef) {
      final uiController = NotificationUIController(widgetRef);
      return NotificationDetailController(
        uiController,
        ref.read(getNotificationByIdUseCaseProvider),
        ref.read(markNotificationAsReadUseCaseProvider),
        ref.read(deleteNotificationUseCaseProvider),
      );
    });
