import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared.dart';

/// 범용 텍스트 필드 위젯
/// 일관된 스타일과 검증 로직 제공
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isRequired;
  final int? minLength;
  final int? maxLength;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextAlign textAlign;
  final int? maxLines;
  final String? errorText;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.semanticLabel,
    this.semanticHint,
    this.isRequired = false,
    this.minLength,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.errorText,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      hint: widget.semanticHint ?? widget.hintText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          if (widget.label.isNotEmpty) ...[
            RichText(
              text: TextSpan(
                text: widget.label,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
                children: widget.isRequired
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],

          // 텍스트 필드
          Container(
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.pureWhite
                  : AppColors.pointGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: widget.errorText != null
                    ? Colors.red
                    : _focusNode.hasFocus
                    ? AppColors.pointBrown
                    : AppColors.pointGray.withValues(alpha: 0.3),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: AppColors.pointGray.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              style: AppFonts.bodyMedium.copyWith(
                color: widget.enabled
                    ? AppColors.pointDark
                    : AppColors.pointGray,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointGray.withValues(alpha: 0.6),
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                counterText: '',
              ),
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
                setState(() {}); // 검증 상태 업데이트
              },
            ),
          ),

          // 에러 메시지
          if (widget.errorText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.errorText!,
              style: AppFonts.bodySmall.copyWith(color: Colors.red),
            ),
          ],

          // 문자 수 표시
          if (widget.maxLength != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.controller.text.length}/${widget.maxLength}',
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
