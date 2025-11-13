import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/pet_health_state.dart';

/// 診療記録編集ダイアログ
class MedicalRecordEditDialog extends StatefulWidget {
  final MedicalRecord? record; // null이면 새로 추가
  final Function(MedicalRecord) onSave;

  const MedicalRecordEditDialog({
    super.key,
    this.record,
    required this.onSave,
  });

  @override
  State<MedicalRecordEditDialog> createState() =>
      _MedicalRecordEditDialogState();
}

class _MedicalRecordEditDialogState extends State<MedicalRecordEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _hospitalController;
  late String _selectedStatus;
  DateTime? _date;
  String _selectedIconName = 'local_hospital';
  String _selectedColorName = 'pink';

  final List<String> _statusOptions = ['正常', '要注意', '完了', '治療中'];
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': '病院'},
    {'name': 'cleaning_services', 'icon': Icons.cleaning_services, 'label': 'ケア'},
    {'name': 'medication', 'icon': Icons.medication, 'label': '投薬'},
    {'name': 'emergency', 'icon': Icons.emergency, 'label': '緊急'},
  ];
  final List<Map<String, String>> _colorOptions = [
    {'name': 'pink', 'label': 'ピンク'},
    {'name': 'blue', 'label': '青'},
    {'name': 'green', 'label': '緑'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record?.title ?? '');
    _hospitalController =
        TextEditingController(text: widget.record?.hospital ?? '');
    _selectedStatus = widget.record?.status ?? '正常';
    _date = widget.record?.date;
    _selectedIconName = widget.record?.iconName ?? 'local_hospital';
    _selectedColorName = widget.record?.colorName ?? 'pink';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hospitalController.dispose();
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
                      isEditing ? '診療記録編集' : '診療記録追加',
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

              // 診療内容
              Text(
                '診療内容',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '例: 定期健康診断',
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

              // 診療日
              Text(
                '診療日',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildDateSelector(
                date: _date,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: AppSpacing.md),

              // 病院名
              Text(
                '病院名',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _hospitalController,
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

  Widget _buildDateSelector(
      {required DateTime? date, required VoidCallback onTap}) {
    final dateFormat = DateFormat('yyyy年M月d日');
    final dateText = date != null ? dateFormat.format(date) : '日付を選択';

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
              color: date != null ? AppColors.pointBrown : AppColors.pointGray,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                dateText,
                style: AppFonts.bodyMedium.copyWith(
                  color: date != null ? AppColors.pointDark : AppColors.pointGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _date ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  void _handleSave() {
    // バリデーション
    if (_titleController.text.trim().isEmpty) {
      SnackBarService.showError(context, '診療内容を入力してください');
      return;
    }

    if (_hospitalController.text.trim().isEmpty) {
      SnackBarService.showError(context, '病院名を入力してください');
      return;
    }

    if (_date == null) {
      SnackBarService.showError(context, '診療日を選択してください');
      return;
    }

    // 新しいレコード生成
    final newRecord = MedicalRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _date!,
      hospital: _hospitalController.text.trim(),
      status: _selectedStatus,
      iconName: _selectedIconName,
      colorName: _selectedColorName,
    );

    widget.onSave(newRecord);
    Navigator.pop(context);
  }
}
