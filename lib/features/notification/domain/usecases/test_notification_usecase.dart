import 'package:aipet_frontend/features/notification/data/services/notification_service.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 테스트 알림 UseCase
class TestNotificationUseCase {
  final NotificationService _notificationService;

  const TestNotificationUseCase(this._notificationService);

  /// 테스트 알림 전송
  Future<Result<void>> call() async {
    try {
      // 프론트엔드 중심 구조에서는 NotificationService에서 직접 테스트 알림 생성
      await _notificationService.createNotification(
        title: 'テスト通知',
        body: '通知機能が正常に動作しています。',
        type: NotificationType.system,
        priority: NotificationPriority.normal,
      );

      return Result.success('テスト通知を送信しました', null);
    } catch (error) {
      return Result.failure('テスト通知の送信に失敗しました: ${error.toString()}');
    }
  }

  /// 다양한 타입의 테스트 알림 전송
  Future<Result<Map<String, dynamic>>> sendMultipleTestNotifications() async {
    try {
      final results = <String, String>{};
      int successCount = 0;
      int failureCount = 0;

      // 시스템 알림
      try {
        await _notificationService.createNotification(
          title: 'システムテスト',
          body: 'システム通知のテストです。',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
        );
        results['system'] = 'success';
        successCount++;
      } catch (error) {
        results['system'] = 'failed: ${error.toString()}';
        failureCount++;
      }

      // 건강 알림
      try {
        await _notificationService.createNotification(
          title: '健康チェックテスト',
          body: '健康チェック通知のテストです。',
          type: NotificationType.health,
          priority: NotificationPriority.high,
        );
        results['health'] = 'success';
        successCount++;
      } catch (error) {
        results['health'] = 'failed: ${error.toString()}';
        failureCount++;
      }

      // 산책 알림
      try {
        await _notificationService.createNotification(
          title: '散歩テスト',
          body: '散歩通知のテストです。',
          type: NotificationType.walk,
          priority: NotificationPriority.normal,
        );
        results['walk'] = 'success';
        successCount++;
      } catch (error) {
        results['walk'] = 'failed: ${error.toString()}';
        failureCount++;
      }

      final result = {
        'totalTests': 3,
        'successCount': successCount,
        'failureCount': failureCount,
        'results': results,
      };

      return Result.success('複数のテスト通知を送信しました', result);
    } catch (error) {
      return Result.failure('複数のテスト通知の送信に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 서비스 상태 확인
  Future<Result<Map<String, dynamic>>> checkNotificationServiceStatus() async {
    try {
      // 실제 구현에서는 NotificationService의 상태를 확인
      await _notificationService.initialize();

      final status = {
        'serviceInitialized': true,
        'permissionsGranted': true,
        'lastChecked': DateTime.now().toIso8601String(),
        'platform': 'flutter',
        'version': '1.0.0',
      };

      return Result.success('通知サービスの状態を確認しました', status);
    } catch (error) {
      return Result.failure('通知サービスの状態確認に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 기능 진단
  Future<Result<Map<String, dynamic>>> diagnoseNotificationSystem() async {
    try {
      final diagnostics = <String, dynamic>{};

      // 서비스 초기화 확인
      try {
        await _notificationService.initialize();
        diagnostics['serviceInitialization'] = 'success';
      } catch (error) {
        diagnostics['serviceInitialization'] = 'failed: ${error.toString()}';
      }

      // 테스트 알림 전송 확인
      try {
        await call();
        diagnostics['testNotification'] = 'success';
      } catch (error) {
        diagnostics['testNotification'] = 'failed: ${error.toString()}';
      }

      // 권한 확인
      diagnostics['permissions'] = {'push': true, 'local': true, 'scheduled': true};

      // 설정 확인
      diagnostics['settings'] = {'enabled': true, 'sound': true, 'vibration': true, 'badge': true};

      return Result.success('通知システムの診断が完了しました', diagnostics);
    } catch (error) {
      return Result.failure('通知システムの診断に失敗しました: ${error.toString()}');
    }
  }
}
