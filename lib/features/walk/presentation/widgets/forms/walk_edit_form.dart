import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/entities/walk_record_entity.dart';

/// 산책 편집 폼 위젯
class WalkEditForm extends StatefulWidget {
  final WalkRecordEntity walkRecord;
  final void Function(WalkRecordEntity) onSave;
  final VoidCallback? onCancel;

  const WalkEditForm({
    super.key,
    required this.walkRecord,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<WalkEditForm> createState() => _WalkEditFormState();
}

class _WalkEditFormState extends State<WalkEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _distanceController;
  late final TextEditingController _notesController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.walkRecord.title);
    _distanceController = TextEditingController(
      text: widget.walkRecord.distance?.toStringAsFixed(1) ?? '',
    );
    _notesController = TextEditingController(text: widget.walkRecord.notes ?? '');

    _startTime = TimeOfDay.fromDateTime(widget.walkRecord.startTime);
    _endTime = widget.walkRecord.endTime != null
        ? TimeOfDay.fromDateTime(widget.walkRecord.endTime!)
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목 필드
          WalkFormFields.buildTitleField(
            controller: _titleController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'タイトルは必須です';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // 거리 필드
          WalkFormFields.buildDistanceField(
            controller: _distanceController,
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final distance = double.tryParse(value);
              if (distance == null) {
                return '有効な数値を入力してください';
              }
              if (distance < 0 || distance > 100) {
                return '0-100kmの範囲で入力してください';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // 시간 필드들
          Row(
            children: [
              Expanded(
                child: WalkFormFields.buildStartTimeField(
                  initialValue: _startTime,
                  onChanged: (time) => setState(() => _startTime = time),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: WalkFormFields.buildStartTimeField(
                  initialValue: _endTime,
                  onChanged: (time) => setState(() => _endTime = time),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 메모 필드
          WalkFormFields.buildNotesField(
            controller: _notesController,
          ),

          const SizedBox(height: AppSpacing.xl),

          // 버튼들
          CommonFormPatterns.buildFormButtons(
            onSave: _handleSave,
            onCancel: widget.onCancel,
            saveText: '保存',
            cancelText: 'キャンセル',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedWalk = _buildUpdatedWalkRecord();
      widget.onSave(updatedWalk);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  WalkRecordEntity _buildUpdatedWalkRecord() {
    final distance = double.tryParse(_distanceController.text);

    // 시작/종료 시간 계산
    DateTime? startDateTime;
    DateTime? endDateTime;
    Duration? duration;

    if (_startTime != null) {
      final originalDate = widget.walkRecord.startTime;
      startDateTime = DateTime(
        originalDate.year,
        originalDate.month,
        originalDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      if (_endTime != null) {
        endDateTime = DateTime(
          originalDate.year,
          originalDate.month,
          originalDate.day,
          _endTime!.hour,
          _endTime!.minute,
        );

        // 종료 시간이 시작 시간보다 이르면 다음날로 간주
        if (endDateTime.isBefore(startDateTime)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
        }

        duration = endDateTime.difference(startDateTime);
      }
    }

    return widget.walkRecord.copyWith(
      title: _titleController.text.trim(),
      distance: distance,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      startTime: startDateTime ?? widget.walkRecord.startTime,
      endTime: endDateTime,
      duration: duration,
      updatedAt: DateTime.now(),
    );
  }
}