import 'package:aipet_frontend/app/widgets/widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountDeleteScreen extends StatelessWidget {
  const AccountDeleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: const SoftGradientDrawerAppBar(title: 'アカウント削除'),
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
                  child: CommonButton(
                    text: '削除',
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    type: ButtonType.danger,
                    size: ButtonSize.large,
                    icon: Icons.delete_forever,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // 戻るボタン
                Expanded(
                  child: CommonButton(
                    text: '戻る',
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.secondary,
                    size: ButtonSize.large,
                    icon: Icons.undo,
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

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // 로딩 표시
      if (context.mounted) {
        UiService.showLoadingDialog(context, 'アカウント削除中...');
      }

      // 1. 모든 로컬 데이터 삭제
      await LocalDataManager.instance.clearAllLocalData();

      // 2. 인증 정보 삭제
      await SecureStorageService.logout();

      if (context.mounted) {
        UiService.hideLoadingDialog(context);
        SnackBarService.showError(context, 'アカウントが削除されました');

        // 로그인 화면으로 이동
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        UiService.hideLoadingDialog(context);
        SnackBarService.showError(context, '削除中にエラーが発生しました: $e');
      }
    }
  }
}
