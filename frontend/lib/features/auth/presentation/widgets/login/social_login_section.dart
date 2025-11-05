import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';


import '../../../../../shared/shared.dart';
import '../../../../../app/router/app_router.dart';
import '../auth_divider.dart';
import '../social_login_button.dart';


/// ソーシャルログインセクション
///
/// Google/Apple/LINE ログインボタンと新規登録リンクを表示
class SocialLoginSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;
  final VoidCallback onLineLogin;

  const SocialLoginSection({
    super.key,
    required this.isLoading,
    required this.onGoogleLogin,
    required this.onAppleLogin,
    required this.onLineLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 区切り線
        const AuthDivider(text: 'または'),
        const SizedBox(height: AppSpacing.md),

        // Google ログインボタン
        SocialLoginButton(
          onPressed: isLoading ? null : onGoogleLogin,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login),
              SizedBox(width: AppSpacing.sm),
              Text('Googleでログイン'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Apple ログインボタン
        SocialLoginButton(
          onPressed: isLoading ? null : onAppleLogin,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple),
              SizedBox(width: AppSpacing.sm),
              Text('Appleでログイン'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // LINE ログインボタン
        SocialLoginButton(
          onPressed: isLoading ? null : onLineLogin,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat),
              SizedBox(width: AppSpacing.sm),
              Text('LINEでログイン'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 新規登録リンク
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'アカウントをお持ちでない方は',
              style: AppFonts.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.go(AppRouter.signupRoute);
                    },
              child: Text(
                '新規登録',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
