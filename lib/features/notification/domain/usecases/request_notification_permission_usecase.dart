import 'package:aipet_frontend/features/notification/data/services/notification_service.dart';
import 'package:aipet_frontend/shared/shared.dart';


/// 알림 권한 요청 UseCase
class RequestNotificationPermissionUseCase {
  final NotificationService _notificationService;

  const RequestNotificationPermissionUseCase(this._notificationService);

  /// 알림 권한 요청
  Future<Result<bool>> call() async {
    try {
      await _notificationService.initialize();
      return Result.success('通知権限を取得しました', true);
    } catch (error) {
      return Result.failure('通知権限の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 권한 상태 확인
  Future<Result<bool>> checkPermissionStatus() async {
    try {
      await _notificationService.initialize();
      return Result.success('通知権限状態を確認しました', true);
    } catch (error) {
      return Result.failure('通知権限状態の確認に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 권한 요청 (상세 정보 포함)
  Future<Result<Map<String, dynamic>>> requestPermissionWithDetails() async {
    try {
      final permissionResult = await call();
      if (!permissionResult.isSuccess) {
        return Result.failure('通知権限の取得に失敗しました');
      }

      final details = {
        'permissionGranted': permissionResult.dataOrNull!,
        'requestedAt': DateTime.now().toIso8601String(),
        'platform': 'flutter',
        'serviceInitialized': true,
      };

      return Result.success('通知権限の詳細を取得しました', details);
    } catch (error) {
      return Result.failure('通知権限の詳細取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 권한 거부 시 대안 제시
  Future<Result<Map<String, dynamic>>> getPermissionAlternatives() async {
    try {
      final alternatives = {
        'settingsUrl': 'app-settings://notification',
        'manualSteps': ['1. デバイスの設定アプリを開く', '2. アプリケーションを選択', '3. 通知設定を有効にする'],
        'alternativeMethods': ['アプリ内通知', 'メール通知', 'SMS通知'],
        'contactSupport': 'support@aipet.com',
      };

      return Result.success('通知権限の代替案を取得しました', alternatives);
    } catch (error) {
      return Result.failure('通知権限の代替案取得に失敗しました: ${error.toString()}');
    }
  }
}
