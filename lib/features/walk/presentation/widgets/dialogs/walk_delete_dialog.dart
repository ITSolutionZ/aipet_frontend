import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 산책 기록 삭제 확인 다이얼로그
class WalkDeleteDialog extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const WalkDeleteDialog({
    super.key,
    required this.walkRecord,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context,
    WalkRecordEntity walkRecord,
    WalkController controller,
  ) {
    return showDialog(
      context: context,
      builder: (context) =>
          WalkDeleteDialog(walkRecord: walkRecord, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('削除確認'),
      content: Text('「${walkRecord.title}」の散歩記録を削除しますか？\nこの操作は取り消せません。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            controller.deleteWalkRecord(walkRecord.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('散歩記録を削除しました'),
                  backgroundColor: AppColors.pointGreen,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pointPink,
            foregroundColor: Colors.white,
          ),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
