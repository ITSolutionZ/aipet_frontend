import 'package:flutter/material.dart';
import '../../../../../shared/shared.dart';

class MicrochipInput extends StatelessWidget {
  final TextEditingController controller;
  final Function() onChanged;

  const MicrochipInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'マイクロチップ番号 (任意)',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller,
            maxLength: 15,
            keyboardType: TextInputType.number,
            style: AppFonts.bodyMedium,
            decoration: InputDecoration(
              hintText: '例: 392142000000000',
              hintStyle: AppFonts.bodyMedium.copyWith(
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(
                  color: AppColors.pointPink,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              counterText: '',
            ),
            onChanged: (value) {
              final filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (filtered != value) {
                controller.value = TextEditingValue(
                  text: filtered,
                  selection: TextSelection.collapsed(offset: filtered.length),
                );
              }
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '※ 15桁の数字を入力してください',
            style: AppFonts.bodySmall.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}