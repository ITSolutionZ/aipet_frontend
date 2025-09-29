import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 성별 선택 드롭다운
class GenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const GenderDropdown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      hint: const Text('選択'),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('オス')),
        DropdownMenuItem(value: 'female', child: Text('メス')),
      ],
      onChanged: onChanged,
    );
  }
}

/// 사이즈 선택 드롭다운
class SizeDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const SizeDropdown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      hint: const Text('選択'),
      items: const [
        DropdownMenuItem(value: 'small', child: Text('小型')),
        DropdownMenuItem(value: 'medium', child: Text('中型')),
        DropdownMenuItem(value: 'large', child: Text('大型')),
      ],
      onChanged: onChanged,
    );
  }
}

/// 체중 입력 필드
class WeightInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double?> onChanged;

  const WeightInputField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
        ],
        decoration: const InputDecoration(
          suffix: Text('kg'),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => onChanged(double.tryParse(value)),
      ),
    );
  }
}

/// 편집 가능한 텍스트 필드
class EditableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const EditableTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppFonts.bodyMedium.copyWith(
        color: AppColors.pointDark.withValues(alpha: 0.8),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        contentPadding: const const const EdgeInsets.all(AppSpacing.md),
      ),
      onChanged: onChanged,
    );
  }
}

/// 이름 편집 필드
class NameEditField extends StatelessWidget {
  final TextEditingController controller;

  const NameEditField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppFonts.titleLarge.copyWith(
        color: AppColors.pointDark,
        fontWeight: FontWeight.bold,
      ),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
