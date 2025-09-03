import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// 공통으로 사용할 수 있는 Summary Card 위젯
/// 중복 코드를 제거하고 일관된 디자인을 제공합니다.
class CommonSummaryCard extends StatelessWidget {
  const CommonSummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.mainValue,
    required this.unit,
    this.onTap,
    this.subtitle,
    this.secondaryValue,
  });

  final IconData icon;
  final Color iconColor;
  final String mainValue;
  final String unit;
  final VoidCallback? onTap;
  final String? subtitle;
  final String? secondaryValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 원형 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: iconColor.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(height: 12),

            // 메인 수치와 단위
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  mainValue,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ],
            ),

            // 부제목 (있는 경우)
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGray,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 보조 값 (있는 경우)
            if (secondaryValue != null) ...[
              const SizedBox(height: 4),
              Text(
                secondaryValue!,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGray,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
