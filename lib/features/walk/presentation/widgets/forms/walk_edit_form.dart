import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Walk Edit Form State Provider
final walkEditFormProvider =
    StateNotifierProvider.family<
      WalkEditFormController,
      WalkEditFormState,
      String
    >((ref, formId) => WalkEditFormController());

class WalkEditFormController extends StateNotifier<WalkEditFormState> {
  WalkEditFormController() : super(const WalkEditFormState());

  void initialize(WalkRecordEntity walkRecord) {
    state = state.copyWith(
      originalWalkRecord: walkRecord,
      title: walkRecord.title,
      distance: walkRecord.distance?.toStringAsFixed(1) ?? '',
      notes: walkRecord.notes ?? '',
      startTime: TimeOfDay.fromDateTime(walkRecord.startTime),
      endTime: walkRecord.endTime != null
          ? TimeOfDay.fromDateTime(walkRecord.endTime!)
          : null,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDistance(String distance) {
    state = state.copyWith(distance: distance);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void updateStartTime(TimeOfDay? startTime) {
    state = state.copyWith(startTime: startTime);
  }

  void updateEndTime(TimeOfDay? endTime) {
    state = state.copyWith(endTime: endTime);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  WalkRecordEntity buildUpdatedWalkRecord() {
    final distance = double.tryParse(state.distance);
    final originalWalk = state.originalWalkRecord!;

    // 시작/종료 시간 계산
    DateTime? startDateTime;
    DateTime? endDateTime;
    Duration? duration;

    if (state.startTime != null) {
      final originalDate = originalWalk.startTime;
      startDateTime = DateTime(
        originalDate.year,
        originalDate.month,
        originalDate.day,
        state.startTime!.hour,
        state.startTime!.minute,
      );

      if (state.endTime != null) {
        endDateTime = DateTime(
          originalDate.year,
          originalDate.month,
          originalDate.day,
          state.endTime!.hour,
          state.endTime!.minute,
        );

        // 종료 시간이 시작 시간보다 이르면 다음날로 간주
        if (endDateTime.isBefore(startDateTime)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
        }

        duration = endDateTime.difference(startDateTime);
      }
    }

    return originalWalk.copyWith(
      distance: distance,
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      startTime: startDateTime ?? originalWalk.startTime,
      endTime: endDateTime,
      duration: duration,
      updatedAt: DateTime.now(),
    );
  }
}

class WalkEditFormState {
  final WalkRecordEntity? originalWalkRecord;
  final String title;
  final String distance;
  final String notes;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isLoading;

  const WalkEditFormState({
    this.originalWalkRecord,
    this.title = '',
    this.distance = '',
    this.notes = '',
    this.startTime,
    this.endTime,
    this.isLoading = false,
  });

  WalkEditFormState copyWith({
    WalkRecordEntity? originalWalkRecord,
    String? title,
    String? distance,
    String? notes,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isLoading,
  }) {
    return WalkEditFormState(
      originalWalkRecord: originalWalkRecord ?? this.originalWalkRecord,
      title: title ?? this.title,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 산책 편집 폼 위젯
class WalkEditForm extends ConsumerStatefulWidget {
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
  ConsumerState<WalkEditForm> createState() => _WalkEditFormState();
}

class _WalkEditFormState extends ConsumerState<WalkEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _distanceController;
  late final TextEditingController _notesController;
  final String _formId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Initialize Riverpod state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(walkEditFormProvider(_formId).notifier)
          .initialize(widget.walkRecord);
    });
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.walkRecord.title);
    _distanceController = TextEditingController(
      text: widget.walkRecord.distance?.toStringAsFixed(1) ?? '',
    );
    _notesController = TextEditingController(
      text: widget.walkRecord.notes ?? '',
    );

    // Add listeners to sync with Riverpod state
    _titleController.addListener(() {
      ref
          .read(walkEditFormProvider(_formId).notifier)
          .updateTitle(_titleController.text);
    });
    _distanceController.addListener(() {
      ref
          .read(walkEditFormProvider(_formId).notifier)
          .updateDistance(_distanceController.text);
    });
    _notesController.addListener(() {
      ref
          .read(walkEditFormProvider(_formId).notifier)
          .updateNotes(_notesController.text);
    });
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
    final formState = ref.watch(walkEditFormProvider(_formId));

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

          const const const SizedBox(height: AppSpacing.md),

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

          const const const SizedBox(height: AppSpacing.md),

          // 시간 필드들
          Row(
            children: [
              Expanded(
                child: WalkFormFields.buildStartTimeField(
                  initialValue: formState.startTime,
                  onChanged: (time) => ref
                      .read(walkEditFormProvider(_formId).notifier)
                      .updateStartTime(time),
                ),
              ),
              const const const SizedBox(width: AppSpacing.md),
              Expanded(
                child: WalkFormFields.buildStartTimeField(
                  initialValue: formState.endTime,
                  onChanged: (time) => ref
                      .read(walkEditFormProvider(_formId).notifier)
                      .updateEndTime(time),
                ),
              ),
            ],
          ),

          const const const SizedBox(height: AppSpacing.md),

          // 메모 필드
          WalkFormFields.buildNotesField(controller: _notesController),

          const const const SizedBox(height: AppSpacing.xl),

          // 버튼들
          CommonFormPatterns.buildFormButtons(
            onSave: _handleSave,
            onCancel: widget.onCancel,
            saveText: '保存',
            cancelText: 'キャンセル',
            isLoading: formState.isLoading,
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(walkEditFormProvider(_formId).notifier).setLoading(true);

    try {
      final updatedWalk = ref
          .read(walkEditFormProvider(_formId).notifier)
          .buildUpdatedWalkRecord();
      widget.onSave(updatedWalk);
    } finally {
      if (mounted) {
        ref.read(walkEditFormProvider(_formId).notifier).setLoading(false);
      }
    }
  }
}
