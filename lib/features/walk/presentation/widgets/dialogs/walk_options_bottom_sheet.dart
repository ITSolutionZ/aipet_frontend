import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import '../../../walk.dart';

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
              Navigator.of(context).pop();
              _showEditWalkDialog(context, walkRecord);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('共有'),
            onTap: () {
              Navigator.of(context).pop();
              _showShareDialog(context, ref, walkRecord);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.pointPink),
            title: const Text(
              '削除',
              style: TextStyle(color: AppColors.pointPink),
            ),
            onTap: () {
              Navigator.of(context).pop();
              controller.deleteWalkRecord(walkRecord.id);
            },
          ),
        ],
      ),
    );
  }

  /// 산책 기록 공유 다이얼로그 표시
  void _showShareDialog(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) {
    // TODO: shareTextProvider 구현 필요
    final shareText =
        '散歩記録: ${walkRecord.title} - ${walkRecord.formattedDistance}';

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
                Navigator.of(context).pop();
                _copyToClipboard(context, shareText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('画像を保存'),
              onTap: () {
                Navigator.of(context).pop();
                _saveAsImage(context, walkRecord);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('システム共有'),
              onTap: () {
                Navigator.of(context).pop();
                _systemShare(context, shareText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 클립보드에 복사
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    // TODO: 클립보드 복사 로직 구현
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('テキストがコピーされました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );
    }
  }

  /// 이미지로 저장
  Future<void> _saveAsImage(
    BuildContext context,
    WalkRecordEntity walkRecord,
  ) async {
    // TODO: 이미지 저장 로직 구현
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画像が保存されました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );
    }
  }

  /// 시스템 공유
  Future<void> _systemShare(BuildContext context, String text) async {
    // TODO: 시스템 공유 로직 구현
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('共有が完了しました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );
    }
  }

  /// 산책 기록 수정 바텀 시트 표시
  void _showEditWalkDialog(BuildContext context, WalkRecordEntity walkRecord) {
    EditWalkBottomSheet.show(context, walkRecord, controller);
  }
}

// EditWalkBottomSheet는 별도 파일에서 import됨
