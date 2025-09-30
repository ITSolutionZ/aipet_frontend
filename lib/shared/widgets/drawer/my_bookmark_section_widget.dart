import 'package:flutter/material.dart';

/// マイブックマークセクションウィジェット
/// 各種ブックマーク機能へのアクセスを提供
class MyBookmarkSectionWidget extends StatelessWidget {
  const MyBookmarkSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          const Row(
            children: [
              Icon(Icons.bookmark, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'マイブックマーク',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                const Color(0xFF6B7FFF),
              ),
              _buildBookmarkItem(
                context,
                Icons.park,
                '遊び場',
                const Color(0xFF50E3C2),
              ),
              _buildBookmarkItem(
                context,
                Icons.directions_walk,
                '散歩',
                const Color(0xFFFFB946),
              ),
              _buildBookmarkItem(
                context,
                Icons.tips_and_updates,
                'お役立ち\nガイド',
                const Color(0xFFFF6B9D),
              ),
              _buildBookmarkItem(
                context,
                Icons.local_cafe,
                'ペット\nカフェ',
                const Color(0xFF9B51E0),
              ),
              _buildBookmarkItem(
                context,
                Icons.terrain,
                'ペット\n散歩道',
                const Color(0xFF56CCF2),
              ),
              _buildBookmarkItem(
                context,
                Icons.book,
                'ペット\n手帳',
                const Color(0xFFF2994A),
              ),
              _buildBookmarkItem(
                context,
                Icons.support_agent,
                'サービス\nセンター',
                const Color(0xFFEB5757),
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
    return InkWell(
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
    );
  }
}
