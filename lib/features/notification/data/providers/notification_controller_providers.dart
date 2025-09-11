import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../../presentation/controllers/controllers.dart';
import '../repositories/notification_repository_impl.dart';

// Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

// UseCase Providers
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.read(notificationRepositoryProvider));
});

final getNotificationByIdUseCaseProvider = Provider<GetNotificationByIdUseCase>(
  (ref) {
    return GetNotificationByIdUseCase(ref.read(notificationRepositoryProvider));
  },
);

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      return MarkNotificationAsReadUseCase(
        ref.read(notificationRepositoryProvider),
      );
    });

final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>((
  ref,
) {
  return DeleteNotificationUseCase(ref.read(notificationRepositoryProvider));
});

final getNotificationSettingsUseCaseProvider =
    Provider<GetNotificationSettingsUseCase>((ref) {
      return GetNotificationSettingsUseCase(
        ref.read(notificationRepositoryProvider),
      );
    });

final saveNotificationSettingsUseCaseProvider =
    Provider<SaveNotificationSettingsUseCase>((ref) {
      return SaveNotificationSettingsUseCase(
        ref.read(notificationRepositoryProvider),
      );
    });

final requestNotificationPermissionUseCaseProvider =
    Provider<RequestNotificationPermissionUseCase>((ref) {
      return RequestNotificationPermissionUseCase(
        ref.read(notificationRepositoryProvider),
      );
    });

final testNotificationUseCaseProvider = Provider<TestNotificationUseCase>((
  ref,
) {
  return TestNotificationUseCase(ref.read(notificationRepositoryProvider));
});

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
