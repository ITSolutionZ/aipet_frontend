import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/walk/domain/entities/walk_record_entity.dart';
import '../../../../../../features/walk/presentation/controllers/walk_controller.dart';
import '../../presentation.dart';
import 'dialogs.dart';


class WalkOptionsBottomSheet extends ConsumerWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const WalkOptionsBottomSheet({
    super.key,
    required this.walkRecord,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('編集'),
            onTap: () {
              context.pop();
              _showEditWalkDialog(context, walkRecord);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('共有'),
            onTap: () {
              context.pop();
              WalkShareDialog.show(context, walkRecord);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.pointPink),
            title: const Text(
              '削除',
              style: TextStyle(color: AppColors.pointPink),
            ),
            onTap: () {
              context.pop();
              WalkDeleteDialog.show(context, walkRecord, controller);
            },
          ),
        ],
      ),
    );
  }

  /// 산책 기록 수정 바텀 시트 표시
  void _showEditWalkDialog(BuildContext context, WalkRecordEntity walkRecord) {
    EditWalkBottomSheet.show(context, walkRecord, controller);
  }
}
