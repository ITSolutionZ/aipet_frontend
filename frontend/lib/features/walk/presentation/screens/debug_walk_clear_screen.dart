import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/walk/data/services/local_walk_storage_service.dart';

/// 디버그용: 로컬 산책 데이터 강제 삭제 화면
class DebugWalkClearScreen extends StatelessWidget {
  const DebugWalkClearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('デバッグ: 散歩データクリア'),
        backgroundColor: AppColors.pointPink,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 64, color: AppColors.pointPink),
              const SizedBox(height: 24),
              const Text(
                '進行中の散歩データを\n強制的に削除します',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await _clearCurrentWalk(context);
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('現在の散歩を削除'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearCurrentWalk(BuildContext context) async {
    try {
      // 로컬 스토리지에서 현재 산책 제거
      await LocalWalkStorageService.saveCurrentWalk(null);

      if (context.mounted) {
        SnackBarService.showSuccess(context, '✅ 現在の散歩データを削除しました');

        // 화면 닫기
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, '❌ 削除失敗: $e');
      }
    }
  }
}
