import 'package:aipet_frontend/features/scheduling/scheduling.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/data.dart';
import '../components/forms/alarm_toggle_component.dart';
import '../controllers/alarm_time_settings_controller.dart';
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
    // アラーム時間設定を読み込み（遅延実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref
              .read(alarmTimeSettingsControllerProvider.notifier)
              .loadAlarmTimes('default_user_id');
        }
      });
    });
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

  /// 時間選択ダイアログ表示
  Future<void> _selectTime(
    BuildContext context,
    String title,
    TimeOfDay currentTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.pointOffWhite,
              hourMinuteTextColor: Colors.black87,
              dialBackgroundColor: AppColors.pointBrown,
              dialHandColor: Colors.white,
              dialTextColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentTime) {
      onTimeSelected(picked);
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

      // アラーム時間設定も保存
      await ref
          .read(alarmTimeSettingsControllerProvider.notifier)
          .saveAlarmTimes();

      // mounted 체크 후 네비게이션
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, '設定の保存に失敗しました: ${e.toString()}');
      }
      if (kDebugMode) {
        LoggerService.debug('알림 설정 저장 실패: $e');
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
      appBar: const SoftGradientAppBar(title: ''),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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

                  const SectionHeaderComponent(title: 'アラーム時間設定'),

                  const SizedBox(height: AppSpacing.lg),

                  // アラーム時間設定セクション
                  Consumer(
                    builder: (context, ref, child) {
                      final alarmState = ref.watch(
                        alarmTimeSettingsControllerProvider,
                      );

                      // ローディング状態の改善
                      if (alarmState.isLoading) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.pointBrown,
                            ),
                          ),
                        );
                      }

                      // エラー状態の処理
                      if (alarmState.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'アラーム時間設定の読み込みに失敗しました',
                                style: AppFonts.bodyMedium.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ActionButton.secondary(
                                text: '再試行',
                                isEnabled: true,
                                onPressed: () {
                                  ref
                                      .read(
                                        alarmTimeSettingsControllerProvider
                                            .notifier,
                                      )
                                      .loadAlarmTimes('default_user_id');
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      // データがロードされていない場合のフォールバック
                      if (alarmState.morningTime?.hour == 0 &&
                          alarmState.morningTime?.minute == 0) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: AppColors.pointGray,
                                size: 48,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'アラーム時間設定を読み込み中...',
                                style: AppFonts.bodyMedium.copyWith(
                                  color: AppColors.pointGray,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const CircularProgressIndicator(
                                color: AppColors.pointBrown,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // アラームカテゴリ別セクション
                          ...AlarmCategory.values.map(
                            (category) =>
                                _buildCategorySection(category, alarmState),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ActionButton.primary(
          text: '修正完了',
          onPressed: _saveNotificationSettings,
          isEnabled: true,
        ),
      ),
    );
  }

  /// アラームカテゴリ別セクション構成
  Widget _buildCategorySection(
    AlarmCategory category,
    AlarmTimeSettingsState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.displayName,
              style: AppFonts.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointBrown,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.description,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                height: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 該当カテゴリに属するイベントタイプ別時間設定
        ...CalendarEventType.values
            .where((type) => type.alarmCategory == category)
            .map(
              (type) => Column(
                children: [
                  _buildEventTypeTimeSettingTile(type, state),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  /// イベントタイプ別時間設定タイル
  Widget _buildEventTypeTimeSettingTile(
    CalendarEventType eventType,
    AlarmTimeSettingsState state,
  ) {
    // デフォルト値設定
    TimeOfDay defaultTime = const TimeOfDay(hour: 9, minute: 0);

    // イベントタイプ別デフォルト時間設定
    switch (eventType) {
      case CalendarEventType.feeding:
        defaultTime = state.morningTime ?? const TimeOfDay(hour: 9, minute: 0);
        break;
      case CalendarEventType.medication:
        defaultTime = const TimeOfDay(hour: 9, minute: 0);
        break;
      case CalendarEventType.walking:
        defaultTime = state.walkTime ?? const TimeOfDay(hour: 17, minute: 0);
        break;
      case CalendarEventType.exercise:
        defaultTime = const TimeOfDay(hour: 17, minute: 0);
        break;
      case CalendarEventType.system:
        defaultTime = const TimeOfDay(hour: 10, minute: 0);
        break;
      default:
        defaultTime = const TimeOfDay(hour: 9, minute: 0);
        break;
    }

    return _buildTimeSettingTile(
      title: '${eventType.emoji} ${eventType.displayName}',
      subtitle: '${eventType.displayName}アラーム時間',
      time: defaultTime,
      onTap: () => _selectTime(
        context,
        '${eventType.displayName}時間',
        defaultTime,
        (time) {
          ref
              .read(alarmTimeSettingsControllerProvider.notifier)
              .selectTime(eventType.name, time);
        },
      ),
    );
  }

  /// 時間設定タイル
  Widget _buildTimeSettingTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.pointBrown,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

//
