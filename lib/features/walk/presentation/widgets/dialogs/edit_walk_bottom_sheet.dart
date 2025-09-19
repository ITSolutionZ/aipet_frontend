import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../walk.dart';
import '../forms/walk_edit_form.dart';

class EditWalkBottomSheet extends StatefulWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const EditWalkBottomSheet({
    super.key,
    required this.walkRecord,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context,
    WalkRecordEntity walkRecord,
    WalkController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) =>
          EditWalkBottomSheet(walkRecord: walkRecord, controller: controller),
    );
  }

  @override
  State<EditWalkBottomSheet> createState() => _EditWalkBottomSheetState();
}

class _EditWalkBottomSheetState extends State<EditWalkBottomSheet> {
  String? _selectedCoManagerId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '散歩記録を編集',
                style: AppFonts.point(
                  fontSize: AppFonts.xxl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.walkRecord.petName != null)
                WalkPetTag(petName: widget.walkRecord.petName!),
              const SizedBox(height: AppSpacing.xl),
              WalkEditForm(
                walkRecord: widget.walkRecord,
                onSave: _updateWalk,
                onCancel: () => context.pop(),
              ),
              const SizedBox(height: AppSpacing.lg),
              WalkCoManagerSelector(
                selectedCoManagerId: _selectedCoManagerId,
                onChanged: (managerId) {
                  setState(() {
                    _selectedCoManagerId = managerId;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '散歩の詳細',
                style: AppFonts.point(
                  fontSize: AppFonts.lg,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              WalkDetailInfoCard(walkRecord: widget.walkRecord),
              const SizedBox(height: AppSpacing.lg),
              if (widget.walkRecord.createdAt != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.pointBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: AppColors.pointBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.pointBlue,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '記録日時: ${_formatDate(widget.walkRecord.createdAt!)}',
                        style: AppFonts.base(
                          fontSize: AppFonts.sm,
                          color: AppColors.pointBlue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _updateWalk(WalkRecordEntity updatedWalkRecord) async {
    try {
      // 공동 관리자 정보를 추가해서 업데이트
      final finalRecord = updatedWalkRecord.copyWith(updatedAt: DateTime.now());

      // 컨트롤러를 통해 수정
      await widget.controller.updateWalkRecord(finalRecord);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('散歩記録が更新されました'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
            backgroundColor: AppColors.pointPink,
          ),
        );
      }
    }
  }
}
