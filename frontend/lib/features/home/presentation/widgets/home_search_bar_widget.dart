import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 홈 화면용 검색바 위젯
class HomeSearchBarWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const HomeSearchBarWidget({
    super.key,
    this.hintText = '検索ワードを入力してください',
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointBrown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: true, // 直接入力を無効化
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.pointGray, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: AppColors.pointGray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
