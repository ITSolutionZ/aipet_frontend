import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 산책 정보 표시 위젯들
class WalkInfoWidgets {
  WalkInfoWidgets._();

  /// 산책 통계 카드
  static Widget buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.pointBlue).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: iconColor ?? AppColors.pointBlue,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.pointGray,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  value,
                  style: AppFonts.headlineMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 산책 정보 행
  static Widget buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? AppColors.pointGray),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const Spacer(),
          Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              color: textColor ?? AppColors.pointDark,
              fontWeight: fontWeight ?? FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 산책 상태 배지
  static Widget buildStatusBadge({
    required String status,
    required Color color,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status,
        style: AppFonts.bodySmall.copyWith(
          color: textColor ?? color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 진행률 표시 위젯
  static Widget buildProgressIndicator({
    required double progress,
    required String label,
    String? subtitle,
    Color? progressColor,
    Color? backgroundColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor:
              backgroundColor ?? AppColors.pointGray.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            progressColor ?? AppColors.pointBlue,
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  /// 타임라인 아이템
  static Widget buildTimelineItem({
    required String time,
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 12,
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.pointBlue).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: iconColor ?? AppColors.pointBlue,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor ?? AppColors.pointBlue,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 12,
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 거리 표시 위젯
  static Widget buildDistanceDisplay(double? distanceKm) {
    if (distanceKm == null) {
      return const Text(
        '--km',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.pointGray,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: distanceKm.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const TextSpan(
            text: 'km',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.pointGray,
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 표시 위젯
  static Widget buildDurationDisplay(Duration? duration) {
    if (duration == null) {
      return const Text(
        '--:--',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.pointGray,
        ),
      );
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return RichText(
      text: TextSpan(
        children: [
          if (hours > 0) ...[
            TextSpan(
              text: hours.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const TextSpan(
              text: 'h ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.pointGray,
              ),
            ),
          ],
          TextSpan(
            text: minutes.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const TextSpan(
            text: 'm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.pointGray,
            ),
          ),
        ],
      ),
    );
  }
}
