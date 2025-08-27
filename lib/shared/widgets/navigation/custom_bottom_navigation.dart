import 'package:flutter/material.dart';

import '../../shared.dart';

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
    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md, // 하단 마진을 늘려서 떠있는 느낌 강화
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // 더 둥근 모서리로 떠있는 느낌 강화
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -3),
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 50, // 높이를 더 낮춤
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(Icons.home, 0, '홈'),
              _buildNavItem(Icons.smart_toy, 1, 'AI'),
              _buildNavItem(Icons.calendar_today, 2, '캘린더'),
              _buildNavItem(Icons.notifications, 3, '알람'),
              _buildNavItem(Icons.settings, 4, '설정'),
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
        height: 46, // 고정 높이 설정으로 중앙 정렬 보장
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? _getTabColor(index).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25), // 탭 아이템도 더 둥글게
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? _getTabColor(index) : Colors.grey[600],
              size: 20, // 아이콘 크기를 줄여서 낮은 높이에 맞춤
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppFonts.bodySmall.copyWith(
                  color: _getTabColor(index),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 각 탭별 색상 반환 (추후 사용자가 정할 수 있도록 임시 색상)
  Color _getTabColor(int index) {
    switch (index) {
      case 0: // 홈
        return const Color(0xFF8B5CF6); // 보라색
      case 1: // AI
        return const Color(0xFFEC4899); // 분홍색
      case 2: // 캘린더
        return const Color(0xFFF59E0B); // 노란색
      case 3: // 알람
        return const Color(0xFF06B6D4); // 청록색
      case 4: // 설정
        return const Color(0xFF10B981); // 초록색
      default:
        return AppColors.pointBrown;
    }
  }
}
