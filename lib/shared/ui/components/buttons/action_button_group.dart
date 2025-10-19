import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 🔘 액션 버튼 그룹
///
/// 편집 모드와 일반 모드에서 공통으로 사용되는 버튼 패턴
class ActionButtonGroup extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final String? secondaryLabel;
  final String editPrimaryLabel;
  final String? editSecondaryLabel;
  final bool isEnabled;
  final Color? primaryColor;
  final Color? secondaryColor;

  const ActionButtonGroup({
    super.key,
    required this.isEditMode,
    required this.onPrimary,
    required this.primaryLabel,
    required this.editPrimaryLabel,
    this.onSecondary,
    this.secondaryLabel,
    this.editSecondaryLabel,
    this.isEnabled = true,
    this.primaryColor,
    this.secondaryColor,
  });

  /// 편집 모드 버튼 그룹 팩토리
  factory ActionButtonGroup.edit({
    required VoidCallback onSave,
    required VoidCallback onCancel,
    String saveLabel = '保存',
    String cancelLabel = 'キャンセル',
    bool isEnabled = true,
    Color? saveColor,
  }) {
    return ActionButtonGroup(
      isEditMode: true,
      onPrimary: onSave,
      onSecondary: onCancel,
      primaryLabel: '',
      editPrimaryLabel: saveLabel,
      editSecondaryLabel: cancelLabel,
      isEnabled: isEnabled,
      primaryColor: saveColor,
    );
  }

  /// 일반/편집 토글 버튼 그룹 팩토리
  factory ActionButtonGroup.toggle({
    required bool isEditMode,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    VoidCallback? onCancel,
    String editLabel = '編集',
    String saveLabel = '保存',
    String cancelLabel = 'キャンセル',
    bool isEnabled = true,
  }) {
    return ActionButtonGroup(
      isEditMode: isEditMode,
      onPrimary: isEditMode ? onSave : onEdit,
      onSecondary: isEditMode ? onCancel : null,
      primaryLabel: editLabel,
      editPrimaryLabel: saveLabel,
      editSecondaryLabel: cancelLabel,
      isEnabled: isEnabled,
    );
  }

  /// 확인/취소 버튼 그룹 팩토리
  factory ActionButtonGroup.confirm({
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    String confirmLabel = '確認',
    String cancelLabel = 'キャンセル',
    bool isEnabled = true,
    Color? confirmColor,
  }) {
    return ActionButtonGroup(
      isEditMode: false,
      onPrimary: onConfirm,
      onSecondary: onCancel,
      primaryLabel: confirmLabel,
      editPrimaryLabel: confirmLabel,
      secondaryLabel: cancelLabel,
      isEnabled: isEnabled,
      primaryColor: confirmColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_shouldShowSecondaryButton) ...[
          Expanded(child: _buildSecondaryButton()),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(child: _buildPrimaryButton()),
      ],
    );
  }

  bool get _shouldShowSecondaryButton {
    if (isEditMode) {
      return onSecondary != null && editSecondaryLabel != null;
    }
    return onSecondary != null && secondaryLabel != null;
  }

  Widget _buildPrimaryButton() {
    final label = isEditMode ? editPrimaryLabel : primaryLabel;
    final color = primaryColor ?? AppColors.pointBrown;

    return ElevatedButton(
      onPressed: isEnabled ? onPrimary : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSecondaryButton() {
    final label = isEditMode
        ? (editSecondaryLabel ?? '')
        : (secondaryLabel ?? '');
    final color = secondaryColor ?? AppColors.pointGray;

    return OutlinedButton(
      onPressed: isEnabled ? onSecondary : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
