import '../../../../shared/shared.dart';

import '../repositories/notification_repository.dart';


/// 알림 설정 조회 UseCase
class GetNotificationSettingsUseCase {
  final NotificationRepository _repository;

  const GetNotificationSettingsUseCase(this._repository);

  /// 알림 설정 가져오기
  Future<Result<Map<String, dynamic>>> call(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      final result = await _repository.getNotificationSettings(userId);
      if (result.isSuccess) {
        return Result.success('通知設定を取得しました', result.dataOrNull);
      } else {
        return Result.failure('通知設定の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知設定の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 특정 알림 타입 설정 조회
  Future<Result<Map<String, dynamic>>> getNotificationTypeSettings(
    String userId,
    String notificationType,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationType.trim().isEmpty) {
        return Result.failure('通知タイプが無効です');
      }

      final result = await call(userId);
      if (result.isSuccess) {
        final allSettings = result.dataOrNull!;
        final typeSettings = allSettings[notificationType] ?? {};
        return Result.success('通知タイプ設定を取得しました', typeSettings);
      } else {
        return Result.failure('通知タイプ設定の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知タイプ設定の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 설정 기본값 조회
  Future<Result<Map<String, dynamic>>> getDefaultSettings() async {
    try {
      // 기본 알림 설정 반환
      final defaultSettings = {
        'pushNotifications': true,
        'emailNotifications': false,
        'smsNotifications': false,
        'healthReminders': true,
        'walkReminders': true,
        'feedingReminders': true,
        'vaccinationReminders': true,
        'quietHours': {
          'enabled': false,
          'startTime': '22:00',
          'endTime': '08:00',
        },
        'frequency': 'immediate',
      };

      return Result.success('デフォルト通知設定を取得しました', defaultSettings);
    } catch (error) {
      return Result.failure('デフォルト通知設定の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 설정 검증
  Future<Result<bool>> validateSettings(Map<String, dynamic> settings) async {
    try {
      // 기본적인 설정 검증
      if (settings.isEmpty) {
        return Result.failure('設定が空です');
      }

      // 필수 설정 확인
      final requiredKeys = [
        'pushNotifications',
        'healthReminders',
        'walkReminders',
      ];
      for (final key in requiredKeys) {
        if (!settings.containsKey(key)) {
          return Result.failure('必須設定が不足しています: $key');
        }
      }

      return Result.success('設定の検証が完了しました', true);
    } catch (error) {
      return Result.failure('設定の検証に失敗しました: ${error.toString()}');
    }
  }
}
