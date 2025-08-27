import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      // 텍스트가 있는 구분선 (예: "または")
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              text!,
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
          ),
        ],
      );
    } else {
      // 단순한 구분선
      return Container(
        height: 1,
        width: double.infinity,
        color: AppColors.pointGray.withValues(alpha: 0.3),
      );
    }
  }
}
