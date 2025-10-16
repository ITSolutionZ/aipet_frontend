import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_event_entity.dart';

class AddEventBottomSheet extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final CalendarEventEntity? initialEvent;

  const AddEventBottomSheet({
    super.key,
    required this.selectedDate,
    this.initialEvent,
  });

  @override
  ConsumerState<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends ConsumerState<AddEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  CalendarEventType _selectedType = CalendarEventType.feeding;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isAllDay = false;
  bool _hasAlarm = false;
  List<AlarmSetting> _alarmSettings = [];

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
      _hasAlarm = event.hasAlarm;
      _alarmSettings = [...event.alarmSettings];
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

      // 신규 이벤트의 경우 기본 알람 설정 적용
      _updateAlarmForEventType(_selectedType);
    }
  }

  /// 이벤트 타입에 따라 알람 설정 업데이트
  void _updateAlarmForEventType(CalendarEventType type) {
    final shouldHaveDefaultAlarm = CalendarEventEntity.shouldHaveDefaultAlarm(type);

    if (shouldHaveDefaultAlarm && widget.initialEvent == null) {
      setState(() {
        _hasAlarm = true;
        _alarmSettings = CalendarEventEntity.getDefaultAlarmsForType(type);
      });
    } else if (!shouldHaveDefaultAlarm && widget.initialEvent == null) {
      setState(() {
        _hasAlarm = false;
        _alarmSettings = [];
      });
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

    return Container(
      height: MediaQuery.of(context).size.height * 1.0, // 100% height
      decoration: const BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Column(
        children: [
          // ハンドルとヘッダー
          _buildHeader(isEditing),

          // コンテンツ
          Expanded(
            child: _buildContent(isEditing),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.pointBrown,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Column(
        children: [
          // ハンドル
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ヘッダー
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.pureWhite),
              ),
              Expanded(
                child: Text(
                  isEditing ? '일정 편집' : '새 일정 추가',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _buildContent(bool isEditing) {
    return Form(
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
                        '選択された日付',
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
            _buildSectionTitle('タイトル'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'スケジュールのタイトルを入力してください',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                filled: true,
                fillColor: AppColors.pureWhite,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 카테고리
            _buildSectionTitle('カテゴリ'),
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
                      // 이벤트 타입 변경 시 알람 설정 업데이트
                      _updateAlarmForEventType(value);
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
                      '終日',
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

            // アラーム設定
            _buildSectionTitle('アラーム'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasAlarm ? Icons.alarm_on : Icons.alarm_off,
                        color: _hasAlarm ? AppColors.pointBrown : AppColors.pointGray,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'アラームを設定',
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: _hasAlarm,
                        onChanged: (value) {
                          setState(() {
                            _hasAlarm = value;
                            if (value && _alarmSettings.isEmpty) {
                              _alarmSettings = [const AlarmSetting(minutesBefore: 10)];
                            }
                          });
                        },
                        activeColor: AppColors.pointBrown,
                      ),
                    ],
                  ),
                  if (_hasAlarm) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildAlarmList(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 설명
            _buildSectionTitle('説明'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'スケジュールの説明を入力してください（任意）',
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
                hintText: '場所を入力してください（任意）',
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
                  isEditing ? 'スケジュール修正' : 'スケジュール追加',
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
              time != null ? DateFormat('HH:mm', 'ja_JP').format(time) : '時間選択',
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
            const SnackBar(content: Text('終了時間は開始時間より遅い必要があります')),
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
      ).showSnackBar(const SnackBar(content: Text('開始時間と終了時間を設定してください')));
      return;
    }

    // 이벤트 생성 또는 편집
    final event = widget.initialEvent == null
        ? CalendarEventEntity.withDefaultAlarms(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
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
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : CalendarEventEntity(
            id: widget.initialEvent!.id,
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
            createdAt: widget.initialEvent!.createdAt,
            updatedAt: DateTime.now(),
            hasAlarm: _hasAlarm,
            alarmSettings: _alarmSettings,
          );

    // 결과와 함께 뒤로 가기
    Navigator.pop(context, event);
  }

  /// アラームリストを構築
  Widget _buildAlarmList() {
    return Column(
      children: [
        // 既存のアラーム設定一覧
        ..._alarmSettings.asMap().entries.map((entry) {
          final index = entry.key;
          final alarm = entry.value;
          return _buildAlarmItem(alarm, index);
        }),
        const SizedBox(height: 8),
        // アラーム追加ボタン
        InkWell(
          onTap: _showAddAlarmDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: AppColors.pointBrown,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'アラームを追加',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 個別のアラーム項目を構築
  Widget _buildAlarmItem(AlarmSetting alarm, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            alarm.type.icon,
            size: 20,
            color: AppColors.pointBrown,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.displayText,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  alarm.type.displayName,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _alarmSettings.removeAt(index);
                if (_alarmSettings.isEmpty) {
                  _hasAlarm = false;
                }
              });
            },
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.pointRed,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// アラーム追加ダイアログを表示
  void _showAddAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アラーム設定'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AlarmSettingExtension.presets.length,
            itemBuilder: (context, index) {
              final preset = AlarmSettingExtension.presets[index];
              return ListTile(
                leading: Icon(preset.type.icon),
                title: Text(preset.displayText),
                subtitle: Text(preset.type.displayName),
                onTap: () {
                  setState(() {
                    _alarmSettings.add(preset);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}