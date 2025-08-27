import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/trick_entity.dart';
import '../controllers/tricks_controller.dart';
import '../widgets/learn_next_trick_card.dart';
import '../widgets/trick_progress_card.dart';

/// 펫 트릭 화면
///
/// 펫이 배운 트릭과 다음에 배울 트릭을 보여주는 화면입니다.
class TricksScreen extends ConsumerStatefulWidget {
  const TricksScreen({super.key});

  @override
  ConsumerState<TricksScreen> createState() => _TricksScreenState();
}

class _TricksScreenState extends ConsumerState<TricksScreen> {
  late TricksController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TricksController(ref, context);
    _loadTricks();
  }

  Future<void> _loadTricks() async {
    await _controller.loadTricks();
  }

  // Changed: 유튜브 교육 영상 관리 화면으로 이동
  void _openTrainingVideos() {
    context.push('/training-videos');
  }

  void _showTrickManagementMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.lg),
              topRight: Radius.circular(AppSpacing.lg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.pointDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      'Trick Management',
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMenuOption(
                      icon: Icons.edit,
                      title: 'Edit tricks',
                      subtitle: 'Modify learned tricks',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/edit-tricks');
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.delete_outline,
                      title: 'Reset progress',
                      subtitle: 'Clear all trick progress',
                      onTap: () {
                        Navigator.pop(context);
                        _showResetProgressDialog();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.analytics_outlined,
                      title: 'View statistics',
                      subtitle: 'See learning progress stats',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/trick-statistics');
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.pointBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Icon(
          icon,
          color: AppColors.pointBlue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppFonts.fredoka(
          fontSize: AppFonts.baseSize,
          color: AppColors.pointDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.bodySmall.copyWith(
          color: AppColors.pointDark.withValues(alpha: 0.7),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
    );
  }

  void _showResetProgressDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          title: Text(
            'Reset Progress',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all trick progress? This action cannot be undone.',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _controller.resetAllProgress();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All trick progress has been reset'),
                      backgroundColor: AppColors.pointBlue,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tricksState = ref.watch(allTricksProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pet Profile',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // 펫 프로필 이미지 (Maxi)
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/dogs/shiba.png'),
              backgroundColor: AppColors.pointBrown,
            ),
          ),
          // Changed: 교육 영상 아이콘 버튼 추가
          IconButton(
            icon: const Icon(Icons.ondemand_video, color: AppColors.pointDark),
            tooltip: 'Training videos',
            onPressed: _openTrainingVideos,
          ),
        ],
      ),
      body: tricksState.when(
        data: (tricks) => _buildContent(tricks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }

  Widget _buildContent(List<TrickEntity> tricks) {
    final learnedTricks = tricks
        .where((trick) => trick.progress != null)
        .toList();
    final availableTricks = tricks
        .where((trick) => trick.progress == null)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your tricks 섹션
          _buildYourTricksSection(learnedTricks),
          const SizedBox(height: AppSpacing.xl),

          // Learn next 섹션
          _buildLearnNextSection(availableTricks),
          const SizedBox(height: AppSpacing.xl),

          // Learn new tricks 버튼
          _buildLearnNewTricksButton(),
          // Changed: 유튜브 교육 영상 관리 버튼 추가
          const SizedBox(height: AppSpacing.lg),
          _buildTrainingVideosButton(),
        ],
      ),
    );
  }

  Widget _buildYourTricksSection(List<TrickEntity> learnedTricks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '学んだトリック',
              style: AppFonts.fredoka(
                fontSize: AppFonts.xl,
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.pointDark),
              onPressed: () => _showTrickManagementMenu(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (learnedTricks.isEmpty)
          Center(
            child: Text(
              'まだ 学んだトリックがありません。',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          ...learnedTricks.map(
            (trick) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TrickProgressCard(trick: trick),
            ),
          ),
      ],
    );
  }

  Widget _buildLearnNextSection(List<TrickEntity> availableTricks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Learn next',
              style: AppFonts.fredoka(
                fontSize: AppFonts.xl,
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/all-tricks'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'すべて見る',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.pointBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (availableTricks.isEmpty)
          Center(
            child: Text(
              '学習完了しました',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          ...availableTricks
              .take(3)
              .map(
                (trick) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: LearnNextTrickCard(trick: trick),
                ),
              ),
      ],
    );
  }

  Widget _buildLearnNewTricksButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          context.push('/learn-trick');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.pointBlue, width: 2),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
        child: Text(
          'Learn new tricks',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Changed: 유튜브 교육 영상 관리 버튼 위젯
  Widget _buildTrainingVideosButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _openTrainingVideos,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.pointBlue, width: 2),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
        child: Text(
          'Training videos',
          // Changed
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
