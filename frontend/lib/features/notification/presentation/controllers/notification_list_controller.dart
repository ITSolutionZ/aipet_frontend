import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
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
  Future<bool> checkNotificationSettings(String userId) async {
    try {
      final result = await _getNotificationSettingsUseCase(userId);
      final settings = result.dataOrNull ?? {};

      // 주요 알림 타입들이 모두 활성화되어 있는지 확인
      final mainTypes = [
        NotificationType.feeding,
        NotificationType.walk,
        NotificationType.system,
      ];

      // settings가 Map<String, dynamic>이므로 적절히 처리
      final enabled = settings['enabled'] as bool? ?? false;
      final typeSettings =
          settings['typeSettings'] as Map<String, dynamic>? ?? {};

      final allEnabled =
          enabled &&
          mainTypes.every((type) {
            final typeKey = type.toString().split('.').last;
            return typeSettings[typeKey] as bool? ?? false;
          });

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
