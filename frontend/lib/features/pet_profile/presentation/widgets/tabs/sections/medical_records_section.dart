import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/shared.dart';
import '../../../controllers/pet_profile_unified_controller.dart';

/// 진료 기록 섹션
///
/// Pet Health Tab에서 분리된 독립적인 위젯
/// 진료 기록의 CRUD를 담당합니다.
class MedicalRecordsSection extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const MedicalRecordsSection({
    super.key,
    required this.pet,
    this.isEditMode = false,
  });

  @override
  ConsumerState<MedicalRecordsSection> createState() =>
      _MedicalRecordsSectionState();
}

class _MedicalRecordsSectionState extends ConsumerState<MedicalRecordsSection> {
  late List<Map<String, dynamic>> _medicalRecords;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecordsData();
  }

  @override
  void didUpdateWidget(MedicalRecordsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pet.id != widget.pet.id ||
        (oldWidget.isEditMode && !widget.isEditMode)) {
      LoggerService.debug('🔄 진료 기록 데이터 갱신');
      _loadMedicalRecordsData();
    }
  }

  void _loadMedicalRecordsData() {
    final additionalInfo = widget.pet.additionalInfo ?? {};
    _medicalRecords =
        (additionalInfo['medicalRecords'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    LoggerService.debug('✅ 진료 기록 ${_medicalRecords.length}건 로드');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '診療記録',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            if (widget.isEditMode)
              TextButton.icon(
                onPressed: _showAddMedicalRecordDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_medicalRecords.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '診療記録がありません',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
            ),
          )
        else
          ..._medicalRecords.map((record) {
            final statusColor = _getMedicalStatusColor(record['status']);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GenericInfoCard.withIcon(
                icon: Icons.local_hospital,
                iconColor: AppColors.pointPink,
                iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
                title: record['title'] ?? '',
                subtitle:
                    '${_formatDate(record['date'])} • ${record['hospital'] ?? ''}',
                badge: record['status'] ?? '',
                badgeColor: statusColor,
              ),
            );
          }),
      ],
    );
  }

  Color _getMedicalStatusColor(String? status) {
    switch (status) {
      case '正常':
        return AppColors.pointGreen;
      case '要観察':
        return AppColors.pointBlue;
      case '要治療':
        return AppColors.pointRed;
      case '完了':
        return AppColors.pointGreen;
      default:
        return AppColors.pointGray;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return '';
    }
  }

  void _showAddMedicalRecordDialog() {
    final titleController = TextEditingController();
    final hospitalController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedStatus = '正常';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('診療記録を追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '診療内容',
                    hintText: '例: 定期健康診断',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(
                    labelText: '病院名',
                    hintText: '例: 田中動物病院',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  title: const Text('診療日'),
                  subtitle: Text(
                    '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('ja', 'JP'),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: '診療結果'),
                  items: ['正常', '要観察', '要治療', '完了']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    hospitalController.text.isEmpty) {
                  SnackBarService.showWarning(context, '診療内容と病院名を入力してください');
                  return;
                }

                setState(() {
                  _medicalRecords.add({
                    'title': titleController.text,
                    'hospital': hospitalController.text,
                    'date': selectedDate.toIso8601String(),
                    'status': selectedStatus,
                  });
                });

                _saveMedicalRecordsToFormData();

                Navigator.pop(context);
                SnackBarService.showSuccess(context, '診療記録を追加しました');
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedicalRecordsToFormData() {
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('medicalRecords', _medicalRecords);

    LoggerService.debug('💾 진료 기록 저장: ${_medicalRecords.length}건');
  }
}
