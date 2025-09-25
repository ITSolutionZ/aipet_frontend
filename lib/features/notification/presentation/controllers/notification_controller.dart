import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/domain/usecases/usecases.dart';

/// 알림 컨트롤러 - UseCase를 통한 클린 아키텍처 구현
class NotificationController extends BaseController {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetNotificationByIdUseCase _getNotificationByIdUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final GetNotificationSettingsUseCase _getSettingsUseCase;
  final SaveNotificationSettingsUseCase _saveSettingsUseCase;
  final RequestNotificationPermissionUseCase _requestPermissionUseCase;
  final TestNotificationUseCase _testNotificationUseCase;

  NotificationController(
    super.ref,
    this._getNotificationsUseCase,
    this._getNotificationByIdUseCase,
    this._markAsReadUseCase,
    this._deleteNotificationUseCase,
    this._getSettingsUseCase,
    this._saveSettingsUseCase,
    this._requestPermissionUseCase,
    this._testNotificationUseCase,
  );

  /// 알림 목록 가져오기
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _getNotificationsUseCase.call();
    } catch (error) {
      handleError(error);
      return [];
    }
  }

  /// 알림 새로고침
  Future<void> refreshNotifications() async {
    try {
      // 새로고침은 단순히 다시 가져오기
      await _getNotificationsUseCase.call();
    } catch (error) {
      handleError(error);
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    try {
      await _markAsReadUseCase.call(id);
    } catch (error) {
      handleError(error);
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(String id) async {
    try {
      await _deleteNotificationUseCase.call(id);
    } catch (error) {
      handleError(error);
    }
  }

  /// 개별 알림 가져오기
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return await _getNotificationByIdUseCase.call(id);
    } catch (error) {
      handleError(error);
      return null;
    }
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount() async {
    try {
      final notifications = await _getNotificationsUseCase.call();
      return notifications
          .where((n) => n.status == NotificationStatus.unread)
          .length;
    } catch (error) {
      handleError(error);
      return 0;
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      return await _getSettingsUseCase.call();
    } catch (error) {
      handleError(error);
      return null;
    }
  }

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      await _saveSettingsUseCase.call(settings);
    } catch (error) {
      handleError(error);
    }
  }

  /// 알림 권한 요청
  Future<bool> requestNotificationPermission() async {
    try {
      return await _requestPermissionUseCase.call();
    } catch (error) {
      handleError(error);
      return false;
    }
  }

  /// 테스트 알림 전송
  Future<void> sendTestNotification() async {
    try {
      await _testNotificationUseCase.call();
    } catch (error) {
      handleError(error);
    }
  }
}
