import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import '../auth_logo.dart';


/// ログインロゴセクション
///
/// ログイン画面のロゴとアプリ名を表示
class LoginLogoSection extends StatelessWidget {
  final double logoSize;
  final double verticalSpacing;

  const LoginLogoSection({
    super.key,
    this.logoSize = 120.0,
    this.verticalSpacing = AppSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: verticalSpacing),
        AuthLogo(width: logoSize, height: logoSize),
        const SizedBox(height: AppSpacing.md),
        // アプリ名
        Text(
          'AIPET',
          style: AppFonts.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'ITSOLUTIONZ',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointBrown.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
