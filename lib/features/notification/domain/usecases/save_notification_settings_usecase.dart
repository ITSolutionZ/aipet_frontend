import 'package:aipet_frontend/features/notification/domain/usecases/get_notification_settings_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/notification_repository.dart';

/// 알림 설정 저장 UseCase
class SaveNotificationSettingsUseCase {
  final NotificationRepository _repository;

  const SaveNotificationSettingsUseCase(this._repository);

  /// 알림 설정 저장
  Future<Result<void>> call(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (settings.isEmpty) {
        return Result.failure('設定が空です');
      }

      // 설정 검증
      final validationResult = await _validateSettings(settings);
      if (!validationResult.isSuccess) {
        return validationResult;
      }

      final result = await _repository.updateNotificationSettings(
        userId: userId,
        settings: settings,
      );

      if (result.isSuccess) {
        return Result.success('通知設定を保存しました', null);
      } else {
        return Result.failure('通知設定の保存に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知設定の保存に失敗しました: ${error.toString()}');
    }
  }

  /// 특정 알림 타입 설정 저장
  Future<Result<void>> saveNotificationTypeSettings(
    String userId,
    String notificationType,
    Map<String, dynamic> typeSettings,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationType.trim().isEmpty) {
        return Result.failure('通知タイプが無効です');
      }

      if (typeSettings.isEmpty) {
        return Result.failure('設定が空です');
      }

      // 기존 설정 조회
      final getSettingsUseCase = GetNotificationSettingsUseCase(_repository);
      final currentSettingsResult = await getSettingsUseCase.call(userId);

      if (!currentSettingsResult.isSuccess) {
        return Result.failure('現在の設定の取得に失敗しました');
      }

      final currentSettings = Map<String, dynamic>.from(
        currentSettingsResult.dataOrNull!,
      );
      currentSettings[notificationType] = typeSettings;

      return await call(userId, currentSettings);
    } catch (error) {
      return Result.failure('通知タイプ設定の保存に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 설정 일괄 저장
  Future<Result<Map<String, dynamic>>> saveMultipleSettings(
    String userId,
    Map<String, Map<String, dynamic>> settingsByType,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (settingsByType.isEmpty) {
        return Result.failure('設定が空です');
      }

      final results = <String, String>{};
      int successCount = 0;
      int failureCount = 0;

      for (final entry in settingsByType.entries) {
        final type = entry.key;
        final settings = entry.value;

        final result = await saveNotificationTypeSettings(
          userId,
          type,
          settings,
        );
        if (result.isSuccess) {
          results[type] = 'success';
          successCount++;
        } else {
          results[type] = 'failed: ${result.message}';
          failureCount++;
        }
      }

      final result = {
        'totalTypes': settingsByType.length,
        'successCount': successCount,
        'failureCount': failureCount,
        'results': results,
      };

      return Result.success('複数の通知設定を保存しました', result);
    } catch (error) {
      return Result.failure('複数の通知設定の保存に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 설정 초기화 및 저장
  Future<Result<void>> resetAndSaveSettings(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      // 기본 설정 조회
      final getSettingsUseCase = GetNotificationSettingsUseCase(_repository);
      final defaultSettingsResult = await getSettingsUseCase
          .getDefaultSettings();

      if (!defaultSettingsResult.isSuccess) {
        return Result.failure('デフォルト設定の取得に失敗しました');
      }

      final defaultSettings = defaultSettingsResult.dataOrNull!;
      return await call(userId, defaultSettings);
    } catch (error) {
      return Result.failure('設定のリセットと保存に失敗しました: ${error.toString()}');
    }
  }

  /// 설정 검증
  Future<Result<bool>> _validateSettings(Map<String, dynamic> settings) async {
    try {
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

      // 데이터 타입 검증
      if (settings['pushNotifications'] is! bool) {
        return Result.failure('pushNotificationsはbooleanである必要があります');
      }

      if (settings['healthReminders'] is! bool) {
        return Result.failure('healthRemindersはbooleanである必要があります');
      }

      if (settings['walkReminders'] is! bool) {
        return Result.failure('walkRemindersはbooleanである必要があります');
      }

      return Result.success('設定の検証が完了しました', true);
    } catch (error) {
      return Result.failure('設定の検証に失敗しました: ${error.toString()}');
    }
  }
}
