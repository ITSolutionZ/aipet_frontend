import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.sm, // SafeArea 위로 띄운 플로팅 스타일
        ),
        child: Container(
          height: 56, // 적절한 높이로 조정
          decoration: const BoxDecoration(
            color: Colors.transparent, // 완전히 투명한 배경
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(Icons.home, 0, '홈'),
              _buildNavItem(Icons.smart_toy, 1, 'AI'),
              _buildNavItem(Icons.directions_walk, 2, '散歩'),
              _buildNavItem(Icons.calendar_today, 3, 'カレンダー'),
              _buildNavItem(Icons.settings, 4, '設定'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppColors
                    .pointBrown // 선택된 아이콘: 다크 브라운
              : AppColors.pointDark.withValues(
                  alpha: 0.6,
                ), // 비선택 아이콘: 더 진한 색상으로 가시성 향상
          size: 24, // 아이콘 크기 약간 증가
        ),
      ),
    );
  }
}
