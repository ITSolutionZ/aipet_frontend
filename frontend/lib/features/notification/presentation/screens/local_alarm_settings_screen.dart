import 'package:aipet_frontend/features/notification/domain/entities/notification_schedule.dart' as notification;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/notification/presentation/controllers/notification_schedule_controller.dart';
import '../../../../../features/notification/presentation/screens/add_local_alarm_screen.dart';
import '../../../../shared/shared.dart';

/// ローカルアラーム設定画面
class LocalAlarmSettingsScreen extends ConsumerStatefulWidget {
  const LocalAlarmSettingsScreen({super.key});

  @override
  ConsumerState<LocalAlarmSettingsScreen> createState() =>
      _LocalAlarmSettingsScreenState();
}

class _LocalAlarmSettingsScreenState
    extends ConsumerState<LocalAlarmSettingsScreen> {
  @override
  void initState() {
    super.initState();
    LoggerService.debug('🔔 [로컬알람] 화면 초기화 시작');
    // 알람 목록 로드 및 권한 확인
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoggerService.debug('🔔 [로컬알람] 스케줄 목록 로드 시작');
      ref.read(notificationScheduleControllerProvider.notifier).loadSchedules();

      // 정확한 알람 권한 확인 및 요청
      await _checkAndRequestAlarmPermissions();
    });
  }

  /// 알람 권한 확인 및 요청
  Future<void> _checkAndRequestAlarmPermissions() async {
    try {
      // 알림 권한 확인
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      LoggerService.debug('🔔 [권한] 알림 권한 상태: $isAllowed');

      if (!isAllowed) {
        LoggerService.debug('🔔 [권한] 알림 권한 요청 시작');
        final granted = await AwesomeNotifications()
            .requestPermissionToSendNotifications();
        LoggerService.debug('🔔 [권한] 알림 권한 요청 결과: $granted');
      }

      // Android 12+ 정확한 알람 권한 확인
      if (mounted) {
        LoggerService.debug('🔔 [권한] 정확한 알람 권한 체크 (Android 12+)');
        // AwesomeNotifications가 자동으로 처리하므로 별도 요청 불필요
      }
    } catch (e) {
      LoggerService.error('❌ [권한] 권한 확인 실패: $e');
    }
  }

  /// 알람 추가/편집 페이지 열기
  Future<void> _openAddAlarmPage({
    notification.NotificationSchedule? schedule,
  }) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddLocalAlarmScreen(schedule: schedule),
      ),
    );

    // 페이지에서 돌아왔을 때 목록 새로고침
    if (result == true && mounted) {
      ref.read(notificationScheduleControllerProvider.notifier).loadSchedules();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(schedule != null ? '✅ アラームを更新しました' : '✅ アラームを作成しました'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationScheduleControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientDrawerAppBar(title: 'ローカルアラーム設定'),
      body: Column(
        children: [
          // 설명 카드
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.alarm, color: AppColors.pointBrown, size: 40),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ローカルアラーム',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '指定した時間に1回アラームが鳴ります',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.pointGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 알람 목록
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alarm_off,
                          size: 80,
                          color: AppColors.pointGray.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'アラームがありません',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.pointGray,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '下のボタンでアラームを追加できます',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.pointGray.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: state.schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = state.schedules[index];
                      final time = TimeOfDay(
                        hour: schedule.time.hour,
                        minute: schedule.time.minute,
                      );

                      return _buildAlarmTile(schedule, time);
                    },
                  ),
          ),

          // 알람 추가 버튼
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ActionButton.primary(
              text: 'アラーム追加',
              isEnabled: true,
              onPressed: () => _openAddAlarmPage(),
            ),
          ),
        ],
      ),
    );
  }

  /// 스케줄 설명 가져오기
  String _getScheduleDescription(notification.NotificationSchedule schedule) {
    switch (schedule.scheduleType) {
      case notification.ScheduleType.once:
        return '1回のみ';
      case notification.ScheduleType.daily:
        return '毎日';
      case notification.ScheduleType.weekly:
        if (schedule.weekDays == null || schedule.weekDays!.isEmpty) {
          return '毎週';
        }
        final days = ['日', '月', '火', '水', '木', '金', '土'];
        final selectedDays = schedule.weekDays!
            .map((day) {
              final uiDay = day == 7 ? 0 : day;
              return days[uiDay];
            })
            .join(', ');
        return '毎週 $selectedDays';
      case notification.ScheduleType.monthly:
        return schedule.dayOfMonth != null ? '毎月${schedule.dayOfMonth}日' : '毎月';
      case notification.ScheduleType.custom:
        return 'カスタム';
    }
  }

  /// 알람 타일
  Widget _buildAlarmTile(
    notification.NotificationSchedule schedule,
    TimeOfDay time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        onTap: () => _openAddAlarmPage(schedule: schedule),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: schedule.isActive
                ? AppColors.pointBrown.withValues(alpha: 0.1)
                : AppColors.pointGray.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.alarm,
              color: schedule.isActive
                  ? AppColors.pointBrown
                  : AppColors.pointGray,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: schedule.isActive ? Colors.black87 : AppColors.pointGray,
              ),
            ),
            if (schedule.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  schedule.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: schedule.isActive
                        ? AppColors.pointBrown
                        : AppColors.pointGray,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _getScheduleDescription(schedule),
            style: const TextStyle(fontSize: 14, color: AppColors.pointGray),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // on/off 토글
            Switch(
              value: schedule.isActive,
              onChanged: (value) {
                ref
                    .read(notificationScheduleControllerProvider.notifier)
                    .toggleSchedule(schedule.id, value);
              },
              activeThumbColor: AppColors.pointBrown,
            ),
            const SizedBox(width: AppSpacing.sm),
            // 삭제 버튼
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('アラーム削除'),
                    content: const Text('このアラームを削除しますか?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          '削除',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await ref
                      .read(notificationScheduleControllerProvider.notifier)
                      .deleteSchedule(schedule.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ アラームを削除しました'),
                        backgroundColor: AppColors.pointGreen,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
