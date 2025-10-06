import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/layout/card.dart';
import 'package:flutter/material.dart';

/// 범용 정보 카드 컴포넌트
/// 다양한 정보를 표시할 수 있는 유연한 카드 위젯
class GenericInfoCard extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool showChevron;

  const GenericInfoCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.badgeColor,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.showChevron = false,
  });

  /// 아바타가 있는 카드 (프로필 이미지 등)
  GenericInfoCard.withAvatar({
    super.key,
    required String? avatarUrl,
    String? placeholderAsset,
    IconData placeholderIcon = Icons.person,
    this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.badgeColor,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.showChevron = false,
  }) : leading = _buildAvatar(
         avatarUrl: avatarUrl,
         placeholderAsset: placeholderAsset,
         placeholderIcon: placeholderIcon,
       );

  /// 아이콘이 있는 카드
  GenericInfoCard.withIcon({
    super.key,
    required IconData icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.badgeColor,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.showChevron = false,
  }) : leading = _buildIcon(
         icon: icon,
         iconColor: iconColor,
         backgroundColor: iconBackgroundColor,
       );

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.pointDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.pointBlue)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: AppFonts.bodySmall.copyWith(
                              color: badgeColor ?? AppColors.pointBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
          if (showChevron && onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right,
              color: AppColors.pointGray,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  /// 아바타 위젯 생성 헬퍼
  static Widget _buildAvatar({
    required String? avatarUrl,
    String? placeholderAsset,
    IconData placeholderIcon = Icons.person,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: avatarUrl != null
            ? Image.asset(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarPlaceholder(placeholderIcon, size);
                },
              )
            : placeholderAsset != null
            ? Image.asset(
                placeholderAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarPlaceholder(placeholderIcon, size);
                },
              )
            : _buildAvatarPlaceholder(placeholderIcon, size),
      ),
    );
  }

  /// 아바타 플레이스홀더 생성
  static Widget _buildAvatarPlaceholder(IconData icon, double size) {
    return Container(
      color: Colors.grey[300],
      child: Icon(icon, color: Colors.grey[600], size: size * 0.5),
    );
  }

  /// 아이콘 위젯 생성 헬퍼
  static Widget _buildIcon({
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (iconColor ?? AppColors.pointBlue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        icon,
        color: iconColor ?? AppColors.pointBlue,
        size: size * 0.5,
      ),
    );
  }
}
