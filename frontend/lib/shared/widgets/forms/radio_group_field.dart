import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 라디오 버튼 그룹 필드 컴포넌트
///
/// 단일 선택이 필요한 옵션들을 라디오 버튼으로 표시합니다.
class RadioGroupField<T> extends StatelessWidget {
  final String label;
  final String? helperText;
  final T? value;
  final List<RadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(T?)? validator;
  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const RadioGroupField({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = 16.0,
    this.runSpacing = 8.0,
  });

  /// 세로 방향 라디오 그룹
  const RadioGroupField.vertical({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  }) : direction = Axis.vertical;

  /// 가로 방향 라디오 그룹
  const RadioGroupField.horizontal({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.alignment = WrapAlignment.start,
    this.spacing = 16.0,
    this.runSpacing = 8.0,
  }) : direction = Axis.horizontal;

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

        // 라디오 버튼 그룹
        _RadioGroupWidget<T>(
          value: value,
          options: options,
          onChanged: enabled ? onChanged : null,
          direction: direction,
          alignment: alignment,
          spacing: spacing,
          runSpacing: runSpacing,
        ),
      ],
    );
  }
}

/// 라디오 옵션 데이터 클래스
class RadioOption<T> {
  final T value;
  final String label;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const RadioOption({
    required this.value,
    required this.label,
    this.description,
    this.leading,
    this.trailing,
    this.enabled = true,
  });

  /// 간단한 라디오 옵션 생성
  RadioOption.simple({
    required this.value,
    required this.label,
    this.enabled = true,
  }) : description = null,
       leading = null,
       trailing = null;

  /// 아이콘이 있는 라디오 옵션 생성
  RadioOption.withIcon({
    required this.value,
    required this.label,
    required IconData icon,
    this.description,
    this.trailing,
    this.enabled = true,
  }) : leading = Icon(icon, size: 20);
}

/// 라디오 그룹 위젯
class _RadioGroupWidget<T> extends StatelessWidget {
  final T? value;
  final List<RadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const _RadioGroupWidget({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.direction,
    required this.alignment,
    required this.spacing,
    required this.runSpacing,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return Column(
        children: options.map((option) => _buildRadioTile(option)).toList(),
      );
    } else {
      return Wrap(
        alignment: alignment,
        spacing: spacing,
        runSpacing: runSpacing,
        children: options.map((option) => _buildRadioChip(option)).toList(),
      );
    }
  }

  Widget _buildRadioTile(RadioOption<T> option) {
    final isSelected = value == option.value;
    final isEnabled = option.enabled && onChanged != null;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: option.label,
      child: InkWell(
        onTap: isEnabled ? () => onChanged?.call(option.value) : null,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            children: [
              Radio<T>(
                value: option.value,
                groupValue: value,
                onChanged: isEnabled ? onChanged : null,
                activeColor: AppColors.primary,
              ),
              if (option.leading != null) ...[
                option.leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppFonts.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (option.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        option.description!,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (option.trailing != null) option.trailing!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioChip(RadioOption<T> option) {
    final isSelected = value == option.value;
    final isEnabled = option.enabled && onChanged != null;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: option.label,
      child: InkWell(
        onTap: isEnabled ? () => onChanged?.call(option.value) : null,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderGray,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<T>(
                value: option.value,
                groupValue: value,
                onChanged: isEnabled ? onChanged : null,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (option.leading != null) ...[
                option.leading!,
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                option.label,
                style: AppFonts.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 불린 값용 라디오 그룹 필드
class BooleanRadioGroupField extends StatelessWidget {
  final String label;
  final String? helperText;
  final bool? value;
  final String trueLabel;
  final String falseLabel;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(bool?)? validator;

  const BooleanRadioGroupField({
    super.key,
    required this.label,
    required this.trueLabel,
    required this.falseLabel,
    this.value,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      RadioOption<bool>(value: true, label: trueLabel),
      RadioOption<bool>(value: false, label: falseLabel),
    ];

    return RadioGroupField<bool>(
      label: label,
      helperText: helperText,
      value: value,
      options: options,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
      required: required,
      validator: validator,
      direction: Axis.horizontal,
    );
  }
}
