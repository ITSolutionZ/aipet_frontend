import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/pet_health_state.dart';

/// 予約/スケジュール編集ダイアログ
class AppointmentEditDialog extends StatefulWidget {
  final AppointmentRecord? record; // null이면 새로 추가
  final Function(AppointmentRecord) onSave;

  const AppointmentEditDialog({
    super.key,
    this.record,
    required this.onSave,
  });

  @override
  State<AppointmentEditDialog> createState() => _AppointmentEditDialogState();
}

class _AppointmentEditDialogState extends State<AppointmentEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late String _selectedStatus;
  DateTime? _dateTime;
  String _selectedIconName = 'schedule';
  String _selectedColorName = 'blue';

  final List<String> _statusOptions = ['予約済み', '完了', 'キャンセル'];
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'schedule', 'icon': Icons.schedule, 'label': '予約'},
    {'name': 'content_cut', 'icon': Icons.content_cut, 'label': 'グルーミング'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': '診察'},
    {'name': 'vaccines', 'icon': Icons.vaccines, 'label': 'ワクチン'},
  ];
  final List<Map<String, String>> _colorOptions = [
    {'name': 'blue', 'label': '青'},
    {'name': 'pink', 'label': 'ピンク'},
    {'name': 'green', 'label': '緑'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record?.title ?? '');
    _locationController =
        TextEditingController(text: widget.record?.location ?? '');
    _selectedStatus = widget.record?.status ?? '予約済み';
    _dateTime = widget.record?.dateTime;
    _selectedIconName = widget.record?.iconName ?? 'schedule';
    _selectedColorName = widget.record?.colorName ?? 'blue';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? '予約編集' : '予約追加',
                      style: AppFonts.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // タイトル
              Text(
                'タイトル',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '例: 次回健康診断',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 日時
              Text(
                '日時',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildDateTimeSelector(
                dateTime: _dateTime,
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: AppSpacing.md),

              // 場所
              Text(
                '場所',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: '例: 田中動物病院',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 状態選択
              Text(
                '状態',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: _statusOptions.map((status) {
                  final isSelected = _selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      }
                    },
                    selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.pointBrown
                          : AppColors.pointGray,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: const BorderSide(color: AppColors.pointGray),
                      ),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointBrown,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: const Text('保存'),
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

  Widget _buildDateTimeSelector(
      {required DateTime? dateTime, required VoidCallback onTap}) {
    final dateFormat = DateFormat('yyyy年M月d日 HH:mm');
    final dateText = dateTime != null ? dateFormat.format(dateTime) : '日時を選択';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color:
                  dateTime != null ? AppColors.pointBrown : AppColors.pointGray,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                dateText,
                style: AppFonts.bodyMedium.copyWith(
                  color:
                      dateTime != null ? AppColors.pointDark : AppColors.pointGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final initialDate = _dateTime ?? DateTime.now();

    // 日付選択
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('ja', 'JP'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pointBrown,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.pointDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    // 時刻選択
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pointBrown,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.pointDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _handleSave() {
    // バリデーション
    if (_titleController.text.trim().isEmpty) {
      SnackBarService.showError(context, 'タイトルを入力してください');
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      SnackBarService.showError(context, '場所を入力してください');
      return;
    }

    if (_dateTime == null) {
      SnackBarService.showError(context, '日時を選択してください');
      return;
    }

    // 新しいレコード生成
    final newRecord = AppointmentRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      dateTime: _dateTime!,
      location: _locationController.text.trim(),
      status: _selectedStatus,
      iconName: _selectedIconName,
      colorName: _selectedColorName,
    );

    widget.onSave(newRecord);
    Navigator.pop(context);
  }
}
