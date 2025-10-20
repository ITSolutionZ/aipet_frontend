import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

import 'drawer_local_datasource.dart';

/// マイブックマークセクションウィジェット
/// 各種ブックマーク機能へのアクセスを提供
class MyBookmarkSectionWidget extends StatelessWidget {
  const MyBookmarkSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 데이터에서 북마크 섹션 데이터 가져오기
    final bookmarkSection = DrawerLocalDatasource.getBookmarkSection();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Row(
            children: [
              const Icon(Icons.bookmark, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                bookmarkSection['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (bookmarkSection['itemCount'] > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${bookmarkSection['itemCount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // ブックマークアイコングリッド
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildBookmarkItem(
                context,
                Icons.restaurant,
                'グルメ\n探訪',
                AppColors.pointBlue,
              ),
              _buildBookmarkItem(
                context,
                Icons.park,
                '遊び場',
                AppColors.pointGreen,
              ),
              _buildBookmarkItem(
                context,
                Icons.directions_walk,
                '散歩',
                AppColors.pointOlive,
              ),
              _buildBookmarkItem(
                context,
                Icons.tips_and_updates,
                'お役立ち\nガイド',
                AppColors.pointPink,
              ),
              _buildBookmarkItem(
                context,
                Icons.local_cafe,
                'ペット\nカフェ',
                AppColors.pointBrown,
              ),
              _buildBookmarkItem(
                context,
                Icons.terrain,
                'ペット\n散歩道',
                AppColors.pointBlue,
              ),
              _buildBookmarkItem(
                context,
                Icons.book,
                'ペット\n手帳',
                AppColors.toneSand,
              ),
              _buildBookmarkItem(
                context,
                Icons.support_agent,
                'サービス\nセンター',
                AppColors.toneRoseBrown,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ブックマークアイテムを構築
  Widget _buildBookmarkItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    // 改行を削除してアクセシビリティラベルを作成
    final accessibilityLabel = label.replaceAll('\n', '');

    return Semantics(
      label: '$accessibilityLabelボタン',
      button: true,
      hint: 'タップして$accessibilityLabelを開きます',
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          // TODO: 各ブックマーク機能への遷移処理
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
