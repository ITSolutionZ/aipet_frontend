import 'package:aipet_frontend/shared/core/constants/app_constants.dart';
import 'package:aipet_frontend/shared/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 공통 폼 패턴들을 제공하는 위젯들
class CommonFormPatterns {
  CommonFormPatterns._();

  /// 기본 텍스트 필드
  static Widget buildTextField({
    required String label,
    String? hint,
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    int? maxLines,
    int? maxLength,
    bool enabled = true,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  /// 이메일 필드
  static Widget buildEmailField({
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return buildTextField(
      controller: controller,
      label: 'メールアドレス',
      hint: 'example@email.com',
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator ?? _emailValidator,
      onChanged: onChanged,
      onSaved: onSaved,
      prefixIcon: const Icon(Icons.email),
    );
  }

  /// 비밀번호 필드
  static Widget buildPasswordField({
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    bool obscureText = true,
    VoidCallback? onToggleVisibility,
    TextEditingController? controller,
  }) {
    return buildTextField(
      controller: controller,
      label: 'パスワード',
      hint: 'パスワードを入力してください',
      initialValue: initialValue,
      obscureText: obscureText,
      textInputAction: TextInputAction.done,
      validator: validator ?? _passwordValidator,
      onChanged: onChanged,
      onSaved: onSaved,
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: onToggleVisibility,
      ),
    );
  }

  /// 숫자 필드
  static Widget buildNumberField({
    required String label,
    String? hint,
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    double? min,
    double? max,
    int? decimalPlaces,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimalPlaces != null,
      ),
      textInputAction: TextInputAction.next,
      validator: validator ?? (value) => _numberValidator(value, min, max),
      onChanged: onChanged,
      onSaved: onSaved,
      inputFormatters: decimalPlaces != null
          ? [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,' + decimalPlaces.toString() + r'}'),
              ),
            ]
          : [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  /// 날짜 필드
  static Widget buildDateField({
    required String label,
    DateTime? initialValue,
    DateTime? firstDate,
    DateTime? lastDate,
    void Function(DateTime?)? onChanged,
    void Function(DateTime?)? onSaved,
    String? Function(DateTime?)? validator,
  }) {
    return FormField<DateTime>(
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: field.context,
              initialDate: initialValue ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime.now(),
            );
            if (date != null) {
              field.didChange(date);
              onChanged?.call(date);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              initialValue != null
                  ? '${initialValue.year}/${initialValue.month.toString().padLeft(2, '0')}/${initialValue.day.toString().padLeft(2, '0')}'
                  : '日付を選択してください',
              style: TextStyle(
                color: initialValue != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 시간 필드
  static Widget buildTimeField({
    required String label,
    TimeOfDay? initialValue,
    void Function(TimeOfDay?)? onChanged,
    void Function(TimeOfDay?)? onSaved,
    String? Function(TimeOfDay?)? validator,
  }) {
    return FormField<TimeOfDay>(
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: field.context,
              initialTime: initialValue ?? TimeOfDay.now(),
            );
            if (time != null) {
              field.didChange(time);
              onChanged?.call(time);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.access_time),
            ),
            child: Text(
              initialValue != null
                  ? '${initialValue.hour.toString().padLeft(2, '0')}:${initialValue.minute.toString().padLeft(2, '0')}'
                  : '時間を選択してください',
              style: TextStyle(
                color: initialValue != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 드롭다운 필드
  static Widget buildDropdownField<T>({
    required String label,
    required List<T> items,
    required String Function(T) itemBuilder,
    T? value,
    void Function(T?)? onChanged,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    Widget? prefixIcon,
  }) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      onSaved: onSaved,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: prefixIcon,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemBuilder(item)),
                );
              }).toList(),
              onChanged: (T? newValue) {
                field.didChange(newValue);
                onChanged?.call(newValue);
              },
            ),
          ),
        );
      },
    );
  }

  /// 체크박스 필드
  static Widget buildCheckboxField({
    required String label,
    required bool value,
    void Function(bool?)? onChanged,
    void Function(bool?)? onSaved,
    String? Function(bool?)? validator,
    String? subtitle,
  }) {
    return FormField<bool>(
      initialValue: value,
      validator: validator,
      onSaved: onSaved,
      builder: (field) {
        return CheckboxListTile(
          title: Text(label),
          subtitle: subtitle != null ? Text(subtitle) : null,
          value: value,
          onChanged: (bool? newValue) {
            field.didChange(newValue);
            onChanged?.call(newValue);
          },
        );
      },
    );
  }

  /// 스위치 필드
  static Widget buildSwitchField({
    required String label,
    required bool value,
    void Function(bool)? onChanged,
    void Function(bool?)? onSaved,
    String? Function(bool?)? validator,
    String? subtitle,
  }) {
    return FormField<bool>(
      initialValue: value,
      validator: validator,
      onSaved: onSaved,
      builder: (field) {
        return SwitchListTile(
          title: Text(label),
          subtitle: subtitle != null ? Text(subtitle) : null,
          value: value,
          onChanged: (bool newValue) {
            field.didChange(newValue);
            onChanged?.call(newValue);
          },
        );
      },
    );
  }

  /// 폼 버튼들
  static Widget buildFormButtons({
    required VoidCallback onSave,
    VoidCallback? onCancel,
    String? saveText,
    String? cancelText,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        if (onCancel != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              child: Text(cancelText ?? AppTexts.cancel),
            ),
          ),
          const const const SizedBox(width: AppConstants.spacingMD),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(saveText ?? AppTexts.save),
          ),
        ),
      ],
    );
  }

  /// 검증 함수들
  static String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.requiredField;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppTexts.invalidEmail;
    }
    return null;
  }

  static String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.requiredField;
    }
    if (value.length < AppConstants.minPasswordLength) {
      return AppTexts.tooShort;
    }
    return null;
  }

  static String? _numberValidator(String? value, double? min, double? max) {
    if (value == null || value.isEmpty) {
      return AppTexts.requiredField;
    }
    final number = double.tryParse(value);
    if (number == null) {
      return AppTexts.invalidFormat;
    }
    if (min != null && number < min) {
      return '$min以上で入力してください';
    }
    if (max != null && number > max) {
      return '$max以下で入力してください';
    }
    return null;
  }
}
