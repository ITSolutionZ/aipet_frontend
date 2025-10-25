import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_unified_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 일본 개 백신 종류 정의
enum VaccineType {
  // 코어백신 (5종 - 필수)
  distemper('ジステンパー', 'コアワクチン'),
  parvovirus('パルボウイルス', 'コアワクチン'),
  hepatitis('伝染性肝炎', 'コアワクチン'),
  adenovirus('アデノウイルス2型', 'コアワクチン'),
  parainfluenza('パラインフルエンザ', 'コアワクチン'),

  // 추가 백신 (6-10종 - 선택)
  coronavirus('コロナウイルス', '追加ワクチン'),
  leptospira('レプトスピラ', '追加ワクチン'),
  lyme('ライム病', '追加ワクチン'),
  bordetella('ケンネルコフ', '追加ワクチン'),

  // 법적 의무
  rabies('狂犬病', '法定接種'),

  // 기생충 예방
  heartworm('フィラリア予防', '予防薬');

  const VaccineType(this.label, this.category);
  final String label;
  final String category;
}

/// 백신 접종 상태
enum VaccinationStatus {
  completed('完了', AppColors.pointGreen),
  inProgress('接種中', AppColors.pointBlue),
  overdue('期限切れ', AppColors.pointPink),
  notStarted('未接種', AppColors.pointGray);

  const VaccinationStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// 백신 접종 기록 데이터 모델
class VaccinationRecord {
  final VaccineType type;
  final DateTime? lastDate;
  final DateTime? nextDate;
  final VaccinationStatus status;
  final String? memo;

  VaccinationRecord({
    required this.type,
    this.lastDate,
    this.nextDate,
    required this.status,
    this.memo,
  });

  VaccinationRecord copyWith({
    VaccineType? type,
    DateTime? lastDate,
    DateTime? nextDate,
    VaccinationStatus? status,
    String? memo,
  }) {
    return VaccinationRecord(
      type: type ?? this.type,
      lastDate: lastDate ?? this.lastDate,
      nextDate: nextDate ?? this.nextDate,
      status: status ?? this.status,
      memo: memo ?? this.memo,
    );
  }
}

class PetHealthTab extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetHealthTab({super.key, required this.pet, this.isEditMode = false});

  @override
  ConsumerState<PetHealthTab> createState() => _PetHealthTabState();
}

class _PetHealthTabState extends ConsumerState<PetHealthTab> {
  // 백신 접종 기록
  late List<VaccinationRecord> _vaccinationRecords;
  // 진료 기록
  late List<Map<String, dynamic>> _medicalRecords;
  // 예약 스케줄
  late List<Map<String, dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  @override
  void didUpdateWidget(PetHealthTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // pet이 변경되거나 편집 모드가 종료되면 데이터 갱신
    if (oldWidget.pet.id != widget.pet.id ||
        (oldWidget.isEditMode && !widget.isEditMode)) {
      LoggerService.debug('🔄 건강 탭 데이터 갱신');
      _loadHealthData();
    }
  }

  void _loadHealthData() {
    final additionalInfo = widget.pet.additionalInfo ?? {};

    // 백신 접종 기록 로드
    final vaccinationsData = additionalInfo['vaccinations'] as List<dynamic>?;
    if (vaccinationsData != null && vaccinationsData.isNotEmpty) {
      _vaccinationRecords = vaccinationsData.map((v) {
        return VaccinationRecord(
          type: VaccineType.values.firstWhere(
            (t) => t.label == v['type'],
            orElse: () => VaccineType.distemper,
          ),
          lastDate: v['lastDate'] != null
              ? DateTime.parse(v['lastDate'])
              : null,
          nextDate: v['nextDate'] != null
              ? DateTime.parse(v['nextDate'])
              : null,
          status: VaccinationStatus.values.firstWhere(
            (s) => s.label == v['status'],
            orElse: () => VaccinationStatus.notStarted,
          ),
          memo: v['memo'],
        );
      }).toList();
      LoggerService.debug('✅ 백신 접종 기록 ${_vaccinationRecords.length}건 로드');
    } else {
      // 데이터가 없으면 빈 리스트
      _vaccinationRecords = [];
      LoggerService.debug('ℹ️  백신 접종 기록 없음');
    }

    // 진료 기록 로드
    _medicalRecords =
        (additionalInfo['medicalRecords'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    LoggerService.debug('✅ 진료 기록 ${_medicalRecords.length}건 로드');

    // 예약 로드
    _appointments =
        (additionalInfo['appointments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    LoggerService.debug('✅ 예약 ${_appointments.length}건 로드');
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildVaccinationSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildMedicalRecordsSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildWeightTrackingSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildAppointmentsSection(),
        ],
      ),
    );
  }

  Widget _buildVaccinationSection() {
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
      // 보기 모드
      return _buildReadOnlyVaccinationCard(record, iconColor);
    }

    // 편집 모드
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
          // 헤더 행
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
          // 날짜 표시 (세로 배치)
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
          // 헤더 행
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
          // 날짜 필드 (세로 배치)
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
    // コアワクチン5種が全て追加されているかチェック
    final hasCoreVaccines = VaccineType.values
        .where((type) => type.category == 'コアワクチン')
        .every((type) => _vaccinationRecords.any((r) => r.type == type));

    // 아직 추가되지 않은 추加ワクチン 목록
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

    final List<Widget> menuItems = [];

    // コアワクチン5種をまとめて追加するオプション（まだ追加されていない場合のみ）
    if (!hasCoreVaccines) {
      menuItems.add(
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pointGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.vaccines, color: AppColors.pointGreen),
          ),
          title: const Text(
            'コアワクチン (5種混合)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('ジステンパー、パルボ、肝炎など必須ワクチン'),
          onTap: () {
            Navigator.pop(context);
            _addCoreVaccines();
          },
        ),
      );
    }

    // 追加ワクチンのオプション
    menuItems.addAll(
      availableAdditionalVaccines.map(
        (type) => ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pointBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medical_services, color: AppColors.pointBlue),
          ),
          title: Text(type.label),
          subtitle: const Text('任意接種'),
          onTap: () {
            Navigator.pop(context);
            _addVaccination(type);
          },
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ワクチンを追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menuItems,
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

  void _addCoreVaccines() {
    // コアワクチン5種を一括追加
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
    final vaccinationsData = _vaccinationRecords.map((record) {
      return {
        'type': record.type.label,
        'lastDate': record.lastDate?.toIso8601String(),
        'nextDate': record.nextDate?.toIso8601String(),
        'status': record.status.label,
        'memo': record.memo,
      };
    }).toList();

    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('vaccinations', vaccinationsData);

    LoggerService.debug('💾 백신 접종 기록 저장: ${vaccinationsData.length}건');
  }

  void _saveMedicalRecordsToFormData() {
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('medicalRecords', _medicalRecords);

    LoggerService.debug('💾 진료 기록 저장: ${_medicalRecords.length}건');
  }

  void _saveAppointmentsToFormData() {
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('appointments', _appointments);

    LoggerService.debug('💾 예약 저장: ${_appointments.length}건');
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

  Widget _buildMedicalRecordsSection() {
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

  Widget _buildWeightTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '体重管理',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.monitor_weight,
          iconColor: AppColors.pointBrown,
          iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
          title: '現在の体重',
          subtitle:
              '${widget.pet.weight}kg • 理想体重: ${widget.pet.weight + 0.5}kg',
          badge: '適正',
          badgeColor: AppColors.pointGreen,
        ),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '予約・スケジュール',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            if (widget.isEditMode)
              TextButton.icon(
                onPressed: _showAddAppointmentDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_appointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '予約がありません',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
            ),
          )
        else
          ..._appointments.map((appointment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GenericInfoCard.withIcon(
                icon: Icons.schedule,
                iconColor: AppColors.pointBlue,
                iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
                title: appointment['title'] ?? '',
                subtitle:
                    '${_formatDateTime(appointment['date'], appointment['time'])} • ${appointment['hospital'] ?? ''}',
                badge: '予約済み',
                badgeColor: AppColors.pointBlue,
              ),
            );
          }),
      ],
    );
  }

  String _formatDateTime(dynamic date, dynamic time) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      final dateStr = '${dateTime.year}年${dateTime.month}月${dateTime.day}日';

      if (time != null) {
        return '$dateStr $time';
      }
      return dateStr;
    } catch (e) {
      return '';
    }
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    final hospitalController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('予約を追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '予約内容',
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
                  title: const Text('予約日'),
                  subtitle: Text(
                    '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
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
                ListTile(
                  title: const Text('予約時刻'),
                  subtitle: Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
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
                  SnackBarService.showWarning(context, '予約内容と病院名を入力してください');
                  return;
                }

                final timeStr =
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                setState(() {
                  _appointments.add({
                    'title': titleController.text,
                    'hospital': hospitalController.text,
                    'date': selectedDate.toIso8601String(),
                    'time': timeStr,
                  });
                });

                _saveAppointmentsToFormData();

                Navigator.pop(context);
                SnackBarService.showSuccess(context, '予約を追加しました');
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
