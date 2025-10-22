import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/controllers/tricks_controller.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/learn_next_section.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/trick_action_buttons.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/trick_management_bottom_sheet.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/your_tricks_section.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 펫 트릭 학습 화면
///
/// 펫이 배운 트릭과 다음에 배울 트릭을 보여주는 화면입니다.
/// 유튜브 트레이닝 비디오 기능과 연계됩니다.
class LearnTrickScreen extends ConsumerStatefulWidget {
  const LearnTrickScreen({super.key});

  @override
  ConsumerState<LearnTrickScreen> createState() => _LearnTrickScreenState();
}

class _LearnTrickScreenState extends ConsumerState<LearnTrickScreen> {
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

  /// 유튜브 트레이닝 비디오 화면으로 이동
  void _openTrainingVideos() {
    context.push('/training-videos');
  }

  void _showTrickManagementMenu() {
    TrickManagementBottomSheet.show(
      context,
      onResetProgress: _showResetProgressDialog,
    );
  }

  void _showResetProgressDialog() {
    ConfirmationDialogComponent.showClear(
      context: context,
      title: '進捗をリセットしますか？',
      message: 'すべてのトリックの進捗をリセットしますか？この操作は元に戻せません。',
      onConfirm: () async {
        await _controller.resetAllProgress();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('すべてのトリックの進捗がリセットされました'),
              backgroundColor: AppColors.pointBlue,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tricksState = ref.watch(allTricksProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: 'ペットアクティビティ'),
      body: tricksState.when(
        data: (tricks) => _buildContent(tricks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.pointBrown,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'エラーが発生しました',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$error',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(onPressed: _loadTricks, child: const Text('再試行')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<TrickEntity> tricks) {
    final learnedTricks = tricks
        .where((trick) => trick.practiceCount > 0)
        .toList();
    final availableTricks = tricks
        .where((trick) => trick.practiceCount == 0)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your tricks 섹션 - 학습한 트릭들
          YourTricksSection(
            learnedTricks: learnedTricks,
            onManageTricks: _showTrickManagementMenu,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Learn next 섹션 - 배울 수 있는 트릭들
          LearnNextSection(availableTricks: availableTricks),
          const SizedBox(height: AppSpacing.xl),

          // Action buttons - 유튜브 트레이닝 비디오 버튼
          TrickActionButtons(onOpenTrainingVideos: _openTrainingVideos),
        ],
      ),
    );
  }
}
