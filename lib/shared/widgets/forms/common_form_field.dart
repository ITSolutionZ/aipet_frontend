import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 공통 폼 필드 위젯
///
/// 모든 feature에서 공통으로 사용되는 폼 필드 패턴을 제공합니다.
class CommonFormField extends StatelessWidget {
  const CommonFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onTap,
    this.decoration,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // 입력 필드
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          decoration: _buildDecoration(),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration() {
    final baseDecoration = InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: '', // maxLength 카운터 숨기기
      filled: true,
      fillColor: enabled ? AppColors.pureWhite : AppColors.pointOffWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.pointOffWhite.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.pointOffWhite.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.pointBrown, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.pointPink, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.pointPink, width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.pointOffWhite.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );

    // 커스텀 데코레이션이 있으면 병합
    if (decoration != null) {
      return baseDecoration.copyWith(
        hintText: decoration!.hintText ?? baseDecoration.hintText,
        prefixIcon: decoration!.prefixIcon ?? baseDecoration.prefixIcon,
        suffixIcon: decoration!.suffixIcon ?? baseDecoration.suffixIcon,
        errorText: decoration!.errorText,
        helperText: decoration!.helperText,
      );
    }

    return baseDecoration;
  }
}

/// 🎯 Password Visibility State Provider
final passwordVisibilityProvider =
    StateNotifierProvider.family<PasswordVisibilityController, bool, String>(
      (ref, fieldId) => PasswordVisibilityController(),
    );

class PasswordVisibilityController extends StateNotifier<bool> {
  PasswordVisibilityController() : super(true); // Initially obscured

  void toggle() {
    state = !state;
  }
}

/// 비밀번호 입력 필드
class PasswordFormField extends ConsumerWidget {
  const PasswordFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.fieldId,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final String? fieldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveFieldId = fieldId ?? 'default_password_field';
    final obscureText = ref.watch(passwordVisibilityProvider(effectiveFieldId));

    return CommonFormField(
      label: label,
      hint: hint,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.pointDark.withValues(alpha: 0.6),
        ),
        onPressed: () {
          ref
              .read(passwordVisibilityProvider(effectiveFieldId).notifier)
              .toggle();
        },
      ),
    );
  }
}

/// 이메일 입력 필드
class EmailFormField extends StatelessWidget {
  const EmailFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CommonFormField(
      label: label,
      hint: hint ?? 'メールアドレスを入力してください',
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.pointBrown),
    );
  }
}

/// 사용자명 입력 필드
class UsernameFormField extends StatelessWidget {
  const UsernameFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CommonFormField(
      label: label,
      hint: hint ?? 'ユーザー名を入力してください',
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.person_outline, color: AppColors.pointBrown),
    );
  }
}
