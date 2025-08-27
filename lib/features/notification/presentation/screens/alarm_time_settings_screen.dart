import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../controllers/alarm_time_settings_controller.dart';
import '../widgets/notification_app_bar_widget.dart';
import '../widgets/notification_save_button_widget.dart';
import '../widgets/notification_section_header_widget.dart';

class AlarmTimeSettingsScreen extends ConsumerStatefulWidget {
  const AlarmTimeSettingsScreen({super.key});

  @override
  ConsumerState<AlarmTimeSettingsScreen> createState() =>
      _AlarmTimeSettingsScreenState();
}

class _AlarmTimeSettingsScreenState
    extends ConsumerState<AlarmTimeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 컨트롤러를 통해 알림 시간 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmTimeSettingsControllerProvider.notifier).loadAlarmTimes();
    });
  }

  /// 시간 선택 다이얼로그 표시
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(alarmTimeSettingsControllerProvider);

        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.pointOffWhite,
            appBar: NotificationAppBarWidget(title: '알림 시간 설정'),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: const NotificationAppBarWidget(title: '알림 시간 설정'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                const NotificationSectionHeaderWidget(title: '식사 알림 시간'),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '아침 식사',
                  subtitle: '아침 식사 알림 시간',
                  time: state.morningTime,
                  onTap: () => _selectTime(
                    context,
                    '아침 식사 시간',
                    state.morningTime,
                    (time) {
                      ref
                          .read(alarmTimeSettingsControllerProvider.notifier)
                          .selectTime('morning', time);
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '점심 식사',
                  subtitle: '점심 식사 알림 시간',
                  time: state.lunchTime,
                  onTap: () =>
                      _selectTime(context, '점심 식사 시간', state.lunchTime, (time) {
                        ref
                            .read(alarmTimeSettingsControllerProvider.notifier)
                            .selectTime('lunch', time);
                      }),
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '저녁 식사',
                  subtitle: '저녁 식사 알림 시간',
                  time: state.dinnerTime,
                  onTap: () => _selectTime(
                    context,
                    '저녁 식사 시간',
                    state.dinnerTime,
                    (time) {
                      ref
                          .read(alarmTimeSettingsControllerProvider.notifier)
                          .selectTime('dinner', time);
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                const NotificationSectionHeaderWidget(title: '산책 알림 시간'),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '산책 시간',
                  subtitle: '산책 알림 시간',
                  time: state.walkTime,
                  onTap: () =>
                      _selectTime(context, '산책 시간', state.walkTime, (time) {
                        ref
                            .read(alarmTimeSettingsControllerProvider.notifier)
                            .selectTime('walk', time);
                      }),
                ),

                const SizedBox(height: AppSpacing.xl * 3),

                NotificationSaveButtonWidget(
                  text: '저장',
                  onPressed: () {
                    ref
                        .read(alarmTimeSettingsControllerProvider.notifier)
                        .saveAlarmTimes();
                  },
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

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
