import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../controllers/alarm_time_settings_controller.dart';
import '../controllers/notification_ui_controller.dart';
import '../widgets/push/alarm_time_settings_section.dart';
import '../widgets/push/notification_type_toggles_section.dart';

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

  /// 通知設定をロード
  Future<void> _loadNotificationSettings() async {
    try {
      final useCase = ref.read(getNotificationSettingsUseCaseProvider);
      final settings = await useCase('default_user_id'); // 仮userId使用

      setState(() {
        // settingsがMap<String, dynamic>なので適切に処理
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

  /// 通知設定を保存
  Future<void> _saveNotificationSettings() async {
    if (!mounted) return;

    try {
      final getSettingsUseCase = ref.read(
        getNotificationSettingsUseCaseProvider,
      );
      final currentSettings = await getSettingsUseCase('default_user_id');

      if (!mounted) return;

      // 新しいタイプ設定生成
      final newTypeSettings = Map<String, dynamic>.from(
        currentSettings.dataOrNull?['typeSettings'] as Map<String, dynamic>? ??
            {},
      );
      newTypeSettings['feeding'] = _foodAlarmEnabled;
      newTypeSettings['walk'] = _walkAlarmEnabled;
      newTypeSettings['medicine'] = _medicineAlarmEnabled;
      newTypeSettings['system'] = _systemAlarmEnabled;
      newTypeSettings['reservation'] = _reservationAlarmEnabled;
      // 新しい設定生成
      final newSettings = Map<String, dynamic>.from(
        currentSettings.dataOrNull ?? {},
      );
      newSettings['typeSettings'] = newTypeSettings;

      if (!mounted) return;

      // UIコントローラーを通じて設定保存 (UIフィードバック含む)
      await _uiController.saveNotificationSettingsWithFeedback(
        context,
        'default_user_id',
        newSettings,
      );

      // アラーム時間設定も保存
      await ref
          .read(alarmTimeSettingsControllerProvider.notifier)
          .saveAlarmTimes();

      // mounted チェック後ナビゲーション
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, '設定の保存に失敗しました: ${e.toString()}');
      }
      if (kDebugMode) {
        LoggerService.debug('通知設定保存失敗: $e');
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

                  // 通知タイプトグルセクション
                  NotificationTypeTogglesSection(
                    foodAlarmEnabled: _foodAlarmEnabled,
                    walkAlarmEnabled: _walkAlarmEnabled,
                    medicineAlarmEnabled: _medicineAlarmEnabled,
                    systemAlarmEnabled: _systemAlarmEnabled,
                    reservationAlarmEnabled: _reservationAlarmEnabled,
                    onFoodAlarmChanged: (value) {
                      setState(() {
                        _foodAlarmEnabled = value;
                      });
                    },
                    onWalkAlarmChanged: (value) {
                      setState(() {
                        _walkAlarmEnabled = value;
                      });
                    },
                    onMedicineAlarmChanged: (value) {
                      setState(() {
                        _medicineAlarmEnabled = value;
                      });
                    },
                    onSystemAlarmChanged: (value) {
                      setState(() {
                        _systemAlarmEnabled = value;
                      });
                    },
                    onReservationAlarmChanged: (value) {
                      setState(() {
                        _reservationAlarmEnabled = value;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl * 2),

                  // アラーム時間設定セクション
                  AlarmTimeSettingsSection(onSelectTime: _selectTime),

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
}
