import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 식사 내용 입력 위젯
class MealContentInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const MealContentInput({
    super.key,
    required this.controller,
    this.validator,
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
              '食事内容',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '例: ドッグフード、鶏肉など',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}