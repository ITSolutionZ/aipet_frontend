import 'package:aipet_frontend/features/notification/presentation/controllers/alarm_time_settings_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmTimeSettingsScreen extends ConsumerStatefulWidget {
  const AlarmTimeSettingsScreen({super.key});

  @override
  ConsumerState<AlarmTimeSettingsScreen> createState() => _AlarmTimeSettingsScreenState();
}

class _AlarmTimeSettingsScreenState extends ConsumerState<AlarmTimeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 컨트롤러를 통해 알림 시간 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmTimeSettingsControllerProvider.notifier).loadAlarmTimes('default_user_id');
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
            appBar: SoftGradientDrawerAppBar(title: 'アラーム時間設定'),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: const SoftGradientDrawerAppBar(title: 'アラーム時間設定'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                const SectionHeaderComponent(title: '食事アラーム時間'),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '朝食',
                  subtitle: '朝食アラーム時間',
                  time: state.morningTime,
                  onTap: () => _selectTime(context, '朝食時間', state.morningTime, (time) {
                    ref
                        .read(alarmTimeSettingsControllerProvider.notifier)
                        .selectTime('morning', time);
                  }),
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '昼食',
                  subtitle: '昼食アラーム時間',
                  time: state.lunchTime,
                  onTap: () => _selectTime(context, '昼食時間', state.lunchTime, (time) {
                    ref
                        .read(alarmTimeSettingsControllerProvider.notifier)
                        .selectTime('lunch', time);
                  }),
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '夕食',
                  subtitle: '夕食アラーム時間',
                  time: state.dinnerTime,
                  onTap: () => _selectTime(context, '夕食時間', state.dinnerTime, (time) {
                    ref
                        .read(alarmTimeSettingsControllerProvider.notifier)
                        .selectTime('dinner', time);
                  }),
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                const SectionHeaderComponent(title: '散歩アラーム時間'),

                const SizedBox(height: AppSpacing.lg),

                _buildTimeSettingTile(
                  title: '散歩時間',
                  subtitle: '散歩アラーム時間',
                  time: state.walkTime,
                  onTap: () => _selectTime(context, '散歩時間', state.walkTime, (time) {
                    ref.read(alarmTimeSettingsControllerProvider.notifier).selectTime('walk', time);
                  }),
                ),

                const SizedBox(height: AppSpacing.xl * 3),

                ActionButton.primary(
                  text: '保存',
                  isEnabled: true,
                  onPressed: () {
                    ref.read(alarmTimeSettingsControllerProvider.notifier).saveAlarmTimes();
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBrown,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
