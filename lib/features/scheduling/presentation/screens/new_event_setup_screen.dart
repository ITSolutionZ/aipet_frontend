import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/scheduling/data/services/calendar_event_service.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('새 일정 추가'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: Colors.black87,
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
          color: isSelected ? AppColors.pointBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Text(
          isAm ? '오전' : '오후',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWheel({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      height: 120,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // 위쪽 화살표
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: value < max ? Colors.grey[600] : Colors.grey[300],
            ),
          ),

          // 현재 값
          Expanded(
            child: Center(
              child: Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // 아래쪽 화살표
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: value > min ? Colors.grey[600] : Colors.grey[300],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              '${_selectedDate.month}월 ${_selectedDate.day}일 (${_getWeekdayName(_selectedDate.weekday)})',
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
            const Text('공휴일에는 끄기'),
            const Spacer(),
            Switch(
              value: _excludeHolidays,
              onChanged: (value) => setState(() => _excludeHolidays = value),
              activeColor: AppColors.pointBlue,
            ),
          ],
        ),
        const Text(
          '대체 공휴일 및 임시공휴일 제외',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDaySelection() {
    final days = ['일', '월', '화', '수', '목', '금', '토'];
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
              color: isSelected ? AppColors.pointBlue : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
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
          '펫 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (pets.isEmpty)
          const Text(
            '등록된 펫이 없습니다',
            style: TextStyle(color: AppColors.pointGray),
          )
        else
          DropdownButtonFormField<PetProfileEntity>(
            value: _selectedPet,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('펫을 선택하세요'),
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
          '일정 카테고리',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: CalendarEventType.values.map((type) {
            final isSelected = _selectedEventType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedEventType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pointBlue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.pointGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEventName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '일정 이름',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: '일정 이름을 입력하세요',
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
          '설명',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '일정 설명을 입력하세요 (선택사항)',
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
          '위치',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: '위치를 입력하세요 (선택사항)',
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
          '하루 종일',
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('취소'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
              ),
              child: Text('저장', style: AppFonts.titleMedium),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
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
          content: Text('일정 이름을 입력해주세요'),
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
            content: Text('일정이 저장되었습니다'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 저장에 실패했습니다: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }
}
