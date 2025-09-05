import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../../walk.dart';

class CurrentWalkDialog extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const CurrentWalkDialog({
    super.key,
    required this.walkRecord,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '散歩中',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('散歩のタイトル: ${walkRecord.title}'),
          Text('開始時間: ${walkRecord.timeString}'),
          Text('経過時間: ${walkRecord.formattedDuration}'),
          Text('距離: ${walkRecord.formattedDistance}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            controller.pauseCurrentWalk();
          },
          child: const Text('一時停止'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await controller.endCurrentWalk();
          },
          child: const Text('終了'),
        ),
      ],
    );
  }
}
