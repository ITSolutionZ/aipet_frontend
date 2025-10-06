import 'package:flutter/material.dart';

/// ドロワー情報バナーウィジェット
/// 情報登録の案内とボタンを表示
class DrawerInfoBannerWidget extends StatelessWidget {
  const DrawerInfoBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '一緒に情報を登録して\nカスタムサービスを受けてください',
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // 情報設定画面へ遷移
              Navigator.of(context).pop();
              // TODO: 情報設定画面への遷移処理
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A5EA6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('情報設定', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
