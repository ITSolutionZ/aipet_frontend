import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_event_entity.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final CalendarEventEntity? initialEvent;

  const AddEventScreen({
    super.key,
    required this.selectedDate,
    this.initialEvent,
  });

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
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
    final isEditing = widget.initialEvent != null;

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointBrown,
        foregroundColor: AppColors.pureWhite,
        title: Text(
          isEditing ? '일정 편집' : '새 일정 추가',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: Text(
              '저장',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 선택된 날짜 표시
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pointBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.pointBrown,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 날짜',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'yyyy年 M月 d日 (E)',
                            'ja_JP',
                          ).format(widget.selectedDate),
                          style: AppFonts.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 제목
              _buildSectionTitle('제목'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '일정 제목을 입력하세요',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 카테고리
              _buildSectionTitle('카테고리'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CalendarEventType>(
                    value: _selectedType,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: CalendarEventType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(type.displayName, style: AppFonts.bodyMedium),
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
              const SizedBox(height: 24),

              // 하루 종일 토글
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAllDay ? Icons.event : Icons.schedule,
                      color: AppColors.pointBrown,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '하루 종일',
                        style: AppFonts.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                      activeColor: AppColors.pointBrown,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 시간 설정 (하루 종일이 아닐 때만)
              if (!_isAllDay) ...[
                _buildSectionTitle('시간'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        '시작 시간',
                        _startTime,
                        Icons.play_arrow,
                        _selectStartTime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeSelector(
                        '종료 시간',
                        _endTime,
                        Icons.stop,
                        _selectEndTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 설명
              _buildSectionTitle('설명'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '일정 설명을 입력하세요 (선택사항)',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 24),

              // 위치
              _buildSectionTitle('위치'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: '위치를 입력하세요 (선택사항)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: AppColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: Text(
                    isEditing ? '일정 수정' : '일정 추가',
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.pointBrown,
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    DateTime? time,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.pointGray),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time != null ? DateFormat('HH:mm', 'ja_JP').format(time) : '시간 선택',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('종료 시간은 시작 시간보다 늦어야 합니다')),
          );
        }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시작 시간과 종료 시간을 설정해주세요')));
      return;
    }

    // 이벤트 생성 (편집 모드일 때는 기존 ID 유지)
    final event = CalendarEventEntity(
      id:
          widget.initialEvent?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: _isAllDay
          ? DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
            )
          : _startTime!,
      endTime: _isAllDay
          ? DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              23,
              59,
            )
          : _endTime!,
      type: _selectedType,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isAllDay: _isAllDay,
      createdAt: widget.initialEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 결과와 함께 뒤로 가기
    context.pop(event);
  }
}
