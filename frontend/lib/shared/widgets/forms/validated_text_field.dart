import 'package:aipet_frontend/shared/validation/input_validation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/shared.dart';

/// 🛡️ 보안 강화된 텍스트 필드 위젯
///
/// 모든 사용자 입력에 대해 자동으로 보안 검증을 수행하는 TextFormField 래퍼입니다.
/// XSS, SQL Injection, 명령어 실행 등 다양한 보안 위협을 차단합니다.
class ValidatedTextField extends StatefulWidget {
  /// 필드 이름 (에러 메시지용)
  final String fieldName;

  /// 컨트롤러
  final TextEditingController? controller;

  /// 힌트 텍스트
  final String? hintText;

  /// 라벨 텍스트
  final String? labelText;

  /// 최대 길이
  final int? maxLength;

  /// HTML 태그 허용 여부
  final bool allowHtml;

  /// 특수문자 허용 여부
  final bool allowSpecialChars;

  /// 필수 입력 여부
  final bool isRequired;

  /// 키보드 타입
  final TextInputType? keyboardType;

  /// 입력 포맷터
  final List<TextInputFormatter>? inputFormatters;

  /// 접두사 아이콘
  final Widget? prefixIcon;

  /// 접미사 아이콘
  final Widget? suffixIcon;

  /// 비밀번호 필드 여부
  final bool obscureText;

  /// 활성화 여부
  final bool enabled;

  /// 최대 라인 수
  final int? maxLines;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백
  final ValueChanged<String>? onSubmitted;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 텍스트 스타일
  final TextStyle? style;

  /// 커스텀 검증 로직
  final String? Function(String?)? customValidator;

  /// 실시간 검증 여부 (입력 중 즉시 검증)
  final bool realtimeValidation;

  /// 보안 위협 감지 시 콜백
  final VoidCallback? onSecurityThreatDetected;

  const ValidatedTextField({
    super.key,
    required this.fieldName,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.allowHtml = false,
    this.allowSpecialChars = true,
    this.isRequired = true,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.style,
    this.customValidator,
    this.realtimeValidation = false,
    this.onSecurityThreatDetected,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  String? _errorText;
  bool _hasSecurityThreat = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    if (widget.realtimeValidation) {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else if (widget.realtimeValidation) {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.realtimeValidation) {
      final result = _validateInput(_controller.text);
      setState(() {
        _errorText = result.isSuccess ? null : result.message;
        _hasSecurityThreat = !result.isSuccess;
      });

      if (!result.isSuccess && widget.onSecurityThreatDetected != null) {
        widget.onSecurityThreatDetected!();
      }
    }
  }

  Result<String> _validateInput(String? input) {
    // 커스텀 검증이 있으면 먼저 수행
    if (widget.customValidator != null) {
      final customError = widget.customValidator!(input);
      if (customError != null) {
        return Result.failure(customError);
      }
    }

    // 보안 검증 수행
    return InputValidationService.validateUserInput(
      input,
      fieldName: widget.fieldName,
      maxLength: widget.maxLength,
      allowHtml: widget.allowHtml,
      allowSpecialChars: widget.allowSpecialChars,
      isRequired: widget.isRequired,
    );
  }

  String? _formValidator(String? value) {
    final result = _validateInput(value);

    if (!result.isSuccess) {
      setState(() {
        _hasSecurityThreat = true;
      });

      if (widget.onSecurityThreatDetected != null) {
        widget.onSecurityThreatDetected!();
      }

      return result.message;
    }

    setState(() {
      _hasSecurityThreat = false;
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: _buildInputFormatters(),
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          style: widget.style,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            border: _buildBorder(),
            enabledBorder: _buildBorder(),
            focusedBorder: _buildFocusedBorder(),
            errorBorder: _buildErrorBorder(),
            focusedErrorBorder: _buildErrorBorder(),
            filled: true,
            fillColor: _buildFillColor(),
            errorText: widget.realtimeValidation ? _errorText : null,
            counterText: widget.maxLength != null ? null : '',
            helperText: _buildHelperText(),
            helperStyle: TextStyle(
              color: _hasSecurityThreat ? Colors.red[600] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          validator: widget.realtimeValidation ? null : _formValidator,
          onChanged: (value) {
            if (widget.realtimeValidation) {
              _onTextChanged();
            }
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
        ),

        // 보안 위협 경고 표시
        if (_hasSecurityThreat && widget.realtimeValidation) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.red[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'セキュリティ上の問題が検出されました',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<TextInputFormatter>? _buildInputFormatters() {
    final formatters = <TextInputFormatter>[
      // 제어 문자 필터링
      FilteringTextInputFormatter.deny(
        RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      ),
    ];

    // 최대 길이 제한
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }

    // 특수문자 제한
    if (!widget.allowSpecialChars) {
      formatters.add(
        FilteringTextInputFormatter.deny(RegExp(r'[<>{}[\]\\|`~!@#$%^&*()+=]')),
      );
    }

    // HTML 태그 제한
    if (!widget.allowHtml) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'[<>]')));
    }

    // 커스텀 포맷터 추가
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    return formatters;
  }

  Widget? _buildSuffixIcon() {
    if (_hasSecurityThreat && widget.realtimeValidation) {
      return Icon(Icons.error, color: Colors.red[600]);
    }
    return widget.suffixIcon;
  }

  InputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: _hasSecurityThreat ? Colors.red : Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  InputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: _hasSecurityThreat ? Colors.red : Theme.of(context).primaryColor,
        width: 2,
      ),
    );
  }

  InputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    );
  }

  Color _buildFillColor() {
    if (!widget.enabled) {
      return Colors.grey[100]!;
    }
    if (_hasSecurityThreat) {
      return Colors.red[50]!;
    }
    return Colors.grey[50]!;
  }

  String? _buildHelperText() {
    if (_hasSecurityThreat && widget.realtimeValidation) {
      return null; // 에러 상태에서는 helper text 숨김
    }

    final constraints = <String>[];

    if (widget.maxLength != null) {
      constraints.add('${widget.maxLength}文字以内');
    }

    if (!widget.allowSpecialChars) {
      constraints.add('特殊文字不可');
    }

    if (!widget.allowHtml) {
      constraints.add('HTMLタグ不可');
    }

    return constraints.isNotEmpty ? constraints.join('、') : null;
  }
}

/// 이메일 전용 검증 텍스트 필드
class ValidatedEmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSecurityThreatDetected;

  const ValidatedEmailField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.enabled = true,
    this.onChanged,
    this.onSecurityThreatDetected,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      fieldName: 'メールアドレス',
      controller: controller,
      hintText: hintText ?? 'メールアドレスを入力してください',
      labelText: labelText,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      maxLength: 254,
      allowHtml: false,
      allowSpecialChars: true,
      prefixIcon: const Icon(Icons.email_outlined),
      customValidator: (value) {
        if (value != null && value.isNotEmpty) {
          final result = InputValidationService.validateEmailInput(value);
          return result.isSuccess ? null : result.message;
        }
        return null;
      },
      onChanged: onChanged,
      onSecurityThreatDetected: onSecurityThreatDetected,
      realtimeValidation: true,
    );
  }
}

/// 비밀번호 전용 검증 텍스트 필드
class ValidatedPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSecurityThreatDetected;

  const ValidatedPasswordField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.enabled = true,
    this.onChanged,
    this.onSecurityThreatDetected,
  });

  @override
  State<ValidatedPasswordField> createState() => _ValidatedPasswordFieldState();
}

class _ValidatedPasswordFieldState extends State<ValidatedPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      fieldName: 'パスワード',
      controller: widget.controller,
      hintText: widget.hintText ?? 'パスワードを入力してください',
      labelText: widget.labelText,
      enabled: widget.enabled,
      obscureText: _obscureText,
      maxLength: 128,
      allowHtml: false,
      allowSpecialChars: true,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      customValidator: (value) {
        if (value != null && value.isNotEmpty) {
          final result = InputValidationService.validatePasswordInput(value);
          return result.isSuccess ? null : result.message;
        }
        return null;
      },
      onChanged: widget.onChanged,
      onSecurityThreatDetected: widget.onSecurityThreatDetected,
      realtimeValidation: true,
    );
  }
}

/// 펫 이름 전용 검증 텍스트 필드
class ValidatedPetNameField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSecurityThreatDetected;

  const ValidatedPetNameField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.enabled = true,
    this.onChanged,
    this.onSecurityThreatDetected,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      fieldName: 'ペット名',
      controller: controller,
      hintText: hintText ?? 'ペットの名前を入力してください',
      labelText: labelText,
      enabled: enabled,
      maxLength: 50,
      allowHtml: false,
      allowSpecialChars: false,
      prefixIcon: const Icon(Icons.pets),
      customValidator: (value) {
        if (value != null && value.isNotEmpty) {
          final result = InputValidationService.validatePetNameInput(value);
          return result.isSuccess ? null : result.message;
        }
        return null;
      },
      onChanged: onChanged,
      onSecurityThreatDetected: onSecurityThreatDetected,
      realtimeValidation: true,
    );
  }
}

/// 검색어 전용 검증 텍스트 필드
class ValidatedSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSecurityThreatDetected;

  const ValidatedSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.onSecurityThreatDetected,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      fieldName: '検索キーワード',
      controller: controller,
      hintText: hintText ?? '検索キーワードを入力してください',
      enabled: enabled,
      isRequired: false,
      maxLength: 100,
      allowHtml: false,
      allowSpecialChars: true,
      prefixIcon: const Icon(Icons.search),
      keyboardType: TextInputType.text,
      customValidator: (value) {
        final result = InputValidationService.validateSearchInput(value);
        return result.isSuccess ? null : result.message;
      },
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSecurityThreatDetected: onSecurityThreatDetected,
      realtimeValidation: true,
    );
  }
}
