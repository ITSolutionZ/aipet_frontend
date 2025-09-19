import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 공통 요약 카드 위젯
///
/// 모든 feature에서 공통으로 사용되는 요약 카드 패턴을 제공합니다.
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
    this.isLoading = false,
    this.errorMessage,
  });

  final IconData icon;
  final Color iconColor;
  final String mainValue;
  final String unit;
  final VoidCallback? onTap;
  final String? subtitle;
  final String? secondaryValue;
  final bool isLoading;
  final String? errorMessage;

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
          children: [
            // 아이콘
            _buildIcon(),
            const SizedBox(height: AppSpacing.xs),

            // 메인 값
            _buildMainValue(),

            // 서브타이틀
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _buildSubtitle(),
            ],

            // 보조 값
            if (secondaryValue != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _buildSecondaryValue(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }

    if (errorMessage != null) {
      return const Icon(
        Icons.error_outline,
        color: AppColors.pointPink,
        size: 24,
      );
    }

    return Icon(icon, color: iconColor, size: 24);
  }

  Widget _buildMainValue() {
    if (isLoading) {
      return Container(
        width: 60,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    if (errorMessage != null) {
      return Text(
        '--',
        style: AppFonts.titleMedium.copyWith(
          color: AppColors.pointPink,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: mainValue,
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    if (isLoading) {
      return Container(
        width: 80,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Text(
      subtitle!,
      style: AppFonts.bodySmall.copyWith(
        color: AppColors.pointDark.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSecondaryValue() {
    if (isLoading) {
      return Container(
        width: 60,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Text(
      secondaryValue!,
      style: AppFonts.bodySmall.copyWith(
        color: AppColors.pointBrown,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 통계 카드 위젯
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.onTap,
    this.isLoading = false,
    this.errorMessage,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Widget? trend;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              title,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // 값과 트렌드
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildValue()),
                if (trend != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trend!,
                ],
              ],
            ),

            // 서브타이틀
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValue() {
    if (isLoading) {
      return Container(
        width: 80,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.pointOffWhite.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    if (errorMessage != null) {
      return Text(
        '--',
        style: AppFonts.titleLarge.copyWith(
          color: AppColors.pointPink,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      value,
      style: AppFonts.titleLarge.copyWith(
        color: AppColors.pointDark,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 액션 카드 위젯
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.pureWhite : AppColors.pointOffWhite,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isEnabled
                ? AppColors.pointOffWhite.withValues(alpha: 0.3)
                : AppColors.pointOffWhite.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.pointBrown.withValues(alpha: 0.1)
                    : AppColors.pointOffWhite.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isEnabled
                              ? AppColors.pointBrown
                              : AppColors.pointOffWhite,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: isEnabled
                          ? AppColors.pointBrown
                          : AppColors.pointOffWhite,
                      size: 20,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyMedium.copyWith(
                      color: isEnabled
                          ? AppColors.pointDark
                          : AppColors.pointOffWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppFonts.bodySmall.copyWith(
                      color: isEnabled
                          ? AppColors.pointDark.withValues(alpha: 0.7)
                          : AppColors.pointOffWhite,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 화살표
            if (isEnabled && !isLoading)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.pointOffWhite,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
