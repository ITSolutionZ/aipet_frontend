import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetHealthTab extends ConsumerWidget {
  final PetProfileEntity pet;

  const PetHealthTab({super.key, required this.pet});

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
}
