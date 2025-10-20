import 'package:flutter/material.dart';

import 'drawer_local_datasource.dart';

/// ドロワー情報バナーウィジェット
/// 情報登録の案内とボタンを表示
class DrawerInfoBannerWidget extends StatelessWidget {
  const DrawerInfoBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 데이터에서 정보 배너 데이터 가져오기
    final infoBanner = DrawerLocalDatasource.getInfoBanner();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              infoBanner['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: infoBanner['isEnabled']
                ? () {
                    // 情報設定画面へ遷移
                    Navigator.of(context).pop();
                    // TODO: 情報設定画面への遷移処理
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A5EA6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              infoBanner['buttonText'],
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
