import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetHealthTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetHealthTab({
    super.key,
    required this.pet,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '予防接種記録',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildHealthCard(
          icon: Icons.vaccines,
          title: 'コアワクチン',
          iconColor: AppColors.pointGreen,
          status: '完了',
          lastDate: '2024年3月15日',
          nextDate: '2025年3月15日',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildHealthCard(
          icon: Icons.healing,
          title: '狂犬病予防接種',
          iconColor: AppColors.pointBlue,
          status: '完了',
          lastDate: '2024年4月10日',
          nextDate: '2025年4月10日',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildHealthCard(
          icon: Icons.bug_report,
          title: 'フィラリア予防',
          iconColor: AppColors.pointPink,
          status: '接種中',
          lastDate: '2024年8月1日',
          nextDate: '2024年9月1日',
        ),
      ],
    );
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
          subtitle: '${pet.weight}kg • 理想体重: ${pet.weight + 0.5}kg',
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
        const SizedBox(height: AppSpacing.sm),
        GenericInfoCard.withIcon(
          icon: Icons.content_cut,
          iconColor: AppColors.pointPink,
          iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
          title: 'グルーミング',
          subtitle: '2024年9月25日 14:00 • ペットサロン花',
          badge: '予約済み',
          badgeColor: AppColors.pointPink,
        ),
      ],
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required String status,
    required String lastDate,
    required String nextDate,
  }) {
    Color statusColor = AppColors.pointGreen;
    if (status == '期限切れ') {
      statusColor = AppColors.pointPink;
    } else if (status == '接種中') {
      statusColor = AppColors.pointBlue;
    }

    if (!isEditMode) {
      return GenericInfoCard.withIcon(
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconColor.withValues(alpha: 0.1),
        title: title,
        subtitle: '前回: $lastDate\n次回: $nextDate',
        badge: status,
        badgeColor: statusColor,
      );
    }

    // 편집 모드: 인라인 편집 가능
    return _buildEditableHealthCard(
      icon: icon,
      title: title,
      iconColor: iconColor,
      status: status,
      statusColor: statusColor,
      lastDate: lastDate,
      nextDate: nextDate,
    );
  }

  Widget _buildEditableHealthCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required String status,
    required Color statusColor,
    required String lastDate,
    required String nextDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 행 (아이콘 + 제목 + 상태)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
              ),
              // 상태 드롭다운
              _buildStatusDropdown(status, statusColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 전회 날짜
          _buildDateField('前回', lastDate, iconColor),
          const SizedBox(height: AppSpacing.sm),
          // 다음 날짜
          _buildDateField('次回', nextDate, iconColor),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, String dateText, Color accentColor) {
    return InkWell(
      onTap: () => _selectDate(dateText),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: accentColor,
            ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(String currentStatus, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentStatus,
            style: AppFonts.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: statusColor,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(String currentDateText) async {
    // TODO: DatePicker 구현
    LoggerService.debug('날짜 선택 다이얼로그 표시: $currentDateText');
  }
}
