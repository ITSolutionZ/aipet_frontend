import 'package:flutter/material.dart';

import '../../../shared/shared.dart';

/// 칩 선택 필드 컴포넌트
///
/// 다중 선택이 가능한 옵션들을 칩으로 표시합니다.
class ChipSelectorField<T> extends StatelessWidget {
  final String label;
  final String? helperText;
  final List<T> selectedValues;
  final List<ChipOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(List<T>)? validator;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final ChipSelectorStyle style;
  final int? maxSelection;
  final bool allowDeselectAll;

  const ChipSelectorField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.style = ChipSelectorStyle.filter,
    this.maxSelection,
    this.allowDeselectAll = true,
  });

  /// 필터 스타일 칩 선택
  const ChipSelectorField.filter({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.maxSelection,
    this.allowDeselectAll = true,
  }) : style = ChipSelectorStyle.filter;

  /// 액션 스타일 칩 선택
  const ChipSelectorField.action({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.maxSelection,
    this.allowDeselectAll = true,
  }) : style = ChipSelectorStyle.action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 (필수 표시 포함)
        if (required)
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
                label,
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          )
        else
          Text(
            label,
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],

        const SizedBox(height: AppSpacing.sm),

        // 칩 선택 그룹
        _ChipSelectorWidget<T>(
          selectedValues: selectedValues,
          options: options,
          onChanged: enabled ? onChanged : null,
          alignment: alignment,
          spacing: spacing,
          runSpacing: runSpacing,
          style: style,
          maxSelection: maxSelection,
          allowDeselectAll: allowDeselectAll,
        ),

        // 선택 개수 표시
        if (maxSelection != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${selectedValues.length}/$maxSelection 선택됨',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// 칩 옵션 데이터 클래스
class ChipOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final Widget? leading;
  final Color? selectedColor;
  final Color? backgroundColor;
  final bool enabled;

  const ChipOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.leading,
    this.selectedColor,
    this.backgroundColor,
    this.enabled = true,
  });

  /// 간단한 칩 옵션 생성
  ChipOption.simple({
    required this.value,
    required this.label,
    this.enabled = true,
  }) : description = null,
       icon = null,
       leading = null,
       selectedColor = AppColors.primary,
       backgroundColor = null;

  /// 아이콘이 있는 칩 옵션 생성
  ChipOption.withIcon({
    required this.value,
    required this.label,
    required this.icon,
    this.description,
    this.enabled = true,
  }) : leading = null,
       selectedColor = AppColors.primary,
       backgroundColor = null;
}

/// 칩 선택 스타일
enum ChipSelectorStyle { filter, action }

/// 칩 선택 위젯
class _ChipSelectorWidget<T> extends StatelessWidget {
  final List<T> selectedValues;
  final List<ChipOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final ChipSelectorStyle style;
  final int? maxSelection;
  final bool allowDeselectAll;

  const _ChipSelectorWidget({
    required this.selectedValues,
    required this.options,
    required this.onChanged,
    required this.alignment,
    required this.spacing,
    required this.runSpacing,
    required this.style,
    required this.maxSelection,
    required this.allowDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: options.map((option) => _buildChip(option)).toList(),
    );
  }

  Widget _buildChip(ChipOption<T> option) {
    final isSelected = selectedValues.contains(option.value);
    final isEnabled = option.enabled && onChanged != null;
    final canSelect =
        maxSelection == null ||
        selectedValues.length < maxSelection! ||
        isSelected;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled && canSelect,
      label: option.label,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.leading != null) ...[
              option.leading!,
              const SizedBox(width: AppSpacing.xs),
            ] else if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(option.label),
          ],
        ),
        selected: isSelected,
        onSelected: isEnabled && canSelect
            ? (selected) {
                if (selected) {
                  _addSelection(option.value);
                } else {
                  _removeSelection(option.value);
                }
              }
            : null,
        selectedColor:
            option.selectedColor ?? AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: option.selectedColor ?? AppColors.primary,
        backgroundColor:
            option.backgroundColor ?? AppColors.cardBackgroundWhite,
        disabledColor: AppColors.backgroundGray,
        labelStyle: AppFonts.bodySmall.copyWith(
          color: isSelected
              ? (option.selectedColor ?? AppColors.primary)
              : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: BorderSide(
            color: isSelected
                ? (option.selectedColor ?? AppColors.primary)
                : AppColors.borderGray,
            width: 1,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        avatarBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
    );
  }

  void _addSelection(T value) {
    if (onChanged != null) {
      final newSelection = List<T>.from(selectedValues)..add(value);
      onChanged!(newSelection);
    }
  }

  void _removeSelection(T value) {
    if (onChanged != null && allowDeselectAll) {
      final newSelection = List<T>.from(selectedValues)..remove(value);
      onChanged!(newSelection);
    }
  }
}

/// 문자열 리스트용 칩 선택 필드
class StringChipSelectorField extends StatelessWidget {
  final String label;
  final String? helperText;
  final List<String> selectedValues;
  final List<String> options;
  final ValueChanged<List<String>>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(List<String>)? validator;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final ChipSelectorStyle style;
  final int? maxSelection;
  final bool allowDeselectAll;

  const StringChipSelectorField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.style = ChipSelectorStyle.filter,
    this.maxSelection,
    this.allowDeselectAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final chipOptions = options
        .map(
          (option) => ChipOption<String>.simple(value: option, label: option),
        )
        .toList();

    return ChipSelectorField<String>(
      label: label,
      helperText: helperText,
      selectedValues: selectedValues,
      options: chipOptions,
      onChanged: onChanged,
      enabled: enabled,
      required: required,
      validator: validator,
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      style: style,
      maxSelection: maxSelection,
      allowDeselectAll: allowDeselectAll,
    );
  }
}
