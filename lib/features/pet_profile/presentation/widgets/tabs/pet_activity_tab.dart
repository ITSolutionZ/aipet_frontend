import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetActivityTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetActivityTab({super.key, required this.pet, this.isEditMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data for tricks since allTricksProvider is not available
    const tricksState = AsyncValue.data(<dynamic>[]);

    return tricksState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
      data: (tricks) => _buildActivityContent(tricks),
    );
  }

  Widget _buildActivityContent(List<dynamic> tricks) {
    final learnedTricks = tricks
        .where((trick) => trick.progress != null)
        .toList();
    final availableTricks = tricks
        .where((trick) => trick.progress == null)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildActivityStatsSection(learnedTricks.length, tricks.length),
          const SizedBox(height: AppSpacing.lg),
          _buildLearnedTricksSection(learnedTricks),
          const SizedBox(height: AppSpacing.lg),
          _buildAvailableTricksSection(availableTricks),
          const SizedBox(height: AppSpacing.lg),
          _buildExerciseLogSection(),
        ],
      ),
    );
  }

  Widget _buildActivityStatsSection(int learnedCount, int totalCount) {
    final progressPercentage = totalCount > 0
        ? (learnedCount / totalCount) * 100
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '活動統計',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.psychology,
          iconColor: AppColors.pointBlue,
          iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
          title: '学習済みトリック',
          subtitle: '$learnedCount / $totalCount トリック',
          badge: '${progressPercentage.toStringAsFixed(0)}%',
          badgeColor: AppColors.pointBlue,
        ),
        const SizedBox(height: AppSpacing.sm),
        GenericInfoCard.withIcon(
          icon: Icons.directions_walk,
          iconColor: AppColors.pointGreen,
          iconBackgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
          title: '今週の散歩',
          subtitle: '5回 • 総距離: 12.5km',
          badge: '活発',
          badgeColor: AppColors.pointGreen,
        ),
      ],
    );
  }

  Widget _buildLearnedTricksSection(List<dynamic> learnedTricks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学習済みトリック',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (learnedTricks.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                'まだ学習したトリックがありません',
                style: TextStyle(color: AppColors.pointGray),
              ),
            ),
          )
        else
          ...learnedTricks.map(
            (trick) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildTrickCard(trick, isLearned: true),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailableTricksSection(List<dynamic> availableTricks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '利用可能なトリック',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...availableTricks
            .take(3)
            .map(
              (trick) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildTrickCard(trick, isLearned: false),
              ),
            ),
        if (availableTricks.length > 3)
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to all tricks screen
              },
              child: Text(
                'さらに${availableTricks.length - 3}個のトリックを見る',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointBlue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '運動記録',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.today,
          iconColor: AppColors.pointBrown,
          iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
          title: '今日の運動',
          subtitle: '朝の散歩 30分 • 公園での遊び 15分',
          badge: '完了',
          badgeColor: AppColors.pointGreen,
        ),
        const SizedBox(height: AppSpacing.sm),
        GenericInfoCard.withIcon(
          icon: Icons.timeline,
          iconColor: AppColors.pointPink,
          iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
          title: '週間目標',
          subtitle: '1日60分の運動 • 進捗: 5/7日',
          badge: '71%',
          badgeColor: AppColors.pointPink,
        ),
      ],
    );
  }

  Widget _buildTrickCard(dynamic trick, {required bool isLearned}) {
    return GenericInfoCard.withIcon(
      icon: isLearned ? Icons.check_circle : Icons.play_circle_outline,
      iconColor: isLearned ? AppColors.pointGreen : AppColors.pointGray,
      iconBackgroundColor: isLearned
          ? AppColors.pointGreen.withValues(alpha: 0.1)
          : AppColors.pointGray.withValues(alpha: 0.1),
      title: trick.name,
      subtitle: trick.description?.toString() ?? '説明なし',
      badge: isLearned ? '習得済み' : (trick.difficulty?.toString() ?? 'easy'),
      badgeColor: isLearned
          ? AppColors.pointGreen
          : _getDifficultyColor(trick.difficulty?.toString() ?? 'easy'),
      onTap: () {
        // Navigate to trick detail or start learning
      },
      showChevron: true,
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case '簡単':
      case 'easy':
        return AppColors.pointGreen;
      case '普通':
      case 'medium':
        return AppColors.pointBlue;
      case '難しい':
      case 'hard':
        return AppColors.pointPink;
      default:
        return AppColors.pointGray;
    }
  }
}
