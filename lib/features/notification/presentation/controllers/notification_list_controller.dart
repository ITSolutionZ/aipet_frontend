import 'package:aipet_frontend/features/notification/data/providers/notification_controller_providers.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/onboarding/domain/usecases/usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_ui_controller.dart';

/// 알림 목록 화면 컨트롤러
class NotificationListController {
  final NotificationUIController _uiController;
  final GetNotificationSettingsUseCase _getNotificationSettingsUseCase;

  NotificationListController(WidgetRef ref)
    : _uiController = NotificationUIController(ref),
      _getNotificationSettingsUseCase = ref.read(
        getNotificationSettingsUseCaseProvider,
      );

  /// 알림 설정 상태 확인
  Future<bool> checkNotificationSettings() async {
    try {
      final settings = await _getNotificationSettingsUseCase();

      // 주요 알림 타입들이 모두 활성화되어 있는지 확인
      final mainTypes = [
        NotificationType.feeding,
        NotificationType.walk,
        NotificationType.system,
      ];

      final allEnabled =
          settings.enabled &&
          mainTypes.every((type) => settings.isTypeEnabled(type));

      return !allEnabled; // 설정이 완료되지 않았으면 true (카드 표시)
    } catch (e) {
      // 오류 시 카드를 보여주어 사용자가 설정할 수 있도록 함
      return true;
    }
  }

  /// 컨트롤러 정리
  void dispose() {
    _uiController.dispose();
  }
}
