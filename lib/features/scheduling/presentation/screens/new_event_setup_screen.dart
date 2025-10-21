import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/scheduling/data/services/calendar_event_service.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NewEventSetupScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final CalendarEventType? eventType;

  const NewEventSetupScreen({super.key, this.initialDate, this.eventType});

  @override
  ConsumerState<NewEventSetupScreen> createState() =>
      _NewEventSetupScreenState();
}

class _NewEventSetupScreenState extends ConsumerState<NewEventSetupScreen> {
  DateTime _selectedTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  CalendarEventType _selectedEventType = CalendarEventType.feeding;
  PetProfileEntity? _selectedPet;
  bool _isRepeating = false;
  final List<int> _selectedDays = [];
  bool _excludeHolidays = false;
  String _eventName = '';
  String _eventDescription = '';
  String _eventLocation = '';
  bool _isAllDay = false;

  // 인라인 입력 상태
  bool _isEditingHour = false;
  bool _isEditingMinute = false;
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.eventType != null) {
      _selectedEventType = widget.eventType!;
    }
    _selectedTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);
    final pets = petsAsync.when(
      data: (data) => data,
      loading: () => <PetProfileEntity>[],
      error: (_, __) => <PetProfileEntity>[],
    );

    return Scaffold(
      backgroundColor: AppColors.pointGray.withValues(alpha: 0.1),
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.pointDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 시간 선택기
            _buildTimePicker(),

            // 일정 설정 카드
            _buildEventSettingsCard(pets),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

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
      child: Column(
        children: [
          // AM/PM 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAmPmButton(true),
              const SizedBox(width: AppSpacing.lg),
              _buildAmPmButton(false),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 시간 선택기
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              ? AppColors.pointBlue
              : AppColors.pointGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Text(isAm ? '午前' : '午後', style: AppFonts.titleMedium),
      ),
    );
  }

  Widget _buildTimeWheel({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    // 분 휠인지 시간 휠인지 구분 (min이 0이고 max가 59이면 분 휠)
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
                color: value < max
                    ? AppColors.pointGray
                    : AppColors.pointGray.withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ),

          // 현재 값
          Expanded(
            child: _buildTimeValue(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              isEditing: isMinute ? _isEditingMinute : _isEditingHour,
            ),
          ),

          // 아래쪽 화살표
          SizedBox(
            height: 32,
            child: IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: value > min
                    ? AppColors.pointGray
                    : AppColors.pointGray.withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSettingsCard(List<PetProfileEntity> pets) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜/반복 설정
          _buildDateRepeatSection(),

          const SizedBox(height: AppSpacing.lg),

          // 펫 선택
          _buildPetSelection(pets),

          const SizedBox(height: AppSpacing.lg),

          // 일정 카테고리
          _buildEventCategory(),

          const SizedBox(height: AppSpacing.lg),

          // 일정 이름
          _buildEventName(),

          const SizedBox(height: AppSpacing.lg),

          // 설명
          _buildEventDescription(),

          const SizedBox(height: AppSpacing.lg),

          // 위치
          _buildEventLocation(),

          const SizedBox(height: AppSpacing.lg),

          // 하루 종일 토글
          _buildAllDayToggle(),
        ],
      ),
    );
  }

  Widget _buildDateRepeatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.pointBlue,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              DateFormat('M月d日 (E)', 'ja_JP').format(_selectedDate),
              style: AppFonts.titleMedium,
            ),
            const Spacer(),
            IconButton(
              onPressed: _selectDate,
              icon: const Icon(
                Icons.calendar_month,
                color: AppColors.pointBlue,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // 요일 반복 선택
        _buildDaySelection(),

        const SizedBox(height: AppSpacing.md),

        // 공휴일 제외
        Row(
          children: [
            Text('祝日はオフにする', style: AppFonts.titleMedium),
            const Spacer(),
            Switch(
              value: _excludeHolidays,
              onChanged: (value) => setState(() => _excludeHolidays = value),
              activeColor: AppColors.pointBlue,
            ),
          ],
        ),
        Text('代替祝日や臨時、祝日を除く', style: AppFonts.bodySmall),
      ],
    );
  }

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
              _isRepeating = _selectedDays.isNotEmpty;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.pointBlue
                  : AppColors.pointGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected ? AppColors.pureWhite : AppColors.pointGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPetSelection(List<PetProfileEntity> pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ペットを選択',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (pets.isEmpty)
          const Text(
            '登録されたペットがありません',
            style: TextStyle(color: AppColors.pointGray),
          )
        else
          DropdownButtonFormField<PetProfileEntity>(
            value: _selectedPet,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('ペットを選択してください'),
            items: pets.map((pet) {
              return DropdownMenuItem(value: pet, child: Text(pet.name));
            }).toList(),
            onChanged: (pet) => setState(() => _selectedPet = pet),
          ),
      ],
    );
  }

  Widget _buildEventCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'イベントカテゴリ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            children: CalendarEventType.values.map((type) {
              final isSelected = _selectedEventType == type;
              final isLast = type == CalendarEventType.values.last;

              return Container(
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: AppColors.pointGray.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                ),
                child: Material(
                  color: AppColors.pureWhite.withValues(alpha: 0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedEventType = type),
                    borderRadius: isLast
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(AppRadius.medium),
                            bottomRight: Radius.circular(AppRadius.medium),
                          )
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              type.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.pointBlue
                                    : AppColors.pointDark,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.pointBlue,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'イベント名',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: 'イベント名を入力してください',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onChanged: (value) => _eventName = value,
        ),
      ],
    );
  }

  Widget _buildEventDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '説明',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'イベントの説明を入力してください (任意)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onChanged: (value) => _eventDescription = value,
        ),
      ],
    );
  }

  Widget _buildEventLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '場所',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: '場所を入力してください (任意)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onChanged: (value) => _eventLocation = value,
        ),
      ],
    );
  }

  Widget _buildAllDayToggle() {
    return Row(
      children: [
        const Text(
          '一日中',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Switch(
          value: _isAllDay,
          onChanged: (value) => setState(() => _isAllDay = value),
          activeColor: AppColors.pointBlue,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.pointGray.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('キャンセル'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: AppColors.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
              ),
              child: Text('保存', style: AppFonts.titleMedium),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ペットを選択してください'),
          backgroundColor: AppColors.pointRed,
        ),
      );
      return;
    }

    if (_eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('イベント名を入力してください'),
          backgroundColor: AppColors.pointRed,
        ),
      );
      return;
    }

    try {
      // 종료 시간 설정
      DateTime endTime;
      if (_isAllDay) {
        endTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          23,
          59,
        );
      } else {
        endTime = _selectedTime.add(const Duration(hours: 1));
      }

      // 캘린더 이벤트 생성
      final event = CalendarEventEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _eventName,
        description: _eventDescription.isNotEmpty ? _eventDescription : '일정',
        startTime: _selectedTime,
        endTime: endTime,
        isAllDay: _isAllDay,
        type: _selectedEventType,
        petId: _selectedPet!.id,
        petName: _selectedPet!.name,
        location: _eventLocation.isNotEmpty ? _eventLocation : null,
        hasAlarm: false,
        alarmSettings: [],
        recurrence: _isRepeating && _selectedDays.isNotEmpty
            ? CalendarEventRecurrence(
                type: CalendarRecurrenceType.weekly,
                daysOfWeek: _selectedDays,
                endDate: _selectedDate.add(const Duration(days: 365)),
              )
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 데이터베이스에 저장
      await CalendarEventService.instance.saveCalendarEvent(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('イベントが保存されました'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('イベントの保存に失敗しました: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }

  /// 시간 값 표시/입력 위젯
  Widget _buildTimeValue({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required bool isEditing,
  }) {
    final isMinute = _isEditingMinute;
    final controller = isMinute ? _minuteController : _hourController;

    if (isEditing) {
      // 편집 모드: TextField 표시
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
            height: 1.2,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (text) {
            final input = int.tryParse(text);
            if (input != null && input >= min && input <= max) {
              onChanged(input);
              setState(() {
                if (isMinute) {
                  _isEditingMinute = false;
                } else {
                  _isEditingHour = false;
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$min から $max の間で入力してください'),
                  backgroundColor: AppColors.pointRed,
                ),
              );
            }
          },
          onTap: () {
            controller.text = value.toString();
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
        ),
      );
    } else {
      // 표시 모드: 터치 가능한 텍스트
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isMinute) {
              _isEditingMinute = true;
              _minuteController.text = value.toString();
            } else {
              _isEditingHour = true;
              _hourController.text = value.toString();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.pointDark,
                height: 1.2,
              ),
            ),
          ),
        ),
      );
    }
  }
}
