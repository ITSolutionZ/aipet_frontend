import 'dart:ui';

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 18,
              sigmaY: 18,
            ), // Glass 효과 blur 16~20
            child: Container(
              height: 56, // 적절한 높이로 조정
              decoration: BoxDecoration(
                color: AppColors.pointBrown
                    .withValues(alpha: 0.47)
                    .withValues(alpha: 0.47), // 브라운 배경 opacity 0.45~0.5
                borderRadius: BorderRadius.circular(AppRadius.circle),
                border: Border.all(
                  color: AppColors.pointCream.withValues(
                    alpha: 0.35,
                  ), // 흰색 테두리 opacity 0.35
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.14,
                    ), // 아래 방향 soft shadow
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
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
              : AppColors.pointGray, // 비선택 아이콘: 그레이
          size: 24, // 아이콘 크기 약간 증가
        ),
      ),
    );
  }
}
