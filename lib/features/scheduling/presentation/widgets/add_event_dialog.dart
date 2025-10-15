import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:aipet_frontend/shared/shared.dart' hide State;

import '../../domain/entities/calendar_event_entity.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(CalendarEventEntity) onEventAdded;
  final CalendarEventEntity? initialEvent;

  const AddEventDialog({
    super.key,
    required this.selectedDate,
    required this.onEventAdded,
    this.initialEvent,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  CalendarEventType _selectedType = CalendarEventType.feeding;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();

    // 편집 모드인지 확인
    if (widget.initialEvent != null) {
      final event = widget.initialEvent!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.location ?? '';
      _selectedType = event.type;
      _startTime = event.startTime;
      _endTime = event.endTime;
      _isAllDay = event.isAllDay ?? false;
    } else {
      // 기본 시간 설정 (오전 9시 ~ 10시)
      _startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        9,
        0,
      );
      _endTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        10,
        0,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Text(
                    widget.initialEvent != null ? '일정 편집' : '새 일정 추가',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 폼 내용을 스크롤 가능하게
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text('제목', style: AppFonts.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: '일정 제목을 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 일정 타입
                      Text('카테고리', style: AppFonts.titleSmall),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CalendarEventType>(
                            value: _selectedType,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: CalendarEventType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Text(type.emoji, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(type.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 하루 종일 토글
                      Row(
                        children: [
                          Checkbox(
                            value: _isAllDay,
                            onChanged: (value) {
                              setState(() {
                                _isAllDay = value ?? false;
                              });
                            },
                          ),
                          Text('하루 종일', style: AppFonts.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 시간 설정 (하루 종일이 아닐 때만)
                      if (!_isAllDay) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('시작 시간', style: AppFonts.titleSmall),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectStartTime,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time),
                                          const SizedBox(width: 8),
                                          Text(
                                            _startTime != null
                                                ? DateFormat('HH:mm').format(_startTime!)
                                                : '시간 선택',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('종료 시간', style: AppFonts.titleSmall),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectEndTime,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time),
                                          const SizedBox(width: 8),
                                          Text(
                                            _endTime != null
                                                ? DateFormat('HH:mm').format(_endTime!)
                                                : '시간 선택',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 설명
                      Text('설명', style: AppFonts.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: '일정 설명을 입력하세요 (선택사항)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 위치
                      Text('위치', style: AppFonts.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: '위치를 입력하세요 (선택사항)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointBrown,
                        foregroundColor: AppColors.pureWhite,
                      ),
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
    );

    if (time != null) {
      setState(() {
        _startTime = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          time.hour,
          time.minute,
        );

        // 종료 시간이 시작 시간보다 이전이면 자동으로 1시간 후로 설정
        if (_endTime != null && _endTime!.isBefore(_startTime!)) {
          _endTime = _startTime!.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime ?? DateTime.now()),
    );

    if (time != null) {
      final newEndTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        time.hour,
        time.minute,
      );

      // 종료 시간이 시작 시간보다 이후인지 확인
      if (_startTime != null && newEndTime.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('종료 시간은 시작 시간보다 늦어야 합니다'),
          ),
        );
        return;
      }

      setState(() {
        _endTime = newEndTime;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAllDay && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작 시간과 종료 시간을 설정해주세요')),
      );
      return;
    }

    // 이벤트 생성 (편집 모드일 때는 기존 ID 유지)
    final event = CalendarEventEntity(
      id: widget.initialEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: _isAllDay
          ? DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day)
          : _startTime!,
      endTime: _isAllDay
          ? DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 23, 59)
          : _endTime!,
      type: _selectedType,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      isAllDay: _isAllDay,
      createdAt: widget.initialEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onEventAdded(event);
    Navigator.pop(context);
  }
}