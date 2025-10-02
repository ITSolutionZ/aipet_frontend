import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Common Input Field State Provider
final commonInputFieldStateProvider =
    StateNotifierProvider.family<CommonInputFieldController, CommonInputFieldState, String>(
      (ref, fieldId) => CommonInputFieldController(),
    );

class CommonInputFieldController extends StateNotifier<CommonInputFieldState> {
  CommonInputFieldController() : super(const CommonInputFieldState());

  void setFocus(bool hasFocus) {
    state = state.copyWith(isFocused: hasFocus);
  }

  void toggleObscureText() {
    state = state.copyWith(obscureText: !state.obscureText);
  }

  void setObscureText(bool obscureText) {
    state = state.copyWith(obscureText: obscureText);
  }
}

class CommonInputFieldState {
  final bool isFocused;
  final bool obscureText;

  const CommonInputFieldState({this.isFocused = false, this.obscureText = false});

  CommonInputFieldState copyWith({bool? isFocused, bool? obscureText}) {
    return CommonInputFieldState(
      isFocused: isFocused ?? this.isFocused,
      obscureText: obscureText ?? this.obscureText,
    );
  }
}

/// 공통 입력 필드 위젯
///
/// 모든 feature에서 공통으로 사용되는 입력 필드 패턴을 제공합니다.
class CommonInputField extends ConsumerStatefulWidget {
  /// 필드 라벨
  final String label;

  /// 힌트 텍스트
  final String? hint;

  /// 초기값
  final String? initialValue;

  /// 컨트롤러
  final TextEditingController? controller;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 입력 타입
  final TextInputType? keyboardType;

  /// 입력 포맷터
  final List<TextInputFormatter>? inputFormatters;

  /// 유효성 검사 함수
  final String? Function(String?)? validator;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 포커스 변경 콜백
  final ValueChanged<bool>? onFocusChange;

  /// 제출 콜백
  final ValueChanged<String>? onSubmitted;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 비활성화 여부
  final bool enabled;

  /// 비밀번호 필드 여부
  final bool obscureText;

  /// 최대 라인 수
  final int? maxLines;

  /// 최대 길이
  final int? maxLength;

  /// 접두사 아이콘
  final IconData? prefixIcon;

  /// 접미사 아이콘
  final IconData? suffixIcon;

  /// 접미사 아이콘 클릭 콜백
  final VoidCallback? onSuffixIconTap;

  /// 에러 메시지
  final String? errorText;

  /// 도움말 텍스트
  final String? helpText;

  /// 필수 필드 여부
  final bool required;

  /// 자동 포커스 여부
  final bool autofocus;

  /// 텍스트 정렬
  final TextAlign textAlign;

  /// 필드 ID (Riverpod 상태 관리용)
  final String? fieldId;

  const CommonInputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFocusChange,
    this.onSubmitted,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.errorText,
    this.helpText,
    this.required = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.fieldId,
  });

  @override
  ConsumerState<CommonInputField> createState() => _CommonInputFieldState();
}

class _CommonInputFieldState extends ConsumerState<CommonInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);

    // Initialize Riverpod state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fieldId != null) {
        ref
            .read(commonInputFieldStateProvider(widget.fieldId!).notifier)
            .setObscureText(widget.obscureText);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (widget.fieldId != null) {
      ref.read(commonInputFieldStateProvider(widget.fieldId!).notifier).setFocus(hasFocus);
    }
    widget.onFocusChange?.call(hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFieldId = widget.fieldId ?? 'default_common_input_field';
    final fieldState = ref.watch(commonInputFieldStateProvider(effectiveFieldId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        _buildLabel(),

        const SizedBox(height: AppSpacing.xs),

        // 입력 필드
        _buildInputField(fieldState),

        // 에러 메시지 또는 도움말
        if (widget.errorText != null || widget.helpText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _buildHelperText(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          widget.label,
          style: AppFonts.bodyMedium.copyWith(
            color: widget.enabled ? AppColors.pointDark : AppColors.pointOffWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.required) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '*',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointPink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(CommonInputFieldState fieldState) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: fieldState.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      textAlign: widget.textAlign,
      style: AppFonts.bodyMedium.copyWith(
        color: widget.enabled ? AppColors.pointDark : AppColors.pointOffWhite,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppFonts.bodyMedium.copyWith(
          color: AppColors.pointOffWhite.withValues(alpha: 0.6),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: fieldState.isFocused
                    ? AppColors.pointBrown
                    : AppColors.pointOffWhite.withValues(alpha: 0.6),
                size: 20,
              )
            : null,
        suffixIcon: _buildSuffixIcon(fieldState),
        filled: true,
        fillColor: widget.enabled
            ? AppColors.pointOffWhite.withValues(alpha: 0.1)
            : AppColors.pointOffWhite.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(
            color: widget.errorText != null
                ? AppColors.pointPink
                : AppColors.pointOffWhite.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: AppColors.pointOffWhite.withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.pointBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.pointPink, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.pointPink, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: AppColors.pointOffWhite.withValues(alpha: 0.1), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        counterText: '', // maxLength 카운터 숨기기
      ),
    );
  }

  Widget? _buildSuffixIcon(CommonInputFieldState fieldState) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          fieldState.obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.pointOffWhite.withValues(alpha: 0.6),
          size: 20,
        ),
        onPressed: () {
          if (widget.fieldId != null) {
            ref.read(commonInputFieldStateProvider(widget.fieldId!).notifier).toggleObscureText();
          }
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.pointOffWhite.withValues(alpha: 0.6),
          size: 20,
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }

  Widget _buildHelperText() {
    if (widget.errorText != null) {
      return Text(
        widget.errorText!,
        style: AppFonts.bodySmall.copyWith(color: AppColors.pointPink),
      );
    }

    if (widget.helpText != null) {
      return Text(
        widget.helpText!,
        style: AppFonts.bodySmall.copyWith(color: AppColors.pointOffWhite.withValues(alpha: 0.7)),
      );
    }

    return const SizedBox.shrink();
  }
}
