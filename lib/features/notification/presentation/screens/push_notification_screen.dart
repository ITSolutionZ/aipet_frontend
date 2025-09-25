import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/notification/data/providers/notification_controller_providers.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/presentation/controllers/notification_ui_controller.dart';
import 'package:aipet_frontend/features/notification/presentation/components/forms/alarm_toggle_component.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// SectionHeader와 SettingsTile은 shared/widgets에서 가져옴 (이미 shared.dart에 포함됨)

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
      final useCase = ref.read(getNotificationSettingsUseCaseProvider);
      final settings = await useCase();

      setState(() {
        _foodAlarmEnabled = settings.isTypeEnabled(NotificationType.feeding);
        _walkAlarmEnabled = settings.isTypeEnabled(NotificationType.walk);
        _systemAlarmEnabled = settings.isTypeEnabled(NotificationType.system);
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {}
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 알림 설정 저장
  Future<void> _saveNotificationSettings() async {
    if (!mounted) return;

    try {
      final getSettingsUseCase = ref.read(
        getNotificationSettingsUseCaseProvider,
      );
      final currentSettings = await getSettingsUseCase();

      if (!mounted) return;

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

      if (!mounted) return;

      // UI 컨트롤러를 통해 설정 저장 (UI 피드백 포함)
      await _uiController.saveNotificationSettingsWithFeedback(
        context,
        newSettings,
      );

      // mounted 체크 후 네비게이션
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定の保存に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (kDebugMode) {
        debugPrint('알림 설정 저장 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: SoftGradientDrawerAppBar(title: 'プッシュ通知'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: const SoftGradientDrawerAppBar(title: 'プッシュ通知'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),

            // 페이지 설명 추가
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: AppColors.pointBrown.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.pointBrown,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'アラームをオンにすると、設定した時間にお知らせを受け取ることができます',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointBrown,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SectionHeaderComponent(title: 'アラーム種類'),

            const SizedBox(height: AppSpacing.md),

            AlarmToggleComponent(
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

            AlarmToggleComponent(
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

            AlarmToggleComponent(
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

            const SectionHeaderComponent(title: '詳細設定'),

            const SizedBox(height: AppSpacing.lg),

            SettingsTileComponent(
              title: 'アラーム時間設定',
              onTap: () {
                context.go(AppRouter.alarmTimeSettingsRoute);
              },
            ),

            const SizedBox(height: AppSpacing.xl * 3),

            ActionButton.primary(
              text: '修正完了',
              onPressed: _saveNotificationSettings,
              isEnabled: true,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
