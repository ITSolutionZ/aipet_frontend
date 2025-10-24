import 'package:aipet_frontend/shared/shared.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? '予定を編集' : '新しい予定', style: AppFonts.titleLarge),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: AppColors.pointGray),
        ),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
            child: Text('保存', style: AppFonts.titleMedium),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.pointBlue,
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
                  prefixIcon: const Icon(
                    Icons.title,
                    color: AppColors.pointBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: const BorderSide(color: AppColors.pointGray),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
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
                      activeThumbColor: AppColors.pointBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 시간 설정 (하루 종일이 아닐 때만)
              if (!_isAllDay) ...[
                _buildSectionTitle('時間'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        '開始時間',
                        _startTime,
                        Icons.play_arrow,
                        _selectStartTime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeSelector(
                        '終了時間',
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
              _buildSectionTitle('説明'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '予定の説明を入力してください (オプション)',
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
              _buildSectionTitle('場所'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: '場所を入力してください (オプション)',
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
                    backgroundColor: AppColors.pointBlue,
                    foregroundColor: AppColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: Text(
                    isEditing ? '予定を編集' : '予定を追加',
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
      style: AppFonts.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.pointGray,
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
              time != null
                  ? DateFormat('HH:mm', 'ja_JP').format(time)
                  : '時間を選択',
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
          SnackBarService.showWarning(context, '終了時間は開始時間より遅い必要があります');
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
      ).showSnackBar(const SnackBar(content: Text('開始時間と終了時間を設定してください')));
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
