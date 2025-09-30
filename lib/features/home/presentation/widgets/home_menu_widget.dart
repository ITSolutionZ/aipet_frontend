import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 메뉴 아이템 데이터 모델
class MenuItem {
  final String title;
  final String iconPath; // 아이콘 경로
  final VoidCallback onTap;

  const MenuItem({required this.title, required this.iconPath, required this.onTap});
}

/// 홈 메뉴 그리드 위젯 (Row + Column 조합)
class HomeMenuGridWidget extends StatelessWidget {
  final List<MenuItem> menuItems;
  final int crossAxisCount; // 한 줄에 표시할 개수

  const HomeMenuGridWidget({
    super.key,
    required this.menuItems,
    this.crossAxisCount = 5, // 기본값: 5열
  });

  @override
  Widget build(BuildContext context) {
    // 메뉴를 줄별로 나누기
    final rows = <List<MenuItem>>[];
    for (var i = 0; i < menuItems.length; i += crossAxisCount) {
      rows.add(
        menuItems.sublist(
          i,
          i + crossAxisCount > menuItems.length ? menuItems.length : i + crossAxisCount,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: rows.map((rowItems) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: rowItems.map((item) {
                return Expanded(child: _MenuItemWidget(item: item));
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 단일 메뉴 아이템 위젯 (아이콘 + 텍스트만)
class _MenuItemWidget extends StatelessWidget {
  final MenuItem item;

  const _MenuItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 이미지
            Image.asset(item.iconPath, width: 32, height: 32, fit: BoxFit.contain),
            const SizedBox(height: 6),
            // 메뉴 이름
            Text(
              item.title,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
