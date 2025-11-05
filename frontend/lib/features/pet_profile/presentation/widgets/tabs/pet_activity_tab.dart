import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/walk/data/providers/walk_providers.dart';
import '../../../../../../features/walk/domain/entities/walk_record_entity.dart';

class PetActivityTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetActivityTab({super.key, required this.pet, this.isEditMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkRecords = ref.watch(walkRecordsProvider);

    return _buildActivityContent(context, ref, walkRecords);
  }

  Widget _buildActivityContent(
    BuildContext context,
    WidgetRef ref,
    List<WalkRecordEntity> walkRecords,
  ) {
    // 펫별 산책 기록 필터링
    final petWalkRecords = walkRecords
        .where((record) => record.petId == pet.id)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    // 이번 주 산책 기록
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekWalks = petWalkRecords.where((record) {
      return record.startTime.isAfter(weekStart);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildWalkStatsSection(thisWeekWalks),
          const SizedBox(height: AppSpacing.lg),
          _buildRecentWalksSection(context, petWalkRecords),
          const SizedBox(height: AppSpacing.lg),
          _buildWeeklyGoalSection(thisWeekWalks),
        ],
      ),
    );
  }

  /// 이번 주 산책 통계 섹션
  Widget _buildWalkStatsSection(List<WalkRecordEntity> thisWeekWalks) {
    // 이번 주 통계 계산
    final totalWalks = thisWeekWalks.length;
    final totalDistance = thisWeekWalks.fold<double>(
      0.0,
      (sum, walk) => sum + (walk.distance ?? 0),
    );
    final totalDuration = thisWeekWalks.fold<Duration>(
      Duration.zero,
      (sum, walk) => sum + (walk.duration ?? Duration.zero),
    );

    // 활동 레벨 판단
    String activityLevel = '低活動';
    Color activityColor = AppColors.pointGray;
    if (totalWalks >= 5) {
      activityLevel = '活発';
      activityColor = AppColors.pointGreen;
    } else if (totalWalks >= 3) {
      activityLevel = '適度';
      activityColor = AppColors.pointBlue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '散歩統計',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.directions_walk,
          iconColor: AppColors.pointBlue,
          iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
          title: '今週の散歩',
          subtitle: '$totalWalks回 • 総距離: ${totalDistance.toStringAsFixed(1)}km',
          badge: activityLevel,
          badgeColor: activityColor,
        ),
        const SizedBox(height: AppSpacing.sm),
        GenericInfoCard.withIcon(
          icon: Icons.timer,
          iconColor: AppColors.pointGreen,
          iconBackgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
          title: '総運動時間',
          subtitle: '${totalDuration.inHours}時間${totalDuration.inMinutes % 60}分',
          badge: '${(totalDuration.inMinutes / 7).toStringAsFixed(0)}分/日',
          badgeColor: AppColors.pointGreen,
        ),
      ],
    );
  }

  /// 최근 산책 기록 섹션
  Widget _buildRecentWalksSection(
    BuildContext context,
    List<WalkRecordEntity> walkRecords,
  ) {
    final recentWalks = walkRecords.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近の散歩',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (recentWalks.isEmpty)
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
                'まだ散歩記録がありません',
                style: TextStyle(color: AppColors.pointGray),
              ),
            ),
          )
        else
          ...recentWalks.map(
            (walk) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildWalkCard(context, walk),
            ),
          ),
      ],
    );
  }

  /// 주간 목표 섹션
  Widget _buildWeeklyGoalSection(List<WalkRecordEntity> thisWeekWalks) {
    final totalDays = thisWeekWalks
        .map((walk) => DateFormat('yyyy-MM-dd').format(walk.startTime))
        .toSet()
        .length;
    const goalDays = 7;
    final progressPercentage = (totalDays / goalDays * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '週間目標',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.timeline,
          iconColor: AppColors.pointPink,
          iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
          title: '散歩目標',
          subtitle: '毎日散歩 • 進捗: $totalDays/$goalDays日',
          badge: '$progressPercentage%',
          badgeColor: AppColors.pointPink,
        ),
      ],
    );
  }

  /// 산책 카드
  Widget _buildWalkCard(BuildContext context, WalkRecordEntity walk) {
    final dateFormat = DateFormat('M月d日(E)', 'ja_JP');
    final timeFormat = DateFormat('HH:mm');
    final duration = walk.duration ?? Duration.zero;
    final durationText =
        '${duration.inHours > 0 ? '${duration.inHours}時間' : ''}${duration.inMinutes % 60}分';

    return GenericInfoCard.withIcon(
      icon: Icons.place,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: dateFormat.format(walk.startTime),
      subtitle:
          '${timeFormat.format(walk.startTime)} • ${walk.distance?.toStringAsFixed(1) ?? 0}km • $durationText',
      badge: walk.status == WalkStatus.completed ? '完了' : '進行中',
      badgeColor: walk.status == WalkStatus.completed
          ? AppColors.pointGreen
          : AppColors.pointBlue,
      onTap: () {
        // 산책 상세 화면으로 이동
      },
      showChevron: true,
    );
  }
}
