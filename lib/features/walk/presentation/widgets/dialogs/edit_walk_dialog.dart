import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../../walk.dart';

class EditWalkDialog extends StatefulWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const EditWalkDialog({
    super.key,
    required this.walkRecord,
    required this.controller,
  });

  @override
  State<EditWalkDialog> createState() => _EditWalkDialogState();
}

class _EditWalkDialogState extends State<EditWalkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.walkRecord.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
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
            Text('開始時間: ${widget.walkRecord.timeString}'),
            Text('経過時間: ${widget.walkRecord.formattedDuration}'),
            Text('距離: ${widget.walkRecord.formattedDistance}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(onPressed: _updateWalk, child: const Text('更新')),
      ],
    );
  }

  void _updateWalk() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 수정된 산책 기록 생성
        final updatedWalkRecord = WalkRecordEntity(
          id: widget.walkRecord.id,
          title: _titleController.text,
          startTime: widget.walkRecord.startTime,
          endTime: widget.walkRecord.endTime,
          distance: widget.walkRecord.distance,
          duration: widget.walkRecord.duration,
          route: widget.walkRecord.route,
        );

        // 컨트롤러를 통해 수정
        await widget.controller.updateWalkRecord(updatedWalkRecord);

        if (mounted) {
          Navigator.of(context).pop();
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
}
