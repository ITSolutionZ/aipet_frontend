import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ペットカードセクションウィジェット
/// ペット情報カードと追加ボタンを表示
class PetCardSectionWidget extends StatelessWidget {
  const PetCardSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ペットカード表示エリア
          Text(
            '旅と概要登録をして様々な情報を確認しよう',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          // ペットカード
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7B68BE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Color(0xFF7B68BE),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '犬犬ちゃん',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ロボロヴスキー',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '男の子 / 成犬 6ヶ月 / 1.8kg',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // プロフィール確認画面へ遷移
                      Navigator.of(context).pop();
                      // TODO: ペット詳細画面への遷移処理
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      'プロフィール確認',
                      style: TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ペット追加ボタン
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              context.go(RouteConstants.petTypeSelectionRoute);
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ペット追加',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
