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
    // notes에서 activities JSON과 일반 메모 분리
    final separatedNotes = _separateNotesAndActivities(walkRecord.notes);

    state = state.copyWith(
      originalWalkRecord: walkRecord,
      distance: walkRecord.distance?.toStringAsFixed(1) ?? '',
      notes: separatedNotes['userNotes'] ?? '',
      activitiesJson: separatedNotes['activities'],
      startTime: TimeOfDay.fromDateTime(walkRecord.startTime),
      endTime: walkRecord.endTime != null
          ? TimeOfDay.fromDateTime(walkRecord.endTime!)
          : null,
    );
  }

  /// notes에서 activities JSON과 일반 메모 분리
  Map<String, String?> _separateNotesAndActivities(String? notes) {
    if (notes == null || notes.isEmpty) {
      return {'userNotes': null, 'activities': null};
    }

    // activities: 로 시작하는 경우 activities만 추출
    if (notes.startsWith('activities:')) {
      return {'userNotes': null, 'activities': notes};
    }

    // activities:가 중간에 있는 경우 분리
    if (notes.contains('activities:')) {
      final parts = notes.split('activities:');
      return {
        'userNotes': parts[0].trim().isEmpty ? null : parts[0].trim(),
        'activities': 'activities:${parts[1]}',
      };
    }

    // 일반 메모만 있는 경우
    return {'userNotes': notes, 'activities': null};
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

    // notes 재구성: 사용자 메모 + activities JSON
    final String? finalNotes = _combinedNotes(
      state.notes,
      state.activitiesJson,
    );

    return originalWalk.copyWith(
      distance: distance,
      notes: finalNotes,
      startTime: startDateTime ?? originalWalk.startTime,
      endTime: endDateTime,
      duration: duration,
      updatedAt: DateTime.now(),
    );
  }

  /// 사용자 메모와 activities JSON 병합
  String? _combinedNotes(String userNotes, String? activitiesJson) {
    final trimmedNotes = userNotes.trim();

    // 둘 다 없으면 null
    if (trimmedNotes.isEmpty && activitiesJson == null) {
      return null;
    }

    // activities만 있으면 activities 반환
    if (trimmedNotes.isEmpty && activitiesJson != null) {
      return activitiesJson;
    }

    // 사용자 메모만 있으면 사용자 메모 반환
    if (trimmedNotes.isNotEmpty && activitiesJson == null) {
      return trimmedNotes;
    }

    // 둘 다 있으면 병합 (사용자 메모 + activities)
    return '$trimmedNotes\n$activitiesJson';
  }
}

class WalkEditFormState {
  final WalkRecordEntity? originalWalkRecord;
  final String distance;
  final String notes; // 사용자가 편집 가능한 메모
  final String? activitiesJson; // 펫 활동 JSON (편집 불가, 자동 보존)
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isLoading;

  const WalkEditFormState({
    this.originalWalkRecord,
    this.distance = '',
    this.notes = '',
    this.activitiesJson,
    this.startTime,
    this.endTime,
    this.isLoading = false,
  });

  WalkEditFormState copyWith({
    WalkRecordEntity? originalWalkRecord,
    String? distance,
    String? notes,
    String? activitiesJson,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isLoading,
  }) {
    return WalkEditFormState(
      originalWalkRecord: originalWalkRecord ?? this.originalWalkRecord,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
      activitiesJson: activitiesJson ?? this.activitiesJson,
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
    // notes에서 activities JSON과 일반 메모 분리
    final separatedNotes = _separateNotesAndActivities(widget.walkRecord.notes);

    _distanceController = TextEditingController(
      text: widget.walkRecord.distance?.toStringAsFixed(1) ?? '',
    );
    // 사용자 메모만 표시 (activities JSON은 숨김)
    _notesController = TextEditingController(
      text: separatedNotes['userNotes'] ?? '',
    );

    // Add listeners to sync with Riverpod state
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

  /// notes에서 activities JSON과 일반 메모 분리
  Map<String, String?> _separateNotesAndActivities(String? notes) {
    if (notes == null || notes.isEmpty) {
      return {'userNotes': null, 'activities': null};
    }

    // activities: 로 시작하는 경우 activities만 추출
    if (notes.startsWith('activities:')) {
      return {'userNotes': null, 'activities': notes};
    }

    // activities:가 포함된 경우 분리
    if (notes.contains('activities:')) {
      final parts = notes.split('activities:');
      return {
        'userNotes': parts[0].trim().isEmpty ? null : parts[0].trim(),
        'activities': 'activities:${parts[1]}',
      };
    }

    // 일반 메모만 있는 경우
    return {'userNotes': notes, 'activities': null};
  }

  @override
  void dispose() {
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
          // 제목은 자동 생성됨 (ペット名 + "の散歩")
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
                  initialValue: formState.startTime,
                  onChanged: (time) => ref
                      .read(walkEditFormProvider(_formId).notifier)
                      .updateStartTime(time),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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

          const SizedBox(height: AppSpacing.md),

          // 메모 필드
          WalkFormFields.buildNotesField(controller: _notesController),

          const SizedBox(height: AppSpacing.xl),

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
