import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/walk_share_providers.dart';
import '../../domain/entities/walk_record_entity.dart';
import '../controllers/walk_controller.dart';

class WalkInfoBottomSheet extends ConsumerWidget {
  final WalkRecordEntity walkRecord;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const WalkInfoBottomSheet({
    super.key,
    required this.walkRecord,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: isExpanded ? 300 : 200,
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
        children: [
          // 드래그 핸들
          _buildDragHandle(),

          // 헤더
          _buildHeader(),

          // 정보 내용
          Expanded(child: _buildContent(context, ref)),
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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
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
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
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
            onPressed: onToggleExpanded,
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

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // 주요 정보
          _buildInfoRow('開始時間', walkRecord.timeString),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('距離', walkRecord.formattedDistance),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('時間', walkRecord.formattedDuration),

          if (isExpanded) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: Colors.grey[300]),
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
                      foregroundColor: Colors.white,
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
        return '진행 중';
      case WalkStatus.completed:
        return '완료';
      case WalkStatus.paused:
        return '일시정지';
      case WalkStatus.cancelled:
        return '취소';
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
        title: const Text('공유'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('텍스트 복사'),
              onTap: () {
                Navigator.of(context).pop();
                _copyToClipboard(context, ref, shareText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('이미지로 저장'),
              onTap: () {
                Navigator.of(context).pop();
                _saveAsImage(context, ref, walkRecord);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('시스템 공유'),
              onTap: () {
                Navigator.of(context).pop();
                _systemShare(context, ref, shareText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
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
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
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
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
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
    final result = await useCase(text, subject: '산책 기록 공유');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 산책 기록 수정 다이얼로그 표시
  void _showEditWalkDialog(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EditWalkDialog(
        walkRecord: walkRecord,
        controller: WalkController(ref),
      ),
    );
  }
}

/// 산책 기록 수정 다이얼로그
class _EditWalkDialog extends StatefulWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const _EditWalkDialog({required this.walkRecord, required this.controller});

  @override
  State<_EditWalkDialog> createState() => _EditWalkDialogState();
}

class _EditWalkDialogState extends State<_EditWalkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.walkRecord.title);
    _notesController = TextEditingController(
      text: widget.walkRecord.notes ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '산책 기록 수정',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '散歩のタイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('開始時間: ${widget.walkRecord.timeString}'),
                  Text('経過時間: ${widget.walkRecord.formattedDuration}'),
                  Text('距離: ${widget.walkRecord.formattedDistance}'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _updateWalk,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pointBrown,
            foregroundColor: Colors.white,
          ),
          child: const Text('更新'),
        ),
      ],
    );
  }

  void _updateWalk() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 수정된 산책 기록 생성
        final updatedWalkRecord = widget.walkRecord.copyWith(
          title: _titleController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          updatedAt: DateTime.now(),
        );

        // 컨트롤러를 통해 수정
        final result = await widget.controller.updateWalkRecord(
          updatedWalkRecord,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: result.isSuccess ? Colors.green : Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('更新に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
