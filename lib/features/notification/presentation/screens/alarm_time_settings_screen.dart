import 'package:aipet_frontend/features/scheduling/scheduling.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/alarm_time_settings_controller.dart';

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
      ref
          .read(alarmTimeSettingsControllerProvider.notifier)
          .loadAlarmTimes('default_user_id');
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

                // 알람 카테고리별 설정 구성
                ...AlarmCategory.values.map(
                  (category) => _buildCategorySection(category, state),
                ),

                const SizedBox(height: AppSpacing.xl * 3),

                ActionButton.primary(
                  text: '保存',
                  isEnabled: true,
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

  /// 알람 카테고리별 섹션 구성
  Widget _buildCategorySection(AlarmCategory category, dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeaderComponent(title: category.displayName),
            const SizedBox(height: AppSpacing.sm),
            Text(
              category.description,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                height: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 해당 카테고리에 속하는 이벤트 타입별 시간 설정
        ...CalendarEventType.values
            .where((type) => type.alarmCategory == category)
            .map(
              (type) => Column(
                children: [
                  _buildEventTypeTimeSettingTile(type, state),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// 이벤트 타입별 시간 설정 타일
  Widget _buildEventTypeTimeSettingTile(
    CalendarEventType eventType,
    dynamic state,
  ) {
    // 기본값 설정 (실제 구현에서는 state에서 가져와야 함)
    TimeOfDay defaultTime = const TimeOfDay(hour: 9, minute: 0);

    // 이벤트 타입별 기본 시간 설정
    switch (eventType) {
      case CalendarEventType.feeding:
        defaultTime = state.morningTime ?? const TimeOfDay(hour: 8, minute: 0);
        break;
      case CalendarEventType.medication:
        defaultTime = const TimeOfDay(hour: 9, minute: 0);
        break;
      case CalendarEventType.walking:
        defaultTime = state.walkTime ?? const TimeOfDay(hour: 7, minute: 0);
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
            DateTimeUtils.formatTime(time),
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
