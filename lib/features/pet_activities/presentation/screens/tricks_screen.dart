import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/features/scheduling/presentation/controllers/tricks_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/learn_next_section.dart';
import 'package:aipet_frontend/shared/widgets/trick_action_buttons.dart';
import 'package:aipet_frontend/shared/widgets/trick_management_bottom_sheet.dart';
import 'package:aipet_frontend/shared/widgets/your_tricks_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: const SoftGradientBackAppBar(title: 'Pet Profile'),
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
          YourTricksSection(
            learnedTricks: learnedTricks,
            onManageTricks: _showTrickManagementMenu,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Learn next 섹션
          LearnNextSection(availableTricks: availableTricks),
          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          TrickActionButtons(onOpenTrainingVideos: _openTrainingVideos),
        ],
      ),
    );
  }
}
