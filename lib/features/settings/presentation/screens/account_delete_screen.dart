import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';
import '../widgets/app_bar_widget.dart';

class AccountDeleteScreen extends StatelessWidget {
  const AccountDeleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: const AppBarWidget(title: 'アカウント削除'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),

            // 警告アイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red[400],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // タイトル
            const Text(
              'アカウント削除',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 説明文
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    'アカウント削除はアプリ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '会員登録を意味します。',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl * 2),

            // 確認メッセージ
            Text(
              'アカウント削除しますか？',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[500],
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // ボタン
            Row(
              children: [
                // 削除ボタン
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '削除',
                          style: AppFonts.fredoka(
                            fontSize: AppFonts.lg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // 戻るボタン
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.undo, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '戻る',
                          style: AppFonts.fredoka(
                            fontSize: AppFonts.lg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[400]),
              const SizedBox(width: AppSpacing.xs),
              const Text('最終確認'),
            ],
          ),
          content: const Text(
            '本当にアカウントを削除しますか？\n\nこの操作は取り消すことができません。\nすべてのデータが永久に失われます。',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('キャンセル', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) {
    // TODO: アカウント削除処理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('アカウントが削除されました'),
        backgroundColor: Colors.red,
      ),
    );

    // 複数回pop()してログイン画面に戻る
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
