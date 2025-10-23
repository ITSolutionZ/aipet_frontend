import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫입양 탭 위젯
class PetAdoptionTab extends StatelessWidget {
  final PetProfileEntity pet;

  const PetAdoptionTab({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: AppSpacing.xl),
          _buildAdoptionStatusCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildAdoptionInfoCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildAdoptionActionsCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildAdoptionHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pointBrown.withValues(alpha: 0.1),
            AppColors.pointGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.family_restroom,
              color: AppColors.pointBrown,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '家族探し',
                  style: AppFonts.titleLarge.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${pet.name}の新しい家族を探しましょう',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          color: AppColors.pureWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.pointBlue,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '現在の状況',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.pointGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: AppColors.pointGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.pointGreen,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '現在、家族探しをしていません',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ペットの新しい家族を探したい場合は、下のボタンから家族探しを開始できます。',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptionInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          color: AppColors.pureWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pets, color: AppColors.pointBrown, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'ペット情報',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow('名前', pet.name),
            _buildInfoRow('種類', pet.typeName),
            _buildInfoRow('品種', pet.breed ?? '不明'),
            _buildInfoRow('性別', pet.gender),
            _buildInfoRow('年齢', '${pet.age}歳'),
            _buildInfoRow('体重', '${pet.weight}kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
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

  Widget _buildAdoptionActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          color: AppColors.pureWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: AppColors.pointBlue,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '家族探し設定',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildActionButton(
              icon: Icons.family_restroom,
              title: '家族探しを開始',
              subtitle: '新しい家族を探し始めます',
              color: AppColors.pointGreen,
              onTap: () {
                // TODO: 家族探し 시작 로직
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildActionButton(
              icon: Icons.edit,
              title: 'プロフィールを編集',
              subtitle: '家族探し用の情報を更新',
              color: AppColors.pointBlue,
              onTap: () {
                // TODO: プロフィール 편집 로직
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildActionButton(
              icon: Icons.share,
              title: 'プロフィールを共有',
              subtitle: 'SNSやメッセージで共有',
              color: AppColors.pointBrown,
              onTap: () {
                // TODO: プロフィール 공유 로직
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptionHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          color: AppColors.pureWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppColors.pointGray, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '家族探し履歴',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: 48,
                    color: AppColors.pointGray.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'まだ家族探しをしていません',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '家族探しを開始すると、ここに履歴が表示されます',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
