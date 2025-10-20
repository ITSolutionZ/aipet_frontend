import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/data.dart';
import '../components/forms/alarm_toggle_component.dart';
import '../controllers/notification_ui_controller.dart';
// SectionHeader와 SettingsTile은 shared/widgets에서 가져옴 (이미 shared.dart에 포함됨)

class PushNotificationScreen extends ConsumerStatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  ConsumerState<PushNotificationScreen> createState() =>
      _PushNotificationScreenState();
}

class _PushNotificationScreenState
    extends ConsumerState<PushNotificationScreen> {
  bool _foodAlarmEnabled = true;
  bool _walkAlarmEnabled = true;
  bool _medicineAlarmEnabled = true;
  bool _systemAlarmEnabled = true;
  bool _reservationAlarmEnabled = true;
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
      final settings = await useCase('default_user_id'); // 임시 userId 사용

      setState(() {
        // settings가 Map<String, dynamic>이므로 적절히 처리
        final typeSettings =
            settings.dataOrNull?['typeSettings'] as Map<String, dynamic>? ?? {};
        _foodAlarmEnabled = typeSettings['feeding'] as bool? ?? false;
        _walkAlarmEnabled = typeSettings['walk'] as bool? ?? false;
        _medicineAlarmEnabled = typeSettings['medicine'] as bool? ?? false;
        _systemAlarmEnabled = typeSettings['system'] as bool? ?? true;
        _reservationAlarmEnabled = typeSettings['reservation'] as bool? ?? true;
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
      final currentSettings = await getSettingsUseCase('default_user_id');

      if (!mounted) return;

      // 새로운 타입 설정 생성
      final newTypeSettings = Map<String, dynamic>.from(
        currentSettings.dataOrNull?['typeSettings'] as Map<String, dynamic>? ??
            {},
      );
      newTypeSettings['feeding'] = _foodAlarmEnabled;
      newTypeSettings['walk'] = _walkAlarmEnabled;
      newTypeSettings['medicine'] = _medicineAlarmEnabled;
      newTypeSettings['system'] = _systemAlarmEnabled;
      newTypeSettings['reservation'] = _reservationAlarmEnabled;
      // 새로운 설정 생성
      final newSettings = Map<String, dynamic>.from(
        currentSettings.dataOrNull ?? {},
      );
      newSettings['typeSettings'] = newTypeSettings;

      if (!mounted) return;

      // UI 컨트롤러를 통해 설정 저장 (UI 피드백 포함)
      await _uiController.saveNotificationSettingsWithFeedback(
        context,
        'default_user_id',
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
      return Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: AppBar(
          title: const Text('プッシュ通知'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: 'プッシュ通知'),
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
              title: '薬のアラーム',
              subtitle: '薬の服用時間をお知らせいたします',
              value: _medicineAlarmEnabled,
              onChanged: (value) {
                setState(() {
                  _medicineAlarmEnabled = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),
            AlarmToggleComponent(
              title: '予約アラーム',
              subtitle: '予約時間をお知らせいたします',
              value: _reservationAlarmEnabled,
              onChanged: (value) {
                setState(() {
                  _reservationAlarmEnabled = value;
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
