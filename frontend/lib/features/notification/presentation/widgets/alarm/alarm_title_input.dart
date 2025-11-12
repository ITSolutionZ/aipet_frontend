import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// アラームタイトル入力ウィジェット
///
/// アラームのタイトルを入力するフィールド
class AlarmTitleInput extends StatelessWidget {
  final TextEditingController controller;

  const AlarmTitleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'アラームのタイトルを入力',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.label_outline, color: AppColors.pointPink),
          counterText: '', // カウンター非表示
        ),
        style: AppFonts.bodyLarge,
        maxLength: 50,
      ),
    );
  }
}
