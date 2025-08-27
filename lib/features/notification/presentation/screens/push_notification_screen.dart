import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/entities.dart';
import '../controllers/notification_ui_controller.dart';
import '../widgets/alarm_toggle_widget.dart';
import '../widgets/notification_app_bar_widget.dart';
import '../widgets/notification_save_button_widget.dart';
import '../widgets/notification_section_header_widget.dart';
import '../widgets/notification_settings_tile_widget.dart';

class PushNotificationScreen extends ConsumerStatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  ConsumerState<PushNotificationScreen> createState() =>
      _PushNotificationScreenState();
}

class _PushNotificationScreenState
    extends ConsumerState<PushNotificationScreen> {
  bool _foodAlarmEnabled = false;
  bool _walkAlarmEnabled = false;
  bool _systemAlarmEnabled = true;
  bool _isLoading = true;
  late final NotificationUIController _uiController;

  @override
  void initState() {
    super.initState();
    _uiController = NotificationUIController(ref);
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  /// 알림 설정 로드
  Future<void> _loadNotificationSettings() async {
    try {
      final notificationService = NotificationService();
      final settings = await notificationService.getNotificationSettings();

      setState(() {
        _foodAlarmEnabled = settings.isTypeEnabled(NotificationType.feeding);
        _walkAlarmEnabled = settings.isTypeEnabled(NotificationType.walk);
        _systemAlarmEnabled = settings.isTypeEnabled(NotificationType.system);
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('알림 설정 로드 실패: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 알림 설정 저장
  Future<void> _saveNotificationSettings() async {
    try {
      final notificationService = NotificationService();
      final currentSettings = await notificationService
          .getNotificationSettings();

      // 새로운 타입 설정 생성
      final newTypeSettings = Map<NotificationType, bool>.from(
        currentSettings.typeSettings,
      );
      newTypeSettings[NotificationType.feeding] = _foodAlarmEnabled;
      newTypeSettings[NotificationType.walk] = _walkAlarmEnabled;
      newTypeSettings[NotificationType.system] = _systemAlarmEnabled;

      // 새로운 설정 생성
      final newSettings = currentSettings.copyWith(
        typeSettings: newTypeSettings,
      );

      // UI 컨트롤러를 통해 설정 저장 (UI 피드백 포함)
      await _uiController.saveNotificationSettingsWithFeedback(
        context,
        newSettings,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('알림 설정 저장 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: NotificationAppBarWidget(title: 'プッシュ通知'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: const NotificationAppBarWidget(title: 'プッシュ通知'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            const NotificationSectionHeaderWidget(title: 'アラーム種類'),

            const SizedBox(height: AppSpacing.lg),

            AlarmToggleWidget(
              title: '食事アラーム',
              subtitle: '食事給与時間をお知らせいたします',
              value: _foodAlarmEnabled,
              onChanged: (value) {
                setState(() {
                  _foodAlarmEnabled = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            AlarmToggleWidget(
              title: '散歩アラーム',
              subtitle: '決めた時間に散歩時間をわかるように',
              value: _walkAlarmEnabled,
              onChanged: (value) {
                setState(() {
                  _walkAlarmEnabled = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            AlarmToggleWidget(
              title: 'システムアラーム',
              subtitle: '予約などをお知らせいたします',
              value: _systemAlarmEnabled,
              onChanged: (value) {
                setState(() {
                  _systemAlarmEnabled = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.xl * 2),

            const NotificationSectionHeaderWidget(title: '詳細設定'),

            const SizedBox(height: AppSpacing.lg),

            NotificationSettingsTileWidget(
              title: 'アラーム時間設定',
              onTap: () {
                context.go(AppRouter.alarmTimeSettingsRoute);
              },
            ),

            const SizedBox(height: AppSpacing.xl * 3),

            NotificationSaveButtonWidget(
              text: '修正完了',
              onPressed: _saveNotificationSettings,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
