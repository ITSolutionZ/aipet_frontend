import 'package:flutter/material.dart';


import '../../../../../../shared/shared.dart';
/// Live Walk UI 헬퍼
class LiveWalkUiHelper {
  /// 원형 버튼 빌드 (뒤로가기/메뉴)
  static Widget buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  /// 하단 버튼들 빌드
  static Widget buildBottomButtons({
    required bool isRunning,
    required bool isPaused,
    required VoidCallback onShowRecords,
    required VoidCallback onWalkButtonPress,
  }) {
    return Row(
      children: [
        // 펫 기록 버튼 (왼쪽, 흰색)
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: onShowRecords,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                '펫 기록',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 산책 시작/중지 버튼 (오른쪽, 갈색/핑크)
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isRunning ? AppColors.pointPink : AppColors.pointBrown,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color:
                      (isRunning ? AppColors.pointPink : AppColors.pointBrown)
                          .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: onWalkButtonPress,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                isRunning
                    ? '散歩終了'
                    : isPaused
                    ? '散歩再開'
                    : '散歩 시작',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
