import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/forms/walk_edit_form.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation.dart';

/// 선택된 공동 관리자 ID 상태 Provider
final selectedCoManagerProvider = StateProvider<String?>((ref) => null);

class EditWalkBottomSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCoManagerId = ref.watch(selectedCoManagerProvider);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
        ),
        child: Padding(
          padding: EdgeInsets.only(
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
                WalkPetTag(petName: walkRecord.petName),
                const SizedBox(height: AppSpacing.xl),
                WalkEditForm(
                  walkRecord: walkRecord,
                  onSave: (updatedRecord) =>
                      _updateWalk(context, ref, updatedRecord),
                  onCancel: () => context.pop(),
                ),
                const SizedBox(height: AppSpacing.lg),
                WalkCoManagerSelector(
                  selectedCoManagerId: selectedCoManagerId,
                  onChanged: (managerId) {
                    ref.read(selectedCoManagerProvider.notifier).state =
                        managerId;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateWalk(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity updatedWalkRecord,
  ) async {
    try {
      // 공동 관리자 정보를 추가해서 업데이트
      final finalRecord = updatedWalkRecord.copyWith(updatedAt: DateTime.now());

      // 컨트롤러를 통해 수정
      await controller.updateWalkRecord(finalRecord);

      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('散歩記録が更新されました'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
        // 상태 초기화
        ref.read(selectedCoManagerProvider.notifier).state = null;
      }
    } catch (e) {
      if (context.mounted) {
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
