import 'package:aipet_frontend/features/notification/domain/domain.dart'
    as notification;
import 'package:aipet_frontend/features/notification/presentation/controllers/notification_schedule_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ローカルアラーム追加/編集画面
class AddLocalAlarmScreen extends ConsumerStatefulWidget {
  final notification.NotificationSchedule? schedule; // 편집할 스케줄

  const AddLocalAlarmScreen({super.key, this.schedule});

  @override
  ConsumerState<AddLocalAlarmScreen> createState() =>
      _AddLocalAlarmScreenState();
}

class _AddLocalAlarmScreenState extends ConsumerState<AddLocalAlarmScreen> {
  late DateTime _selectedTime;
  late DateTime _selectedDate;
  final List<int> _selectedDays = []; // 선택된 요일 (0=일요일, 6=토요일)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final FocusNode _hourFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();
  bool _isEditingHour = false; // 시간 편집 모드
  bool _isEditingMinute = false; // 분 편집 모드

  @override
  void initState() {
    super.initState();

    if (widget.schedule != null) {
      // 편집 모드
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

      // 요일 설정 (API: 1=월요일, 7=일요일 → UI: 0=일요일, 1=월요일)
      if (schedule.weekDays != null) {
        for (final day in schedule.weekDays!) {
          final uiDay = day == 7 ? 0 : day;
          _selectedDays.add(uiDay);
        }
      }
    } else {
      // 새 알람 모드
      _selectedTime = DateTime.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  /// 알람 저장
  Future<void> _saveAlarm() async {
    final time = TimeOfDay(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
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
          return day == 0 ? 7 : day;
        }).toList();
      }

      // 타이틀 가져오기
      final title = _titleController.text.trim().isEmpty
          ? 'アラーム'
          : _titleController.text.trim();

      // NotificationSchedule 생성
      final schedule = notification.NotificationSchedule(
        id:
            widget.schedule?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'アラーム',
        description: title, // 유저가 입력한 타이틀을 description에 저장
        type: notification.NotificationType.reminder,
        scheduleType: scheduleType,
        time: notification.NotificationTimeOfDay(
          hour: time.hour,
          minute: time.minute,
        ),
        weekDays: weekDays,
        isActive: true,
        createdAt: now,
        sound: notification.AlarmSound.defaultSound,
      );

      LoggerService.debug('🔔 [알람추가] 스케줄 저장 시작');

      // 스케줄 추가 또는 업데이트
      if (widget.schedule != null) {
        await ref
            .read(notificationScheduleControllerProvider.notifier)
            .updateSchedule(schedule);
      } else {
        await ref
            .read(notificationScheduleControllerProvider.notifier)
            .addSchedule(schedule);
      }

      LoggerService.debug('✅ [알람추가] 스케줄 저장 완료');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      LoggerService.error('❌ [알람추가] 저장 실패: $e');
      LoggerService.debug('📍 [알람추가] StackTrace: $stackTrace');

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
            // 타이틀 입력 필드
            _buildTitleInput(),
            const SizedBox(height: AppSpacing.md),
            // 시간 선택 UI
            _buildTimePicker(),
            const SizedBox(height: AppSpacing.md),
            // 날짜 및 반복 설정 UI
            _buildDateRepeatSection(),
            const SizedBox(height: AppSpacing.xl),
            // 저장/취소 버튼
            Padding(
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
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// 타이틀 입력 필드
  Widget _buildTitleInput() {
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
      child: TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          hintText: 'アラームのタイトルを入力',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.label_outline, color: AppColors.pointPink),
          counterText: '', // 카운터 숨기기
        ),
        style: AppFonts.bodyLarge,
        maxLength: 50,
      ),
    );
  }

  /// 시간 선택 UI
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
    final isEditing = isMinute ? _isEditingMinute : _isEditingHour;
    final controller = isMinute ? _minuteController : _hourController;
    final focusNode = isMinute ? _minuteFocusNode : _hourFocusNode;

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
          // 숫자 표시 (탭하면 인라인 키보드 입력)
          Expanded(
            child: Center(
              child: isEditing
                  ? SizedBox(
                      width: 70,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        maxLength: 2,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: AppColors.pointDark,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (text) {
                          final newValue = int.tryParse(text);
                          if (newValue != null &&
                              newValue >= min &&
                              newValue <= max) {
                            onChanged(newValue);
                          }
                          setState(() {
                            if (isMinute) {
                              _isEditingMinute = false;
                            } else {
                              _isEditingHour = false;
                            }
                          });
                        },
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isMinute) {
                            _isEditingMinute = true;
                            _minuteController.text = value.toString().padLeft(
                              2,
                              '0',
                            );
                            _minuteController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _minuteController.text.length,
                            );
                          } else {
                            _isEditingHour = true;
                            _hourController.text = value.toString();
                            _hourController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _hourController.text.length,
                            );
                          }
                        });
                      },
                      child: Text(
                        isMinute
                            ? value.toString().padLeft(2, '0')
                            : value.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: AppColors.pointDark,
                        ),
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
}
