import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

enum SocialLoginType { email, google, apple, line }

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.pointDark,
          side: BorderSide(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.pointBrown,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _getText(),
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case SocialLoginType.email:
        return const Icon(Icons.email_outlined, size: 20, color: AppColors.pointDark);
      case SocialLoginType.google:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://developers.google.com/identity/images/g-logo.png',
              ),
              fit: BoxFit.contain,
            ),
          ),
        );
      case SocialLoginType.apple:
        return const Icon(Icons.apple, size: 20, color: AppColors.pointDark);
      case SocialLoginType.line:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF00C300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'LINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    }
  }

  String _getText() {
    switch (type) {
      case SocialLoginType.email:
        return 'Signup with E-Mail';
      case SocialLoginType.google:
        return 'Signup with Google';
      case SocialLoginType.apple:
        return 'Signup with apple account';
      case SocialLoginType.line:
        return 'Signup with LINE';
    }
  }
}
