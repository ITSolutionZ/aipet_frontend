import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 저장 버튼 위젯 (ActionButton으로 대체됨)
@Deprecated('Use ActionButton.primary instead')
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.text = '保存',
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton.primary(
      text: text,
      onPressed: isLoading ? null : onPressed,
      isLoading: isLoading,
      isEnabled: !isLoading,
    );
  }
}
