import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

class ProfileEditButtons extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ProfileEditButtons({
    super.key,
    required this.isEditMode,
    this.onEdit,
    this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // キャンセルボタン
          Expanded(
            child: ActionButton.outlined(
              isEnabled: !isLoading,
              onPressed: onCancel,
              text: 'キャンセル',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 保存ボタン
          Expanded(
            child: ActionButton.primary(
              isEnabled: !isLoading,
              onPressed: onSave,
              text: '保存',
              isLoading: isLoading,
            ),
          ),
        ],
      );
    } else {
      return ActionButton.primary(
        isEnabled: true,
        onPressed: onEdit,
        text: '編集',
        icon: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 20,
        ),
      );
    }
  }
}