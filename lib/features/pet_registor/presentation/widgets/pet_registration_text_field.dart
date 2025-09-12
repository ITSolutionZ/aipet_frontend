import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/shared.dart';

/// 펫 등록용 공통 텍스트 필드 위젯
/// 일관된 스타일과 검증 로직 제공
class PetRegistrationTextField extends StatefulWidget {
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

  const PetRegistrationTextField({
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
  State<PetRegistrationTextField> createState() =>
      _PetRegistrationTextFieldState();
}

class _PetRegistrationTextFieldState extends State<PetRegistrationTextField> {
  String? _currentError;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasInteracted && widget.controller.text.isNotEmpty) {
      setState(() {
        _hasInteracted = true;
      });
    }

    if (_hasInteracted || widget.controller.text.isNotEmpty) {
      _validateInput();
    }

    widget.onChanged?.call(widget.controller.text);
  }

  void _validateInput() {
    String? error;
    final text = widget.controller.text;

    // 커스텀 검증 우선
    if (widget.validator != null) {
      error = widget.validator!(text.isEmpty ? null : text);
    } else {
      // 기본 검증 로직
      if (widget.isRequired && text.trim().isEmpty) {
        error = '${widget.label}を入力してください';
      } else if (text.isNotEmpty) {
        if (widget.minLength != null && text.length < widget.minLength!) {
          error = '${widget.label}は${widget.minLength}文字以上で入力してください';
        } else if (widget.maxLength != null && text.length > widget.maxLength!) {
          error = '${widget.label}は${widget.maxLength}文字以内で入力してください';
        }
      }
    }

    if (_currentError != error) {
      setState(() {
        _currentError = error;
      });
    }
  }

  InputDecoration _buildDecoration() {
    final hasError = _currentError != null || widget.errorText != null;
    final errorMessage = widget.errorText ?? _currentError;

    return InputDecoration(
      labelText: widget.isRequired ? '${widget.label} *' : widget.label,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      errorText: hasError ? errorMessage : null,
      filled: true,
      fillColor: widget.enabled 
          ? AppColors.pureWhite 
          : AppColors.pointGray.withValues(alpha: 0.1),
      
      // 기본 테두리
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      
      // 활성화 상태 테두리
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: hasError 
              ? Colors.red.withValues(alpha: 0.5)
              : AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      
      // 포커스 상태 테두리
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: hasError ? Colors.red : AppColors.pointBrown,
          width: 2,
        ),
      ),
      
      // 에러 상태 테두리
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      
      // 비활성화 상태 테두리
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.pointGray.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      
      // 라벨 스타일
      labelStyle: AppFonts.bodyMedium.copyWith(
        color: hasError 
            ? Colors.red 
            : AppColors.pointDark.withValues(alpha: 0.7),
      ),
      
      // 힌트 스타일
      hintStyle: AppFonts.bodyMedium.copyWith(
        color: AppColors.pointGray.withValues(alpha: 0.6),
      ),
      
      // 에러 스타일
      errorStyle: AppFonts.bodySmall.copyWith(
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel = widget.semanticLabel ?? '${widget.label}入力フィールド';
    final semanticHint = widget.semanticHint ?? 
        '${widget.isRequired ? "必須項目です。" : ""}${widget.minLength != null ? "${widget.minLength}文字以上、" : ""}${widget.maxLength != null ? "${widget.maxLength}文字以内で入力してください。" : ""}';

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            style: AppFonts.bodyMedium.copyWith(
              color: widget.enabled ? AppColors.pointDark : AppColors.pointGray,
            ),
            decoration: _buildDecoration(),
            onTap: () {
              if (!_hasInteracted) {
                setState(() {
                  _hasInteracted = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  /// 현재 검증 상태 확인
  bool get isValid => _currentError == null && widget.errorText == null;
  
  /// 에러 메시지 가져오기
  String? get currentError => widget.errorText ?? _currentError;
}