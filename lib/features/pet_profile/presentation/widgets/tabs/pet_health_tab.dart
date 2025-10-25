import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'health/controllers/pet_health_controller.dart';
import 'health/controllers/pet_health_state.dart';
import 'health/dialogs/appointment_edit_dialog.dart';
import 'health/dialogs/medical_record_edit_dialog.dart';
import 'health/dialogs/vaccination_edit_dialog.dart';

class PetHealthTab extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final VoidCallback? onToggleEdit;

  const PetHealthTab({
    super.key,
    required this.pet,
    this.isEditMode = false,
    this.onToggleEdit,
  });

  @override
  ConsumerState<PetHealthTab> createState() => _PetHealthTabState();
}

class _PetHealthTabState extends ConsumerState<PetHealthTab> {
  late final String tabId;

  @override
  void initState() {
    super.initState();
    tabId = DateTime.now().millisecondsSinceEpoch.toString();

    // Controller 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petHealthControllerProvider(tabId).notifier).initialize(widget.pet);
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(petHealthControllerProvider(tabId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildVaccinationSection(healthState),
          const SizedBox(height: AppSpacing.lg),
          _buildMedicalRecordsSection(healthState),
          const SizedBox(height: AppSpacing.lg),
          _buildWeightTrackingSection(healthState),
          const SizedBox(height: AppSpacing.lg),
          _buildAppointmentsSection(healthState),

          // 편집 모드일 때 저장/취소 버튼 표시
          if (widget.isEditMode && widget.onToggleEdit != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }

  /// 저장/취소 버튼
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onToggleEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.pointBrown),
            ),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: AppColors.pointBrown),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleSave(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text('保存'),
          ),
        ),
      ],
    );
  }

  /// 저장 처리
  void _handleSave(BuildContext context) {
    // TODO: PetProfileUnifiedController와 연동하여 실제 저장
    final controller = ref.read(petHealthControllerProvider(tabId).notifier);
    final changes = controller.getChanges();

    LoggerService.debug('💾 健康タブ: 保存ボタン押下');
    LoggerService.debug('💾 変更内容: $changes');

    SnackBarService.showSaved(context, itemName: '健康情報');

    // 편집 모드 종료
    if (widget.onToggleEdit != null) {
      LoggerService.debug('🔄 健康タブ: 編集モード終了');
      widget.onToggleEdit!();
    }
  }

  /// 예방접종 기록 추가
  void _addVaccinationRecord() {
    showDialog(
      context: context,
      builder: (context) => VaccinationEditDialog(
        onSave: (record) {
          final controller = ref.read(petHealthControllerProvider(tabId).notifier);
          controller.addVaccinationRecord(record);
          LoggerService.debug('✅ 予防接種記録追加: ${record.name}');
        },
      ),
    );
  }

  /// 예방접종 카드 빌드
  Widget _buildVaccinationCard(VaccinationRecord record) {
    final iconData = _getIconData(record.iconName);
    final iconColor = _getColor(record.colorName);
    final statusColor = _getStatusColor(record.status);

    final dateFormat = DateFormat('yyyy年M月d日');
    final lastDateStr = record.lastDate != null ? dateFormat.format(record.lastDate!) : '-';
    final nextDateStr = record.nextDate != null ? dateFormat.format(record.nextDate!) : '-';

    if (!widget.isEditMode) {
      return GenericInfoCard.withIcon(
        icon: iconData,
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: record.name,
        subtitle: '前回: $lastDateStr\n次回: $nextDateStr',
        badge: record.status,
        badgeColor: statusColor,
      );
    }

    // 편집 모드: 클릭 가능한 카드 (길게 누르면 삭제)
    return GestureDetector(
      onTap: () => _editVaccinationRecord(record),
      onLongPress: () => _deleteVaccinationRecord(record),
      child: Container(
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
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    record.name,
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status,
                    style: AppFonts.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.edit, size: 16, color: AppColors.pointGray),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '前回: $lastDateStr',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
            Text(
              '次回: $nextDateStr',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
      ),
    );
  }

  /// 예방접종 기록 편집
  void _editVaccinationRecord(VaccinationRecord record) {
    showDialog(
      context: context,
      builder: (context) => VaccinationEditDialog(
        record: record,
        onSave: (updatedRecord) {
          final controller = ref.read(petHealthControllerProvider(tabId).notifier);
          controller.updateVaccinationRecord(record.id, updatedRecord);
          LoggerService.debug('✅ 予防接種記録更新: ${updatedRecord.name}');
        },
      ),
    );
  }

  /// 예방접종 기록 삭제
  void _deleteVaccinationRecord(VaccinationRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${record.name}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final controller = ref.read(petHealthControllerProvider(tabId).notifier);
              controller.deleteVaccinationRecord(record.id);
              Navigator.pop(context);
              LoggerService.debug('✅ 予防接種記録削除: ${record.name}');
              SnackBarService.showSuccess(context, '削除しました');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// 아이콘 이름을 IconData로 변환
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'vaccines':
        return Icons.vaccines;
      case 'healing':
        return Icons.healing;
      case 'bug_report':
        return Icons.bug_report;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'medication':
        return Icons.medication;
      case 'emergency':
        return Icons.emergency;
      case 'schedule':
        return Icons.schedule;
      case 'content_cut':
        return Icons.content_cut;
      case 'monitor_weight':
        return Icons.monitor_weight;
      default:
        return Icons.health_and_safety;
    }
  }

  /// 색상 이름을 Color로 변환
  Color _getColor(String colorName) {
    switch (colorName) {
      case 'green':
        return AppColors.pointGreen;
      case 'blue':
        return AppColors.pointBlue;
      case 'pink':
        return AppColors.pointPink;
      case 'brown':
        return AppColors.pointBrown;
      default:
        return AppColors.pointGray;
    }
  }

  /// 상태에 따른 색상 반환
  Color _getStatusColor(String status) {
    if (status == '期限切れ') {
      return AppColors.pointPink;
    } else if (status == '接種中') {
      return AppColors.pointBlue;
    }
    return AppColors.pointGreen;
  }

  Widget _buildVaccinationSection(PetHealthState healthState) {
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
                onPressed: () => _addVaccinationRecord(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...healthState.vaccinationRecords.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildVaccinationCard(record),
          );
        }),
      ],
    );
  }

  Widget _buildMedicalRecordsSection(PetHealthState healthState) {
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
                onPressed: () => _addMedicalRecord(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...healthState.medicalRecords.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildMedicalRecordCard(record),
          );
        }),
      ],
    );
  }

  /// 진료 기록 추가
  void _addMedicalRecord() {
    showDialog(
      context: context,
      builder: (context) => MedicalRecordEditDialog(
        onSave: (record) {
          final controller = ref.read(petHealthControllerProvider(tabId).notifier);
          controller.addMedicalRecord(record);
          LoggerService.debug('✅ 診療記録追加: ${record.title}');
        },
      ),
    );
  }

  /// 진료 기록 카드 빌드
  Widget _buildMedicalRecordCard(MedicalRecord record) {
    final iconData = _getIconData(record.iconName);
    final iconColor = _getColor(record.colorName);
    final statusColor = _getColor(record.colorName);

    final dateFormat = DateFormat('yyyy年M月d日');
    final dateStr = dateFormat.format(record.date);

    if (!widget.isEditMode) {
      return GenericInfoCard.withIcon(
        icon: iconData,
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: record.title,
        subtitle: '$dateStr • ${record.hospital}',
        badge: record.status,
        badgeColor: statusColor,
      );
    }

    // 편집 모드: 클릭 가능한 카드
    return GestureDetector(
      onTap: () => _editMedicalRecord(record),
      onLongPress: () => _deleteMedicalRecord(record),
      child: GenericInfoCard.withIcon(
        icon: iconData,
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: record.title,
        subtitle: '$dateStr • ${record.hospital}',
        badge: record.status,
        badgeColor: statusColor,
        trailing: const Icon(Icons.edit, size: 16, color: AppColors.pointGray),
      ),
    );
  }

  /// 진료 기록 편집
  void _editMedicalRecord(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => MedicalRecordEditDialog(
        record: record,
        onSave: (updatedRecord) {
          final controller = ref.read(petHealthControllerProvider(tabId).notifier);
          controller.updateMedicalRecord(record.id, updatedRecord);
          LoggerService.debug('✅ 診療記録更新: ${updatedRecord.title}');
        },
      ),
    );
  }

  /// 진료 기록 삭제
  void _deleteMedicalRecord(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${record.title}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final controller = ref.read(petHealthControllerProvider(tabId).notifier);
              controller.deleteMedicalRecord(record.id);
              Navigator.pop(context);
              LoggerService.debug('✅ 診療記録削除: ${record.title}');
              SnackBarService.showSuccess(context, '削除しました');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrackingSection(PetHealthState healthState) {
    final currentWeight = healthState.currentWeight ?? widget.pet.weight;
    final idealWeight = healthState.idealWeight ?? widget.pet.weight + 0.5;

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
          subtitle: '${currentWeight}kg • 理想体重: ${idealWeight}kg',
          badge: '適正',
          badgeColor: AppColors.pointGreen,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '体重推移チャート\n（実装予定）',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.pointGray),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsSection(PetHealthState healthState) {
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
                onPressed: () => _addAppointment(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...healthState.appointments.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildAppointmentCard(record),
          );
        }),
      ],
    );
  }

  /// 예약 추가
  void _addAppointment() {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditDialog(
        onSave: (record) {
          final controller = ref.read(petHealthControllerProvider(tabId).notifier);
          controller.addAppointment(record);
          LoggerService.debug('✅ 予約追加: ${record.title}');
        },
      ),
    );
  }

  /// 예약 카드 빌드
  Widget _buildAppointmentCard(AppointmentRecord record) {
    final iconData = _getIconData(record.iconName);
    final iconColor = _getColor(record.colorName);
    final statusColor = _getColor(record.colorName);

    final dateFormat = DateFormat('yyyy年M月d日 HH:mm');
    final dateTimeStr = dateFormat.format(record.dateTime);

    if (!widget.isEditMode) {
      return GenericInfoCard.withIcon(
        icon: iconData,
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: record.title,
        subtitle: '$dateTimeStr • ${record.location}',
        badge: record.status,
        badgeColor: statusColor,
      );
    }

    // 편집 모드: 클릭 가능한 카드
    return GestureDetector(
      onTap: () => _editAppointment(record),
      onLongPress: () => _deleteAppointment(record),
      child: GenericInfoCard.withIcon(
        icon: iconData,
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: record.title,
        subtitle: '$dateTimeStr • ${record.location}',
        badge: record.status,
        badgeColor: statusColor,
        trailing: const Icon(Icons.edit, size: 16, color: AppColors.pointGray),
      ),
    );
  }

  /// 예약 편집
  void _editAppointment(AppointmentRecord record) {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditDialog(
        record: record,
        onSave: (updatedRecord) {
          final controller = ref.read(petHealthControllerProvider(tabId).notifier);
          controller.updateAppointment(record.id, updatedRecord);
          LoggerService.debug('✅ 予約更新: ${updatedRecord.title}');
        },
      ),
    );
  }

  /// 예약 삭제
  void _deleteAppointment(AppointmentRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${record.title}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final controller = ref.read(petHealthControllerProvider(tabId).notifier);
              controller.deleteAppointment(record.id);
              Navigator.pop(context);
              LoggerService.debug('✅ 予約削除: ${record.title}');
              SnackBarService.showSuccess(context, '削除しました');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
