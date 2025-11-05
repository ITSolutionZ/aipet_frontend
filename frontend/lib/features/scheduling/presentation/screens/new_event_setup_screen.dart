import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import '../../../../../features/scheduling/data/services/calendar_event_service.dart';
import '../../../../../features/scheduling/domain/entities/calendar_event_entity.dart';

class NewEventSetupScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final CalendarEventType? eventType;
  final CalendarEventEntity? initialEvent; // 編集モード用

  const NewEventSetupScreen({
    super.key,
    this.initialDate,
    this.eventType,
    this.initialEvent,
  });

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
  final bool _excludeHolidays = false;
  String _eventName = '';
  String _eventDescription = '';
  String _eventLocation = '';
  bool _isAllDay = false;
  DateTime? _endTime; // 終了時間

  // TextEditingController for title field
  final TextEditingController _titleController = TextEditingController();

  // 인라인 입력 상태
  bool _isEditingHour = false;
  bool _isEditingMinute = false;
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  // Focus nodes for inline time input
  final FocusNode _hourFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 編集モードの場合、既存データをロード
    if (widget.initialEvent != null) {
      final event = widget.initialEvent!;
      _selectedDate = event.startTime;
      _selectedTime = event.startTime;
      _endTime = event.endTime;
      _selectedEventType = event.type;
      _eventName = event.title;
      _titleController.text = event.title;
      _eventDescription = event.description;
      _eventLocation = event.location ?? '';
      _isAllDay = event.isAllDay ?? false;

      // 繰り返し設定
      if (event.recurrence != null) {
        _isRepeating = true;
        _selectedDays.addAll(event.recurrence!.daysOfWeek ?? []);
      }
    } else {
      // 新規作成モード
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

    _hourFocusNode.addListener(_onHourFocusChange);
    _minuteFocusNode.addListener(_onMinuteFocusChange);
  }

  // 펫이 1마리일 때 자동 선택 또는 편집 모드에서 펫 선택
  void _autoSelectPetIfOnlyOne(List<PetProfileEntity> pets) {
    if (!mounted) return; // mounted 체크 추가

    // 편집 모드에서 petId가 있으면 해당 펫 선택
    if (widget.initialEvent != null &&
        widget.initialEvent!.petId != null &&
        _selectedPet == null) {
      final pet = pets.firstWhere(
        (p) => p.id == widget.initialEvent!.petId,
        orElse: () => pets.isNotEmpty ? pets.first : pets.first,
      );
      if (mounted) {
        setState(() {
          _selectedPet = pet;
        });
      }
      return;
    }

    // 펫이 1마리일 때 자동 선택
    if (pets.length == 1 && _selectedPet == null && mounted) {
      setState(() {
        _selectedPet = pets.first;
        _updateTitleIfEmpty();
      });
    }
  }

  // タイトルが空の場合、ペット名 + カテゴリで自動生成
  void _updateTitleIfEmpty() {
    // ユーザーがタイトルを手動で入力している場合は更新しない
    if (_titleController.text.isNotEmpty && _eventName.isNotEmpty) {
      return;
    }

    if (_selectedPet != null) {
      final newTitle =
          '${_selectedPet!.name}の${_selectedEventType.displayName}';
      _titleController.text = newTitle;
      _eventName = newTitle;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocusNode.removeListener(_onHourFocusChange);
    _hourFocusNode.dispose();
    _minuteFocusNode.removeListener(_onMinuteFocusChange);
    _minuteFocusNode.dispose();
    super.dispose();
  }

  // Focus change handlers
  void _onHourFocusChange() {
    if (!_hourFocusNode.hasFocus && _isEditingHour) {
      _handleTimeInputSubmission(
        controller: _hourController,
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
        isMinute: false,
      );
    }
  }

  void _onMinuteFocusChange() {
    if (!_minuteFocusNode.hasFocus && _isEditingMinute) {
      _handleTimeInputSubmission(
        controller: _minuteController,
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
        isMinute: true,
      );
    }
  }

  // Helper method to handle time input submission (both onSubmitted and onFocusChange)
  void _handleTimeInputSubmission({
    required TextEditingController controller,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required bool isMinute,
  }) {
    final text = controller.text;
    final input = int.tryParse(text);

    if (input != null && input >= min && input <= max) {
      onChanged(input); // Update _selectedTime
      setState(() {
        if (isMinute) {
          _isEditingMinute = false;
        } else {
          _isEditingHour = false;
        }
      });
    } else {
      // If invalid, revert to the current _selectedTime value and exit editing mode
      final currentValue = isMinute
          ? _selectedTime.minute
          : (_selectedTime.hour % 12 == 0 ? 12 : _selectedTime.hour % 12);
      controller.text = DateTimeUtils.formatTwoDigits(currentValue);
      setState(() {
        if (isMinute) {
          _isEditingMinute = false;
        } else {
          _isEditingHour = false;
        }
      });
      // ✅ Shared SnackBarService 사용
      SnackBarService.showWarning(context, '$min から $max の間で入力してください');
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);
    final pets = petsAsync.when(
      data: (data) {
        // 펫이 1마리일 때 자동 선택 (mounted 체크 추가)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _autoSelectPetIfOnlyOne(data);
          }
        });
        return data;
      },
      loading: () => <PetProfileEntity>[],
      error: (_, __) => <PetProfileEntity>[],
    );

    return Scaffold(
      backgroundColor: AppColors.pointGray.withValues(alpha: 0.1),
      appBar: AppBar(
        title: const Text(''),
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
              color: AppColors.pointPink,
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
                color: AppColors.pointPink,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // 요일 반복 선택
        _buildDaySelection(),

        const SizedBox(height: AppSpacing.md),

        // 공휴일 제외 옵션 삭제됨
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
                  ? AppColors.pointPink
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
            initialValue: _selectedPet,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('ペットを選択してください'),
            items: pets.map((pet) {
              return DropdownMenuItem(value: pet, child: Text(pet.name));
            }).toList(),
            onChanged: (pet) {
              if (mounted) {
                setState(() {
                  _selectedPet = pet;
                  _updateTitleIfEmpty();
                });
              }
            },
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
                    onTap: () {
                      setState(() {
                        _selectedEventType = type;
                        _updateTitleIfEmpty();
                      });
                    },
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
                                    ? AppColors.pointPink
                                    : AppColors.pointDark,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.pointPink,
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
          '제목',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _titleController,
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
          onChanged: (value) {
            setState(() {
              _eventName = value;
            });
          },
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
          activeThumbColor: AppColors.pointPink,
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
                backgroundColor: AppColors.pointPink,
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

    if (date != null && mounted) {
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
    // BuildContext를 미리 저장 (비동기 작업 전)
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_selectedPet == null) {
      SnackBarService.showWarning(context, 'ペットを選択してください');
      return;
    }

    if (_eventName.isEmpty) {
      SnackBarService.showWarning(context, 'イベント名を入力してください');
      return;
    }

    try {
      // 종료 시간 설정
      DateTime endTime;
      if (_endTime != null) {
        endTime = _endTime!;
      } else if (_isAllDay) {
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

      // 캘린더 이벤트 생성 또는 업데이트
      final event = CalendarEventEntity(
        id:
            widget.initialEvent?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _eventName,
        description: _eventDescription.isNotEmpty ? _eventDescription : '일정',
        startTime: _selectedTime,
        endTime: endTime,
        isAllDay: _isAllDay,
        type: _selectedEventType,
        petId: _selectedPet!.id,
        petName: _selectedPet!.name,
        location: _eventLocation.isNotEmpty ? _eventLocation : null,
        hasAlarm: widget.initialEvent?.hasAlarm ?? false,
        alarmSettings: widget.initialEvent?.alarmSettings ?? [],
        recurrence: _isRepeating && _selectedDays.isNotEmpty
            ? CalendarEventRecurrence(
                type: CalendarRecurrenceType.weekly,
                daysOfWeek: _selectedDays,
                endDate: _selectedDate.add(const Duration(days: 365)),
              )
            : null,
        createdAt: widget.initialEvent?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 데이터베이스에 저장 또는 업데이트
      if (widget.initialEvent != null) {
        await CalendarEventService.instance.updateCalendarEvent(event);
      } else {
        await CalendarEventService.instance.saveCalendarEvent(event);
      }

      if (mounted) {
        // 먼저 화면을 닫고 (SnackBar 애니메이션 충돌 방지)
        navigator.pop(event);

        // 화면이 닫힌 후 SnackBar 표시 (부모 화면에서)
        Future.microtask(() {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  widget.initialEvent != null ? 'イベントが更新されました' : 'イベントが保存されました',
                ),
                backgroundColor: AppColors.pointGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      LoggerService.debug('❌ イベント保存エラー: $e');
      if (mounted) {
        // 미리 저장한 scaffoldMessenger 사용
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('イベントの保存に失敗しました: $e'),
            backgroundColor: AppColors.pointRed,
            behavior: SnackBarBehavior.floating,
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
    final isMinute =
        min == 0 && max == 59; // Determine if it's the minute wheel
    final controller = isMinute ? _minuteController : _hourController;
    final focusNode = isMinute
        ? _minuteFocusNode
        : _hourFocusNode; // Use focus node

    if (isEditing) {
      // 편집 모드: TextField 표시
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          focusNode: focusNode, // Assign focus node
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
            _handleTimeInputSubmission(
              controller: controller,
              min: min,
              max: max,
              onChanged: onChanged,
              isMinute: isMinute,
            );
          },
          onTap: () {
            // When tapping the TextField, ensure it's pre-filled with the current value
            controller.text = DateTimeUtils.formatTwoDigits(value);
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
              _minuteController.text = DateTimeUtils.formatTwoDigits(value);
              _minuteFocusNode.requestFocus(); // Request focus
            } else {
              _isEditingHour = true;
              _hourController.text = DateTimeUtils.formatTwoDigits(value);
              _hourFocusNode.requestFocus(); // Request focus
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              DateTimeUtils.formatTwoDigits(value),
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
