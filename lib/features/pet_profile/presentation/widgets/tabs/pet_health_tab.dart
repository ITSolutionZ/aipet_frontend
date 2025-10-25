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
  // 백신 접종 기록 (실제로는 데이터베이스에서 로드)
  late List<VaccinationRecord> _vaccinationRecords;
  
  @override
  void initState() {
    super.initState();
    _initializeVaccinationRecords();
  }

  void _initializeVaccinationRecords() {
    // TODO: 실제 데이터는 pet.additionalInfo나 별도 DB에서 로드
    _vaccinationRecords = [
      // 코어백신 5종 (기본)
      VaccinationRecord(
        type: VaccineType.distemper,
        lastDate: DateTime(2024, 3, 15),
        nextDate: DateTime(2025, 3, 15),
        status: VaccinationStatus.completed,
      ),
      VaccinationRecord(
        type: VaccineType.parvovirus,
        lastDate: DateTime(2024, 3, 15),
        nextDate: DateTime(2025, 3, 15),
        status: VaccinationStatus.completed,
      ),
      VaccinationRecord(
        type: VaccineType.hepatitis,
        lastDate: DateTime(2024, 3, 15),
        nextDate: DateTime(2025, 3, 15),
        status: VaccinationStatus.completed,
      ),
      VaccinationRecord(
        type: VaccineType.adenovirus,
        lastDate: DateTime(2024, 3, 15),
        nextDate: DateTime(2025, 3, 15),
        status: VaccinationStatus.completed,
      ),
      VaccinationRecord(
        type: VaccineType.parainfluenza,
        lastDate: DateTime(2024, 3, 15),
        nextDate: DateTime(2025, 3, 15),
        status: VaccinationStatus.completed,
      ),
      
      // 법정 접종
      VaccinationRecord(
        type: VaccineType.rabies,
        lastDate: DateTime(2024, 4, 10),
        nextDate: DateTime(2025, 4, 10),
        status: VaccinationStatus.completed,
      ),
      
      // 기생충 예방
      VaccinationRecord(
        type: VaccineType.heartworm,
        lastDate: DateTime(2024, 8, 1),
        nextDate: DateTime(2024, 9, 1),
        status: VaccinationStatus.inProgress,
      ),
    ];
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
        
        // 코어백신 5종 (필수)
        if (coreVaccines.isNotEmpty) ...[
          _buildVaccineCategoryHeader('コアワクチン (5種)', Icons.shield, AppColors.pointGreen),
          const SizedBox(height: AppSpacing.sm),
          ...coreVaccines.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildVaccinationCard(record),
              )),
        ],
        
        // 법정 접종
        if (mandatoryVaccines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildVaccineCategoryHeader('法定接種 (必須)', Icons.gavel, AppColors.pointRed),
          const SizedBox(height: AppSpacing.sm),
          ...mandatoryVaccines.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildVaccinationCard(record),
              )),
        ],
        
        // 기생충 예방
        if (preventiveMeds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildVaccineCategoryHeader('寄生虫予防', Icons.bug_report, AppColors.pointPink),
          const SizedBox(height: AppSpacing.sm),
          ...preventiveMeds.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildVaccinationCard(record),
              )),
        ],
        
        // 추가 백신 (선택)
        if (additionalVaccines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildVaccineCategoryHeader('追加ワクチン (任意)', Icons.add_circle_outline, AppColors.pointBlue),
          const SizedBox(height: AppSpacing.sm),
          ...additionalVaccines.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildVaccinationCard(record),
              )),
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
      return GenericInfoCard.withIcon(
        icon: _getVaccineIcon(record.type),
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: record.type.label,
        subtitle: _formatVaccineDates(record),
        badge: record.status.label,
        badgeColor: record.status.color,
      );
    }

    // 편집 모드
    return _buildEditableVaccinationCard(record, iconColor);
  }

  Widget _buildEditableVaccinationCard(VaccinationRecord record, Color iconColor) {
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
                child: Icon(_getVaccineIcon(record.type), color: iconColor, size: 20),
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
                  icon: const Icon(Icons.delete, size: 20, color: AppColors.pointRed),
                  onPressed: () => _deleteVaccination(record),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 날짜 필드
          _buildDateField('前回接種', record.lastDate, iconColor, () => _selectLastDate(record)),
          const SizedBox(height: AppSpacing.sm),
          _buildDateField('次回接種', record.nextDate, iconColor, () => _selectNextDate(record)),
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

  String _formatVaccineDates(VaccinationRecord record) {
    final lastDate = record.lastDate != null
        ? '${record.lastDate!.year}年${record.lastDate!.month}月${record.lastDate!.day}日'
        : '未設定';
    final nextDate = record.nextDate != null
        ? '${record.nextDate!.year}年${record.nextDate!.month}月${record.nextDate!.day}日'
        : '未設定';
    return '前回: $lastDate\n次回: $nextDate';
  }

  Widget _buildDateField(String label, DateTime? date, Color accentColor, VoidCallback onTap) {
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
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
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
          .map((status) => PopupMenuItem(
                value: status,
                child: Text(status.label),
              ))
          .toList(),
    );
  }

  void _showAddVaccineDialog() {
    // 아직 추가되지 않은 백신 목록
    final availableVaccines = VaccineType.values
        .where((type) =>
            type.category == '追加ワクチン' &&
            !_vaccinationRecords.any((r) => r.type == type))
        .toList();

    if (availableVaccines.isEmpty) {
      SnackBarService.showInfo(context, '追加可能なワクチンがありません');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ワクチンを追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableVaccines
              .map((type) => ListTile(
                    title: Text(type.label),
                    onTap: () {
                      Navigator.pop(context);
                      _addVaccination(type);
                    },
                  ))
              .toList(),
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

  void _addVaccination(VaccineType type) {
    setState(() {
      _vaccinationRecords.add(
        VaccinationRecord(
          type: type,
          status: VaccinationStatus.notStarted,
        ),
      );
    });
    SnackBarService.showSuccess(context, '${type.label}を追加しました');
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

  void _updateVaccinationStatus(VaccinationRecord record, VaccinationStatus status) {
    setState(() {
      final index = _vaccinationRecords.indexOf(record);
      _vaccinationRecords[index] = record.copyWith(status: status);
    });
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
    }
  }

  Future<void> _selectNextDate(VaccinationRecord record) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: record.nextDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('ja', 'JP'),
    );

    if (picked != null) {
      setState(() {
        final index = _vaccinationRecords.indexOf(record);
        _vaccinationRecords[index] = record.copyWith(nextDate: picked);
      });
    }
  }

  Widget _buildMedicalRecordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '診療記録',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.local_hospital,
          iconColor: AppColors.pointPink,
          iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
          title: '定期健康診断',
          subtitle: '2024年7月20日 • 田中動物病院',
          badge: '正常',
          badgeColor: AppColors.pointGreen,
        ),
        const SizedBox(height: AppSpacing.sm),
        GenericInfoCard.withIcon(
          icon: Icons.cleaning_services,
          iconColor: AppColors.pointBlue,
          iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
          title: 'デンタルケア',
          subtitle: '2024年6月5日 • 田中動物病院',
          badge: '完了',
          badgeColor: AppColors.pointGreen,
        ),
      ],
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
          subtitle: '${widget.pet.weight}kg • 理想体重: ${widget.pet.weight + 0.5}kg',
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
        Text(
          '予約・スケジュール',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.schedule,
          iconColor: AppColors.pointBlue,
          iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
          title: '次回健康診断',
          subtitle: '2025年1月20日 10:00 • 田中動物病院',
          badge: '予約済み',
          badgeColor: AppColors.pointBlue,
        ),
      ],
    );
  }
}
