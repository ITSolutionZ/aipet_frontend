import 'package:flutter/material.dart';

import 'package:intl/intl.dart';


import '../../../../../../../shared/shared.dart';
import '../controllers/pet_health_state.dart';


/// 예방접종 기록 편집 다이얼로그
class VaccinationEditDialog extends StatefulWidget {
  final VaccinationRecord? record; // null이면 새로 추가
  final Function(VaccinationRecord) onSave;

  const VaccinationEditDialog({
    super.key,
    this.record,
    required this.onSave,
  });

  @override
  State<VaccinationEditDialog> createState() => _VaccinationEditDialogState();
}

class _VaccinationEditDialogState extends State<VaccinationEditDialog> {
  late TextEditingController _nameController;
  late String _selectedStatus;
  DateTime? _lastDate;
  DateTime? _nextDate;
  String _selectedIconName = 'vaccines';
  String _selectedColorName = 'green';

  final List<String> _statusOptions = ['接種中', '接種完了', '期限切れ'];
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'vaccines', 'icon': Icons.vaccines, 'label': 'ワクチン'},
    {'name': 'healing', 'icon': Icons.healing, 'label': '治療'},
    {'name': 'bug_report', 'icon': Icons.bug_report, 'label': '予防'},
  ];
  final List<Map<String, String>> _colorOptions = [
    {'name': 'green', 'label': '緑'},
    {'name': 'blue', 'label': '青'},
    {'name': 'pink', 'label': 'ピンク'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.record?.name ?? '');
    _lastDate = widget.record?.lastDate;
    _nextDate = widget.record?.nextDate;

    // 状態の自動判定: 次回接種日があれば「接種中」、なければ「接種完了」
    _selectedStatus = widget.record?.status ??
        (_nextDate != null ? '接種中' : '接種完了');

    _selectedIconName = widget.record?.iconName ?? 'vaccines';
    _selectedColorName = widget.record?.colorName ?? 'green';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
              // 헤더
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? '予防接種記録編集' : '予防接種記録追加',
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

              // 예방접종 이름
              Text(
                '予防接種名',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '例: コアワクチン',
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

              // 상태 선택
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
              const SizedBox(height: AppSpacing.md),

              // 전회 날짜
              Text(
                '前回接種日',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildDateSelector(
                date: _lastDate,
                onTap: () => _selectDate(context, isLastDate: true),
              ),
              const SizedBox(height: AppSpacing.md),

              // 다음 날짜
              Text(
                '次回接種日',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 前回接種日からの期間選択ボタン + 接種完了ボタン
              if (_lastDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildMonthButton(1),
                      _buildMonthButton(3),
                      _buildMonthButton(6),
                      _buildMonthButton(12),
                      _buildCompletedButton(),
                    ],
                  ),
                ),

              _buildDateSelector(
                date: _nextDate,
                onTap: () => _selectDate(context, isLastDate: false),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 버튼
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

  /// ○ヶ月後ボタンを作成
  Widget _buildMonthButton(int months) {
    final label = months == 12 ? '1年後' : '$monthsヶ月後';

    return OutlinedButton(
      onPressed: () {
        if (_lastDate != null) {
          setState(() {
            _nextDate = DateTime(
              _lastDate!.year,
              _lastDate!.month + months,
              _lastDate!.day,
            );
          });
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        side: BorderSide(
          color: AppColors.pointBrown.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.pointBrown,
        ),
      ),
    );
  }

  /// 接種完了ボタンを作成（次回接種日を削除）
  Widget _buildCompletedButton() {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _nextDate = null;
          _selectedStatus = '接種完了';
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        side: BorderSide(
          color: AppColors.pointGreen.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
      child: const Text(
        '接種完了',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.pointGreen,
        ),
      ),
    );
  }

  Widget _buildDateSelector({required DateTime? date, required VoidCallback onTap}) {
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

  Future<void> _selectDate(BuildContext context, {required bool isLastDate}) async {
    final initialDate = isLastDate
        ? (_lastDate ?? DateTime.now())
        : (_nextDate ?? DateTime.now().add(const Duration(days: 365)));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
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

    if (pickedDate != null) {
      setState(() {
        if (isLastDate) {
          _lastDate = pickedDate;
        } else {
          _nextDate = pickedDate;
        }
      });
    }
  }

  void _handleSave() {
    // 유효성 검사
    if (_nameController.text.trim().isEmpty) {
      SnackBarService.showError(context, '予防接種名を入力してください');
      return;
    }

    // 状態の自動判定: 次回接種日があれば「接種中」、なければ「接種完了」
    final autoStatus = _nextDate != null ? '接種中' : '接種完了';

    // 새 레코드 생성
    final newRecord = VaccinationRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      status: autoStatus,
      lastDate: _lastDate,
      nextDate: _nextDate,
      iconName: _selectedIconName,
      colorName: _selectedColorName,
    );

    widget.onSave(newRecord);
    Navigator.pop(context);
  }
}
