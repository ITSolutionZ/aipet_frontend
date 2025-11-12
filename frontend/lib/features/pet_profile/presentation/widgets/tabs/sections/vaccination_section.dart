import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/shared.dart';
import '../../../controllers/pet_profile_unified_controller.dart';
import '../../../models/vaccine_models.dart';

/// 예방접종 기록 섹션
///
/// Pet Health Tab에서 분리된 독립적인 위젯
/// 예방접종 기록의 CRUD를 담당합니다.
class VaccinationSection extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const VaccinationSection({
    super.key,
    required this.pet,
    this.isEditMode = false,
  });

  @override
  ConsumerState<VaccinationSection> createState() => _VaccinationSectionState();
}

class _VaccinationSectionState extends ConsumerState<VaccinationSection> {
  late List<VaccinationRecord> _vaccinationRecords;

  @override
  void initState() {
    super.initState();
    _loadVaccinationData();
  }

  @override
  void didUpdateWidget(VaccinationSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // pet이 변경되거나 편집 모드가 종료되면 데이터 갱신
    if (oldWidget.pet.id != widget.pet.id ||
        (oldWidget.isEditMode && !widget.isEditMode)) {
      LoggerService.debug('🔄 예방접종 데이터 갱신');
      _loadVaccinationData();
    }
  }

  void _loadVaccinationData() {
    final additionalInfo = widget.pet.additionalInfo ?? {};

    // ワクチン接種記録ロード
    final vaccinationsData = additionalInfo['vaccinations'] as List<dynamic>?;
    if (vaccinationsData != null && vaccinationsData.isNotEmpty) {
      _vaccinationRecords = vaccinationsData
          .map((v) => VaccinationRecord.fromMap(v as Map<String, dynamic>))
          .toList();
      LoggerService.debug('✅ ワクチン接種記録 ${_vaccinationRecords.length}件ロード');
    } else {
      _vaccinationRecords = [];
      LoggerService.debug('ℹ️  ワクチン接種記録なし');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 코어백신과 추가백신 분리
    final coreVaccines = _vaccinationRecords
        .where((r) => r.type.category == 'コアワクチン')
        .toList();
    final additionalVaccines = _vaccinationRecords
        .where((r) => r.type.category == '追加ワクチン')
        .toList();
    final mandatoryVaccines = _vaccinationRecords
        .where((r) => r.type.category == '法定接種')
        .toList();
    final preventiveMeds = _vaccinationRecords
        .where((r) => r.type.category == '予防薬')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '予防接種記録',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            if (widget.isEditMode)
              TextButton.icon(
                onPressed: _showAddVaccineDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 백신 기록이 전혀 없을 때
        if (_vaccinationRecords.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.vaccines,
                  size: 48,
                  color: AppColors.pointGray.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '予防接種記録がありません',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '編集モードで「追加」ボタンからワクチンを追加してください',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        // 코어백신 5종 (필수)
        if (coreVaccines.isNotEmpty) ...[
          _buildVaccineCategoryHeader(
            'コアワクチン (5種)',
            Icons.shield,
            AppColors.pointGreen,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...coreVaccines.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildVaccinationCard(record),
            ),
          ),
        ],

        // 법정 접종
        if (mandatoryVaccines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildVaccineCategoryHeader(
            '法定接種 (必須)',
            Icons.gavel,
            AppColors.pointRed,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...mandatoryVaccines.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildVaccinationCard(record),
            ),
          ),
        ],

        // 기생충 예방
        if (preventiveMeds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildVaccineCategoryHeader(
            '寄生虫予防',
            Icons.bug_report,
            AppColors.pointPink,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...preventiveMeds.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildVaccinationCard(record),
            ),
          ),
        ],

        // 추가 백신 (선택)
        if (additionalVaccines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildVaccineCategoryHeader(
            '追加ワクチン (任意)',
            Icons.add_circle_outline,
            AppColors.pointBlue,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...additionalVaccines.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildVaccinationCard(record),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVaccineCategoryHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationCard(VaccinationRecord record) {
    final iconColor = _getVaccineIconColor(record.type);

    if (!widget.isEditMode) {
      return _buildReadOnlyVaccinationCard(record, iconColor);
    }

    return _buildEditableVaccinationCard(record, iconColor);
  }

  Widget _buildReadOnlyVaccinationCard(
    VaccinationRecord record,
    Color iconColor,
  ) {
    final lastDateText = record.lastDate != null
        ? '${record.lastDate!.year}年${record.lastDate!.month}月${record.lastDate!.day}日'
        : '未設定';
    final nextDateText = record.nextDate != null
        ? '${record.nextDate!.year}年${record.nextDate!.month}月${record.nextDate!.day}日'
        : '未設定';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVaccineIcon(record.type),
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  record.type.label,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: record.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.status.label,
                  style: AppFonts.bodySmall.copyWith(
                    color: record.status.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDateDisplay('前回', lastDateText, iconColor),
          const SizedBox(height: AppSpacing.sm),
          _buildDateDisplay('次回', nextDateText, iconColor),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(String label, String dateText, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: accentColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label:',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              dateText,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableVaccinationCard(
    VaccinationRecord record,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVaccineIcon(record.type),
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  record.type.label,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
              ),
              _buildStatusDropdown(record),
              if (record.type.category == '追加ワクチン') ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
                    color: AppColors.pointRed,
                  ),
                  onPressed: () => _deleteVaccination(record),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDateField(
            '前回接種',
            record.lastDate,
            iconColor,
            () => _selectLastDate(record),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDateField(
            '次回接種',
            record.nextDate,
            iconColor,
            () => _selectNextDate(record),
          ),
        ],
      ),
    );
  }

  IconData _getVaccineIcon(VaccineType type) {
    switch (type.category) {
      case 'コアワクチン':
        return Icons.vaccines;
      case '法定接種':
        return Icons.gavel;
      case '予防薬':
        return Icons.bug_report;
      default:
        return Icons.medical_services;
    }
  }

  Color _getVaccineIconColor(VaccineType type) {
    switch (type.category) {
      case 'コアワクチン':
        return AppColors.pointGreen;
      case '法定接種':
        return AppColors.pointRed;
      case '予防薬':
        return AppColors.pointPink;
      default:
        return AppColors.pointBlue;
    }
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Color accentColor,
    VoidCallback onTap,
  ) {
    final dateText = date != null
        ? '${date.year}年${date.month}月${date.day}日'
        : '未設定';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: accentColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$label:',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                dateText,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(VaccinationRecord record) {
    return PopupMenuButton<VaccinationStatus>(
      initialValue: record.status,
      onSelected: (status) => _updateVaccinationStatus(record, status),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: record.status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: record.status.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              record.status.label,
              style: AppFonts.bodySmall.copyWith(
                color: record.status.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: record.status.color),
          ],
        ),
      ),
      itemBuilder: (context) => VaccinationStatus.values
          .map(
            (status) => PopupMenuItem(value: status, child: Text(status.label)),
          )
          .toList(),
    );
  }

  void _showAddVaccineDialog() {
    final hasCoreVaccines = VaccineType.values
        .where((type) => type.category == 'コアワクチン')
        .every((type) => _vaccinationRecords.any((r) => r.type == type));

    final availableAdditionalVaccines = VaccineType.values
        .where(
          (type) =>
              type.category == '追加ワクチン' &&
              !_vaccinationRecords.any((r) => r.type == type),
        )
        .toList();

    if (hasCoreVaccines && availableAdditionalVaccines.isEmpty) {
      SnackBarService.showInfo(context, '追加可能なワクチンがありません');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ワクチンを追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasCoreVaccines)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pointGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vaccines,
                        color: AppColors.pointGreen,
                      ),
                    ),
                    title: const Text(
                      'コアワクチン (5種混合)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('ジステンパー、パルボ、肝炎など必須ワクチン'),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _addCoreVaccines();
                    },
                  ),
                ...availableAdditionalVaccines.map(
                  (type) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: AppColors.pointBlue,
                      ),
                    ),
                    title: Text(type.label),
                    subtitle: const Text('任意接種'),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _addVaccination(type);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  void _addCoreVaccines() {
    final coreVaccineTypes = VaccineType.values
        .where((type) => type.category == 'コアワクチン')
        .toList();

    setState(() {
      for (final type in coreVaccineTypes) {
        if (!_vaccinationRecords.any((r) => r.type == type)) {
          _vaccinationRecords.add(
            VaccinationRecord(type: type, status: VaccinationStatus.notStarted),
          );
        }
      }
    });

    _saveVaccinationsToFormData();
    SnackBarService.showSuccess(context, 'コアワクチン(5種)を追加しました');
  }

  void _addVaccination(VaccineType type) {
    setState(() {
      _vaccinationRecords.add(
        VaccinationRecord(type: type, status: VaccinationStatus.notStarted),
      );
    });
    _saveVaccinationsToFormData();
    SnackBarService.showSuccess(context, '${type.label}を追加しました');
  }

  void _saveVaccinationsToFormData() {
    final vaccinationsData = _vaccinationRecords.map((r) => r.toMap()).toList();

    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('vaccinations', vaccinationsData);

    LoggerService.debug('💾 ワクチン接種記録保存: ${vaccinationsData.length}件');
  }

  void _deleteVaccination(VaccinationRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${record.type.label}の記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _vaccinationRecords.remove(record);
              });
              _saveVaccinationsToFormData();
              Navigator.pop(context);
              SnackBarService.showSuccess(context, '削除しました');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.pointRed),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _updateVaccinationStatus(
    VaccinationRecord record,
    VaccinationStatus status,
  ) {
    setState(() {
      final index = _vaccinationRecords.indexOf(record);
      _vaccinationRecords[index] = record.copyWith(status: status);
    });
    _saveVaccinationsToFormData();
  }

  Future<void> _selectLastDate(VaccinationRecord record) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: record.lastDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ja', 'JP'),
    );

    if (picked != null) {
      setState(() {
        final index = _vaccinationRecords.indexOf(record);
        _vaccinationRecords[index] = record.copyWith(lastDate: picked);
      });
      _saveVaccinationsToFormData();
    }
  }

  Future<void> _selectNextDate(VaccinationRecord record) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          record.nextDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('ja', 'JP'),
    );

    if (picked != null) {
      setState(() {
        final index = _vaccinationRecords.indexOf(record);
        _vaccinationRecords[index] = record.copyWith(nextDate: picked);
      });
      _saveVaccinationsToFormData();
    }
  }
}
