import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
/// 트레이닝 다이얼로그 헬퍼
class TrainingDialogHelper {
  /// 고급 기술 다이얼로그
  static void showAdvancedSkillsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('高度な技'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの高度なスキルを練習しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () =>
                  SnackBarService.showInfo(context, '芸の練習機能は開発中です'),
              icon: const Icon(Icons.sports_gymnastics),
              label: const Text('芸を練習'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointGreen,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () =>
                  SnackBarService.showInfo(context, 'アジリティ訓練機能は開発中です'),
              icon: const Icon(Icons.fitness_center),
              label: const Text('アジリティ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () =>
                  SnackBarService.showInfo(context, '服従訓練機能は開発中です'),
              icon: const Icon(Icons.psychology),
              label: const Text('服従訓練'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 트레이닝 스케줄 다이얼로그
  static void showTrainingScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('練習スケジュール'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの練習スケジュールを管理しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => showCreateScheduleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('新しいスケジュール'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tonePeach,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () =>
                  SnackBarService.showInfo(context, '週間スケジュール機能は開発中です'),
              icon: const Icon(Icons.calendar_view_week),
              label: const Text('週間スケジュール'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () =>
                  SnackBarService.showInfo(context, 'リマインダー設定機能は開発中です'),
              icon: const Icon(Icons.notifications),
              label: const Text('リマインダー設定'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 트레이닝 시작 다이얼로그
  static void showStartTrainingDialog(BuildContext context, String command) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$command の練習'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$command のコマンドを練習しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                SnackBarService.showSaved(
                  context,
                  itemName: '$command の練習セッション',
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('練習開始'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 새 스케줄 생성 다이얼로그
  static void showCreateScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいスケジュール'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('練習スケジュールを作成しましょう'),
            SizedBox(height: AppSpacing.lg),
            TextField(
              decoration: InputDecoration(
                labelText: 'スケジュール名',
                hintText: '例: 毎日の基本練習',
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                labelText: '練習内容',
                hintText: '座る、待て、来い',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SnackBarService.showSaved(context, itemName: '新しいスケジュール');
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }
}
