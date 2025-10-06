import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ドロワーヘッダーウィジェット
/// プロフィール情報と統計を表示
class DrawerHeaderWidget extends StatelessWidget {
  final String? userImagePath;

  const DrawerHeaderWidget({super.key, this.userImagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // アバター
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: userImagePath == null ? Colors.white : null,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: AssetImage(
                  userImagePath ?? 'assets/icons/logos/aipet_logo.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 統計情報と位置設定
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _StatItem(label: '購読', value: '0'),
                const _StatItem(label: '投稿', value: '0'),
                const _StatItem(label: 'コメント', value: '0'),
                // 位置設定ボタン
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(); // ドロワーを閉じる
                    context.push(RouteConstants.locationSettingRoute);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 18),
                      SizedBox(height: 2),
                      Text(
                        '位置設定',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 統計アイテムウィジェット
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}
