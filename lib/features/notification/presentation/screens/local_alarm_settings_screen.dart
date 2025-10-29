import 'package:aipet_frontend/features/notification/domain/domain.dart'
    as notification;
import 'package:aipet_frontend/features/notification/presentation/controllers/notification_schedule_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ローカルアラーム設定画面
class LocalAlarmSettingsScreen extends ConsumerStatefulWidget {
  const LocalAlarmSettingsScreen({super.key});

  @override
  ConsumerState<LocalAlarmSettingsScreen> createState() =>
      _LocalAlarmSettingsScreenState();
}

class _LocalAlarmSettingsScreenState
    extends ConsumerState<LocalAlarmSettingsScreen> {
  // 시간 선택 상태
  DateTime _selectedTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  notification.AlarmSound _selectedSound = notification.AlarmSound.defaultSound;
  bool _isAddingAlarm = false; // 알람 추가 모드
  String? _editingScheduleId; // 편집 중인 스케줄 ID
  final List<int> _selectedDays = []; // 선택된 요일 (0=일요일, 6=토요일)

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

  /// 알람 추가 모드 토글
  void _toggleAddAlarmMode() {
    setState(() {
      _isAddingAlarm = !_isAddingAlarm;
      if (_isAddingAlarm) {
        // 초기화 (새 알람)
        _editingScheduleId = null;
        _selectedTime = DateTime.now();
        _selectedDate = DateTime.now();
        _selectedSound = notification.AlarmSound.defaultSound;
        _selectedDays.clear();
      }
    });
  }

  /// 알람 생성
  Future<void> _createAlarm(
    TimeOfDay time, {
    String? scheduleId,
    notification.AlarmSound? sound,
  }) async {
    LoggerService.debug(
      '🔔 [로컬알람] 알람 ${scheduleId != null ? "수정" : "생성"} 시작 - ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );

    try {
      final now = DateTime.now();

      // 반복 타입 결정
      final scheduleType = _selectedDays.isEmpty
          ? notification.ScheduleType.once
          : notification.ScheduleType.weekly;

      // 요일 변환 (UI: 0=일요일 → API: 1=월요일, 7=일요일)
      List<int>? weekDays;
      if (_selectedDays.isNotEmpty) {
        weekDays = _selectedDays.map((day) {
          // 0=일요일 → 7, 1=월요일 → 1, ..., 6=토요일 → 6
          return day == 0 ? 7 : day;
        }).toList();
      }

      // NotificationSchedule 생성
      final schedule = notification.NotificationSchedule(
        id: scheduleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'アラーム',
        description:
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}のアラームです',
        type: notification.NotificationType.reminder,
        scheduleType: scheduleType,
        time: notification.NotificationTimeOfDay(
          hour: time.hour,
          minute: time.minute,
        ),
        weekDays: weekDays,
        isActive: true,
        createdAt: now,
        sound: sound ?? notification.AlarmSound.defaultSound, // 소리 설정
      );

      LoggerService.debug('🔔 [로컬알람] 스케줄 객체 생성 완료: ${schedule.id}');
      LoggerService.debug('🔔 [로컬알람] 스케줄 타입: ${schedule.scheduleType}');
      LoggerService.debug(
        '🔔 [로컬알람] 알람 시간: ${schedule.time.hour}:${schedule.time.minute}',
      );
      LoggerService.debug('🔔 [로컬알람] 알람 소리: ${schedule.sound.displayName}');
      LoggerService.debug(
        '🔔 [로컬알람] 다음 실행 시간: ${schedule.calculateNextExecutionTime()}',
      );

      // 스케줄 추가 또는 업데이트
      if (scheduleId != null) {
        LoggerService.debug('🔔 [로컬알람] 기존 알람 업데이트 시작');
        await ref
            .read(notificationScheduleControllerProvider.notifier)
            .updateSchedule(schedule);
        LoggerService.debug('🔔 [로컬알람] 기존 알람 업데이트 완료');
      } else {
        LoggerService.debug('🔔 [로컬알람] 새 알람 추가 시작');
        await ref
            .read(notificationScheduleControllerProvider.notifier)
            .addSchedule(schedule);
        LoggerService.debug('🔔 [로컬알람] 새 알람 추가 완료');
      }

      // 등록된 알람 확인
      final scheduledList = await AwesomeNotifications()
          .listScheduledNotifications();
      final justScheduled = scheduledList
          .where((n) => n.content?.id == int.parse(schedule.id) % 2147483647)
          .toList();

      if (justScheduled.isNotEmpty) {
        LoggerService.debug('✅ [로컬알람] 알람이 실제로 스케줄에 등록됨!');
        LoggerService.debug(
          '✅ [로컬알람] 스케줄 정보: ${justScheduled.first.schedule?.toMap()}',
        );
      } else {
        LoggerService.error('❌ [로컬알람] 알람이 스케줄에 등록되지 않음!');
        LoggerService.debug('❌ [로컬알람] 전체 등록된 알람 수: ${scheduledList.length}');
      }

      LoggerService.debug('🔔 [로컬알람] 스케줄 저장 완료');
      LoggerService.debug(
        '🔔 [로컬알람] 알람 ${scheduleId != null ? "수정" : "생성"} 완료! SnackBar 표시',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scheduleId != null ? '✅ アラームを更新しました' : '✅ アラームを作成しました',
            ),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        '❌ [로컬알람] 알람 ${scheduleId != null ? "수정" : "생성"} 실패: $e',
      );
      LoggerService.debug('📍 [로컬알람] StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ アラーム${scheduleId != null ? "更新" : "作成"}に失敗しました: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 알람 편집 모드 열기
  void _editAlarm(
    BuildContext context,
    notification.NotificationSchedule schedule,
  ) {
    LoggerService.debug('🔔 [로컬알람] 알람 편집 모드 - ID: ${schedule.id}');

    setState(() {
      _isAddingAlarm = true;
      _editingScheduleId = schedule.id; // 편집 중인 ID 설정
      _selectedTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        schedule.time.hour,
        schedule.time.minute,
      );
      _selectedSound = schedule.sound;

      // 요일 설정 (API: 1=월요일, 7=일요일 → UI: 0=일요일, 1=월요일)
      _selectedDays.clear();
      if (schedule.weekDays != null) {
        for (final day in schedule.weekDays!) {
          final uiDay = day == 7 ? 0 : day;
          _selectedDays.add(uiDay);
        }
      }
    });
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

          // 알람 추가 모드 또는 알람 목록
          Expanded(
            child: _isAddingAlarm
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        // 시간 선택 UI
                        _buildTimePicker(),
                        const SizedBox(height: AppSpacing.md),
                        // 날짜 및 반복 설정 UI
                        _buildDateRepeatSection(),
                        const SizedBox(height: AppSpacing.md),
                        // 소리 선택 UI
                        _buildSoundSelector(),
                        const SizedBox(height: AppSpacing.xl),
                        // 저장/취소 버튼
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isAddingAlarm = false;
                                      _editingScheduleId = null;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('キャンセル'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final time = TimeOfDay(
                                      hour: _selectedTime.hour,
                                      minute: _selectedTime.minute,
                                    );
                                    await _createAlarm(
                                      time,
                                      scheduleId: _editingScheduleId,
                                      sound: _selectedSound,
                                    );
                                    setState(() {
                                      _isAddingAlarm = false;
                                      _editingScheduleId = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.pointPink,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('保存'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  )
                : (state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.schedules.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.alarm_off,
                                size: 80,
                                color: AppColors.pointGray.withValues(
                                  alpha: 0.5,
                                ),
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
                                  color: AppColors.pointGray.withValues(
                                    alpha: 0.7,
                                  ),
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
                        )),
          ),

          // 알람 추가 버튼
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ActionButton.primary(
              text: _isAddingAlarm ? 'リストに戻る' : 'アラーム追加',
              isEnabled: true,
              onPressed: _toggleAddAlarmMode,
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 선택 UI (이미지 디자인)
  Widget _buildTimePicker() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AM/PM 선택
          Column(
            children: [
              _buildAmPmButton(true),
              const SizedBox(height: AppSpacing.sm),
              _buildAmPmButton(false),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          // 시간 선택기
          Row(
            children: [
              _buildTimeWheel(
                value: _selectedTime.hour % 12 == 0
                    ? 12
                    : _selectedTime.hour % 12,
                min: 1,
                max: 12,
                onChanged: (value) {
                  setState(() {
                    final hour = _selectedTime.hour >= 12
                        ? (value == 12 ? 12 : value + 12)
                        : (value == 12 ? 0 : value);
                    _selectedTime = DateTime(
                      _selectedTime.year,
                      _selectedTime.month,
                      _selectedTime.day,
                      hour,
                      _selectedTime.minute,
                    );
                  });
                },
              ),
              const Text(
                ' : ',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppColors.pointDark,
                ),
              ),
              _buildTimeWheel(
                value: _selectedTime.minute,
                min: 0,
                max: 59,
                onChanged: (value) {
                  setState(() {
                    _selectedTime = DateTime(
                      _selectedTime.year,
                      _selectedTime.month,
                      _selectedTime.day,
                      _selectedTime.hour,
                      value,
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// AM/PM 버튼
  Widget _buildAmPmButton(bool isAm) {
    final isSelected = (_selectedTime.hour < 12) == isAm;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isAm && _selectedTime.hour >= 12) {
            _selectedTime = DateTime(
              _selectedTime.year,
              _selectedTime.month,
              _selectedTime.day,
              _selectedTime.hour - 12,
              _selectedTime.minute,
            );
          } else if (!isAm && _selectedTime.hour < 12) {
            _selectedTime = DateTime(
              _selectedTime.year,
              _selectedTime.month,
              _selectedTime.day,
              _selectedTime.hour + 12,
              _selectedTime.minute,
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointPink
              : AppColors.pointGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Text(
          isAm ? '午前' : '午後',
          style: AppFonts.titleMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.pointGray,
          ),
        ),
      ),
    );
  }

  /// 시간/분 휠
  Widget _buildTimeWheel({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final isMinute = min == 0 && max == 59;

    return Container(
      height: 140,
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // 위쪽 화살표
          SizedBox(
            height: 32,
            child: IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: value < max ? AppColors.pointBrown : AppColors.pointGray,
              ),
            ),
          ),
          // 숫자 표시
          Expanded(
            child: Center(
              child: Text(
                isMinute ? value.toString().padLeft(2, '0') : value.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppColors.pointDark,
                ),
              ),
            ),
          ),
          // 아래쪽 화살표
          SizedBox(
            height: 32,
            child: IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: value > min ? AppColors.pointBrown : AppColors.pointGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 및 반복 설정 UI
  Widget _buildDateRepeatSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 표시
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppColors.pointPink,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_selectedDate.month}月${_selectedDate.day}日(${_getWeekdayName(_selectedDate.weekday)})',
                style: AppFonts.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 요일 선택
          _buildDaySelection(),
        ],
      ),
    );
  }

  /// 요일 이름 가져오기
  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[(weekday - 1) % 7];
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
              // API: 1=월요일, 7=일요일 → UI: 0=일요일, 1=월요일
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

  /// 요일 선택 UI
  Widget _buildDaySelection() {
    final days = ['日', '月', '火', '水', '木', '金', '土'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSelected = _selectedDays.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.pointPink
                  : AppColors.pointGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.pointGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 소리 선택 UI
  Widget _buildSoundSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: AppColors.pointBrown),
          const SizedBox(width: AppSpacing.md),
          const Text('アラーム音', style: TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          DropdownButton<notification.AlarmSound>(
            value: _selectedSound,
            underline: const SizedBox(),
            items: notification.AlarmSound.values.map((sound) {
              String displayText;
              IconData icon;
              switch (sound) {
                case notification.AlarmSound.dog:
                  displayText = '🐶 犬';
                  icon = Icons.pets;
                case notification.AlarmSound.cat:
                  displayText = '🐱 猫';
                  icon = Icons.ac_unit;
                case notification.AlarmSound.defaultSound:
                  displayText = '🔔 デフォルト';
                  icon = Icons.notifications;
              }
              return DropdownMenuItem(
                value: sound,
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.pointBrown),
                    const SizedBox(width: AppSpacing.sm),
                    Text(displayText),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSound = value;
                });
              }
            },
          ),
        ],
      ),
    );
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
        onTap: () => _editAlarm(context, schedule),
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
        title: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: schedule.isActive ? Colors.black87 : AppColors.pointGray,
          ),
        ),
        subtitle: Text(
          _getScheduleDescription(schedule),
          style: const TextStyle(fontSize: 14, color: AppColors.pointGray),
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
