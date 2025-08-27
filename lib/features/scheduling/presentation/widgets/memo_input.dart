import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 메모 입력 위젯
class MemoInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;

  const MemoInput({
    super.key,
    required this.controller,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'メモ',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '特記事項があれば入力してください',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: maxLines,
            ),
          ],
        ),
      ),
    );
  }
}