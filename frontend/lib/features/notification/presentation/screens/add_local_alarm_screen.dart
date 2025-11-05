import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart' as notification;
import '../controllers/notification_schedule_controller.dart';
import '../widgets/alarm/alarm_repeat_selector.dart';
import '../widgets/alarm/alarm_time_picker_section.dart';
import '../widgets/alarm/alarm_title_input.dart';

/// ローカルアラーム追加/編集画面
class AddLocalAlarmScreen extends ConsumerStatefulWidget {
  final notification.NotificationSchedule? schedule; // 編集するスケジュール

  const AddLocalAlarmScreen({super.key, this.schedule});

  @override
  ConsumerState<AddLocalAlarmScreen> createState() =>
      _AddLocalAlarmScreenState();
}

class _AddLocalAlarmScreenState extends ConsumerState<AddLocalAlarmScreen> {
  late DateTime _selectedTime;
  late DateTime _selectedDate;
  final List<int> _selectedDays = []; // 選択された曜日 (0=日曜日, 6=土曜日)
  final TextEditingController _titleController = TextEditingController();
  bool _isDailyAlarm = false; // 毎日アラームトグル

  @override
  void initState() {
    super.initState();

    if (widget.schedule != null) {
      // 編集モード
      final schedule = widget.schedule!;
      _selectedTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        schedule.time.hour,
        schedule.time.minute,
      );
      _selectedDate = DateTime.now();
      _titleController.text = schedule.description;

      // 毎日アラーム設定
      _isDailyAlarm = schedule.scheduleType == notification.ScheduleType.daily;

      // 曜日設定 (API: 1=月曜日, 7=日曜日 → UI: 0=日曜日, 1=月曜日)
      if (schedule.weekDays != null) {
        for (final day in schedule.weekDays!) {
          final uiDay = day == 7 ? 0 : day;
          _selectedDays.add(uiDay);
        }
      }
    } else {
      // 新規アラームモード
      _selectedTime = DateTime.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // タイトル入力フィールド
            AlarmTitleInput(controller: _titleController),
            const SizedBox(height: AppSpacing.md),
            // 時間選択UI
            AlarmTimePickerSection(
              selectedTime: _selectedTime,
              onTimeChanged: (newTime) {
                setState(() {
                  _selectedTime = newTime;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // 日付と繰り返し設定UI
            AlarmRepeatSelector(
              selectedDate: _selectedDate,
              isDailyAlarm: _isDailyAlarm,
              selectedDays: _selectedDays,
              onDailyAlarmChanged: (value) {
                setState(() {
                  _isDailyAlarm = value;
                  if (value) {
                    _selectedDays.clear();
                  }
                });
              },
              onDaysChanged: (newDays) {
                setState(() {
                  _selectedDays
                    ..clear()
                    ..addAll(newDays);
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            // 保存/キャンセルボタン
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('キャンセル'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }

  /// アラーム保存
  Future<void> _saveAlarm() async {
    final time = TimeOfDay(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
    );

    try {
      final now = DateTime.now();

      // 繰り返しタイプ決定
      final notification.ScheduleType scheduleType;
      if (_isDailyAlarm) {
        scheduleType = notification.ScheduleType.daily;
      } else if (_selectedDays.isEmpty) {
        scheduleType = notification.ScheduleType.once;
      } else {
        scheduleType = notification.ScheduleType.weekly;
      }

      // 曜日変換 (UI: 0=日曜日 → API: 1=月曜日, 7=日曜日)
      List<int>? weekDays;
      if (_selectedDays.isNotEmpty && !_isDailyAlarm) {
        weekDays = _selectedDays.map((day) {
          return day == 0 ? 7 : day;
        }).toList();
      }

      // タイトル取得
      final title = _titleController.text.trim().isEmpty
          ? 'アラーム'
          : _titleController.text.trim();

      // NotificationSchedule 生成
      final schedule = notification.NotificationSchedule(
        id:
            widget.schedule?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'アラーム',
        description: title, // ユーザーが入力したタイトルをdescriptionに保存
        type: notification.NotificationType.reminder,
        scheduleType: scheduleType,
        time: notification.NotificationTimeOfDay(
          hour: time.hour,
          minute: time.minute,
        ),
        weekDays: weekDays,
        isActive: widget.schedule?.isActive ?? true, // 編集時は既存状態を維持
        createdAt: widget.schedule?.createdAt ?? now, // 編集時は既存作成時間を維持
        sound: widget.schedule?.sound ?? notification.AlarmSound.defaultSound,
      );

      LoggerService.debug('🔔 [アラーム追加] スケジュール保存開始');
      LoggerService.debug('  - ID: ${schedule.id}');
      LoggerService.debug(
        '  - 時間: ${schedule.time.hour}:${schedule.time.minute}',
      );
      LoggerService.debug('  - 繰り返し: ${schedule.scheduleType}');
      LoggerService.debug('  - 有効: ${schedule.isActive}');
      LoggerService.debug('  - 作成日: ${schedule.createdAt}');

      // スケジュール追加または更新
      if (widget.schedule != null) {
        await ref
            .read(notificationScheduleControllerProvider.notifier)
            .updateSchedule(schedule);
      } else {
        await ref
            .read(notificationScheduleControllerProvider.notifier)
            .addSchedule(schedule);
      }

      LoggerService.debug('✅ [アラーム追加] スケジュール保存完了');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      LoggerService.error('❌ [アラーム追加] 保存失敗: $e');
      LoggerService.debug('📍 [アラーム追加] StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ アラーム保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
