import 'package:aipet_frontend/features/walk/data/providers/walk_share_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dialogs/edit_walk_bottom_sheet.dart';

/// 🎯 Walk Info Bottom Sheet Expansion State Provider
final walkInfoBottomSheetProvider =
    StateNotifierProvider.family<WalkInfoExpansionController, bool, String>(
      (ref, sheetId) => WalkInfoExpansionController(),
    );

class WalkInfoExpansionController extends StateNotifier<bool> {
  WalkInfoExpansionController() : super(false);

  void toggle() {
    state = !state;
  }
}

class WalkInfoBottomSheet extends ConsumerWidget {
  final WalkRecordEntity walkRecord;

  const WalkInfoBottomSheet({super.key, required this.walkRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetId = walkRecord.id;
    final isExpanded = ref.watch(walkInfoBottomSheetProvider(sheetId));
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          _buildDragHandle(),

          // 헤더
          _buildHeader(context, ref, sheetId, isExpanded),

          // 정보 내용 (스크롤 가능)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _buildContent(context, ref, isExpanded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String sheetId,
    bool isExpanded,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                walkRecord.ownerAvatar ?? 'assets/images/placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.pointGray.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.pointGray,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      walkRecord.ownerName ?? 'Hanna Blair',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '(3.5)',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'ドッグウォーカー',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),

          // 확장/축소 버튼
          IconButton(
            onPressed: () {
              ref.read(walkInfoBottomSheetProvider(sheetId).notifier).toggle();
            },
            icon: Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: AppColors.pointGray,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, bool isExpanded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 주요 정보
          _buildInfoRow('開始時間', walkRecord.timeString),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('距離', walkRecord.formattedDistance),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('時間', walkRecord.formattedDuration),

          if (isExpanded) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: AppColors.pointGray.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // 추가 정보
            _buildInfoRow('日付', walkRecord.dateString),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow('状態', _getStatusText(walkRecord.status)),
            if (walkRecord.notes != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('メモ', walkRecord.notes!),
            ],

            const SizedBox(height: AppSpacing.lg),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showShareDialog(context, ref, walkRecord);
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('共有'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pointBrown,
                      side: const BorderSide(color: AppColors.pointBrown),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showEditWalkDialog(context, ref, walkRecord);
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('編集'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: AppColors.pointOffWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
        Text(
          value,
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getStatusText(WalkStatus status) {
    switch (status) {
      case WalkStatus.inProgress:
        return '散歩中';
      case WalkStatus.completed:
        return '完了';
      case WalkStatus.paused:
        return '一時停止';
      case WalkStatus.cancelled:
        return 'キャンセル';
    }
  }

  /// 산책 기록 공유 다이얼로그 표시
  void _showShareDialog(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) {
    final shareText = ref.read(shareTextProvider(walkRecord));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('共有'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('テキストをコピー'),
              onTap: () {
                context.pop();
                _copyToClipboard(context, ref, shareText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('画像を保存'),
              onTap: () {
                context.pop();
                _saveAsImage(context, ref, walkRecord);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('システム共有'),
              onTap: () {
                context.pop();
                _systemShare(context, ref, shareText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 클립보드에 복사
  Future<void> _copyToClipboard(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    final useCase = ref.read(copyToClipboardUseCaseProvider);
    final result = await useCase(text);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? AppColors.pointGreen
              : AppColors.pointPink,
        ),
      );
    }
  }

  /// 이미지로 저장
  Future<void> _saveAsImage(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) async {
    final useCase = ref.read(saveAsImageUseCaseProvider);
    final result = await useCase(walkRecord);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? AppColors.pointGreen
              : AppColors.pointPink,
        ),
      );
    }
  }

  /// 시스템 공유
  Future<void> _systemShare(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    final useCase = ref.read(systemShareUseCaseProvider);
    final result = await useCase(text, subject: '散歩記録を共有');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? AppColors.pointGreen
              : AppColors.pointPink,
        ),
      );
    }
  }

  /// 산책 기록 수정 바텀 시트 표시
  void _showEditWalkDialog(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) {
    EditWalkBottomSheet.show(context, walkRecord, WalkController(ref));
  }
}
