import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Pet Registration Text Field State Provider
final petRegistrationTextFieldProvider =
    StateNotifierProvider.family<
      PetRegistrationTextFieldController,
      PetRegistrationTextFieldState,
      String
    >((ref, fieldId) => PetRegistrationTextFieldController());

class PetRegistrationTextFieldController
    extends StateNotifier<PetRegistrationTextFieldState> {
  PetRegistrationTextFieldController()
    : super(const PetRegistrationTextFieldState());

  void setError(String? error) {
    state = state.copyWith(currentError: error);
  }

  void setInteracted(bool hasInteracted) {
    state = state.copyWith(hasInteracted: hasInteracted);
  }

  void validateInput(
    String text, {
    bool isRequired = false,
    int? minLength,
    int? maxLength,
    String? label,
    Function(String?)? validator,
  }) {
    String? error;

    // 커스텀 검증 우선
    if (validator != null) {
      error = validator(text.isEmpty ? null : text);
    } else {
      // 기본 검증 로직
      if (isRequired && text.trim().isEmpty) {
        error = '${label ?? 'この項目'}を入力してください';
      } else if (text.isNotEmpty) {
        if (minLength != null && text.length < minLength) {
          error = '${label ?? 'この項目'}は$minLength文字以上で入力してください';
        } else if (maxLength != null && text.length > maxLength) {
          error = '${label ?? 'この項目'}は$maxLength文字以内で入力してください';
        }
      }
    }

    setError(error);
  }
}

class PetRegistrationTextFieldState {
  final String? currentError;
  final bool hasInteracted;

  const PetRegistrationTextFieldState({
    this.currentError,
    this.hasInteracted = false,
  });

  PetRegistrationTextFieldState copyWith({
    String? currentError,
    bool? hasInteracted,
  }) {
    return PetRegistrationTextFieldState(
      currentError: currentError ?? this.currentError,
      hasInteracted: hasInteracted ?? this.hasInteracted,
    );
  }

  bool get isValid => currentError == null;
}

/// 펫 등록용 공통 텍스트 필드 위젯
/// 일관된 스타일과 검증 로직 제공
class PetRegistrationTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return _PetRegistrationTextFieldContent(
      controller: controller,
      label: label,
      hintText: hintText,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      isRequired: isRequired,
      minLength: minLength,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      enabled: enabled,
      textAlign: textAlign,
      maxLines: maxLines,
      errorText: errorText,
      focusNode: focusNode,
    );
  }
}

class _PetRegistrationTextFieldContent extends ConsumerStatefulWidget {
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

  const _PetRegistrationTextFieldContent({
    required this.controller,
    required this.label,
    this.hintText,
    this.semanticLabel,
    this.semanticHint,
    required this.isRequired,
    this.minLength,
    this.maxLength,
    required this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    required this.obscureText,
    required this.enabled,
    required this.textAlign,
    this.maxLines,
    this.errorText,
    this.focusNode,
  });

  @override
  ConsumerState<_PetRegistrationTextFieldContent> createState() =>
      _PetRegistrationTextFieldContentState();
}

class _PetRegistrationTextFieldContentState
    extends ConsumerState<_PetRegistrationTextFieldContent> {
  final String _fieldId = DateTime.now().millisecondsSinceEpoch.toString();

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
    final fieldState = ref.read(petRegistrationTextFieldProvider(_fieldId));

    if (!fieldState.hasInteracted && widget.controller.text.isNotEmpty) {
      ref
          .read(petRegistrationTextFieldProvider(_fieldId).notifier)
          .setInteracted(true);
    }

    if (fieldState.hasInteracted || widget.controller.text.isNotEmpty) {
      _validateInput();
    }

    widget.onChanged?.call(widget.controller.text);
  }

  void _validateInput() {
    ref
        .read(petRegistrationTextFieldProvider(_fieldId).notifier)
        .validateInput(
          widget.controller.text,
          isRequired: widget.isRequired,
          minLength: widget.minLength,
          maxLength: widget.maxLength,
          label: widget.label,
          validator: widget.validator,
        );
  }

  InputDecoration _buildDecoration() {
    final fieldState = ref.watch(petRegistrationTextFieldProvider(_fieldId));
    final hasError =
        fieldState.currentError != null || widget.errorText != null;
    final errorMessage = widget.errorText ?? fieldState.currentError;

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

      contentPadding: const const const EdgeInsets.symmetric(
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
      errorStyle: AppFonts.bodySmall.copyWith(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel = widget.semanticLabel ?? '${widget.label}入力フィールド';
    final semanticHint =
        widget.semanticHint ??
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
              final fieldState = ref.read(
                petRegistrationTextFieldProvider(_fieldId),
              );
              if (!fieldState.hasInteracted) {
                ref
                    .read(petRegistrationTextFieldProvider(_fieldId).notifier)
                    .setInteracted(true);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 현재 검증 상태 확인
  bool get isValid {
    final fieldState = ref.read(petRegistrationTextFieldProvider(_fieldId));
    return fieldState.currentError == null && widget.errorText == null;
  }

  /// 에러 메시지 가져오기
  String? get currentError {
    final fieldState = ref.read(petRegistrationTextFieldProvider(_fieldId));
    return widget.errorText ?? fieldState.currentError;
  }
}
