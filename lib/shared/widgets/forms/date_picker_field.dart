import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart' as material show State;
import 'package:flutter/material.dart' hide State;
import 'package:intl/intl.dart';

/// 날짜 선택 필드 컴포넌트
///
/// 날짜 선택과 입력을 위한 통합 컴포넌트입니다.
class DatePickerField extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;
  final String? hint;
  final String? helperText;
  final DateFormat? dateFormat;
  final Locale? locale;
  final bool enabled;
  final bool required;
  final String? Function(DateTime?)? validator;
  final void Function(DateTime?)? onDateChanged;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign textAlign;
  final bool readOnly;

  const DatePickerField({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.label,
    this.hint,
    this.helperText,
    this.dateFormat,
    this.locale,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.onDateChanged,
    this.suffixIcon,
    this.contentPadding,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DatePickerFieldStateful(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      label: label,
      hint: hint,
      helperText: helperText,
      dateFormat: dateFormat,
      locale: locale,
      enabled: enabled,
      required: required,
      validator: validator,
      onDateChanged: onDateChanged,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      textAlign: textAlign,
      readOnly: readOnly,
    );
  }
}

class _DatePickerFieldStateful extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;
  final String? hint;
  final String? helperText;
  final DateFormat? dateFormat;
  final Locale? locale;
  final bool enabled;
  final bool required;
  final String? Function(DateTime?)? validator;
  final void Function(DateTime?)? onDateChanged;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign textAlign;
  final bool readOnly;

  const _DatePickerFieldStateful({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.label,
    required this.hint,
    required this.helperText,
    required this.dateFormat,
    required this.locale,
    required this.enabled,
    required this.required,
    required this.validator,
    required this.onDateChanged,
    required this.suffixIcon,
    required this.contentPadding,
    required this.textAlign,
    required this.readOnly,
  });

  @override
  material.State<_DatePickerFieldStateful> createState() =>
      _DatePickerFieldStatefulState();
}

class _DatePickerFieldStatefulState
    extends material.State<_DatePickerFieldStateful> {
  late final TextEditingController _controller;
  DateTime? _selectedDate;
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _dateFormat = widget.dateFormat ?? DateFormat('yyyy-MM-dd');
    _selectedDate = widget.initialDate;
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    if (_selectedDate != null) {
      _controller.text = _dateFormat.format(_selectedDate!);
    } else {
      _controller.text = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled || widget.readOnly) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime.now(),
      locale: widget.locale,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateController();
      });
      widget.onDateChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 (필수 표시 포함)
        if (widget.label.isNotEmpty) ...[
          if (widget.required)
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.pointRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  widget.label,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            )
          else
            Text(
              widget.label,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // 날짜 선택 필드
        GestureDetector(
          onTap: widget.enabled && !widget.readOnly
              ? () => _selectDate(context)
              : null,
          child: AbsorbPointer(
            absorbing: widget.enabled && !widget.readOnly,
            child: TextFormField(
              controller: _controller,
              enabled: widget.enabled,
              readOnly: true,
              textAlign: widget.textAlign,
              validator: (value) {
                if (widget.required &&
                    (_selectedDate == null || value?.isEmpty == true)) {
                  return '${widget.label}を選択してください';
                }
                return widget.validator?.call(_selectedDate);
              },
              decoration: InputDecoration(
                hintText: widget.hint ?? _dateFormat.format(DateTime.now()),
                helperText: widget.helperText,
                suffixIcon:
                    widget.suffixIcon ??
                    (widget.enabled && !widget.readOnly
                        ? const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          )
                        : null),
                contentPadding:
                    widget.contentPadding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(color: AppColors.pointRed),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(
                    color: AppColors.pointRed,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(color: AppColors.backgroundGray),
                ),
                filled: true,
                fillColor: widget.enabled
                    ? Colors.white
                    : AppColors.backgroundGray,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 날짜 선택 버튼 위젯
class DatePickerButton extends StatelessWidget {
  final DateTime? selectedDate;
  final DateFormat? dateFormat;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? icon;

  const DatePickerButton({
    super.key,
    this.selectedDate,
    this.dateFormat,
    required this.label,
    this.hint,
    this.onTap,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final format = dateFormat ?? DateFormat('yyyy-MM-dd');
    final displayText = selectedDate != null
        ? format.format(selectedDate!)
        : (hint ?? format.format(DateTime.now()));

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.backgroundGray,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: enabled ? AppColors.borderGray : AppColors.backgroundGray,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: AppFonts.bodyMedium.copyWith(
                  color: enabled
                      ? (selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary)
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (icon != null)
              icon!
            else if (enabled)
              const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
