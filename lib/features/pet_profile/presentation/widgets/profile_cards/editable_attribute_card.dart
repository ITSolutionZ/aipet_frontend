import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/shared.dart';

class EditableAttributeCard extends StatefulWidget {
  final String label;
  final String value;
  final String type;
  final bool isEditMode;
  final Function(String?)? onGenderChanged;
  final Function(String?)? onSizeChanged;
  final Function(double?)? onWeightChanged;
  final TextEditingController? weightController;

  const EditableAttributeCard({
    super.key,
    required this.label,
    required this.value,
    required this.type,
    required this.isEditMode,
    this.onGenderChanged,
    this.onSizeChanged,
    this.onWeightChanged,
    this.weightController,
  });

  @override
  State<EditableAttributeCard> createState() => _EditableAttributeCardState();
}

class _EditableAttributeCardState extends State<EditableAttributeCard> {
  late TextEditingController _internalWeightController;

  @override
  void initState() {
    super.initState();
    _internalWeightController = widget.weightController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.weightController == null) {
      _internalWeightController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
          ),
          if (widget.isEditMode)
            _buildEditableField()
          else
            Text(
              widget.value,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField() {
    switch (widget.type) {
      case 'gender':
        return DropdownButton<String>(
          value: _getGenderValue(),
          hint: const Text('選択'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('オス')),
            DropdownMenuItem(value: 'female', child: Text('メス')),
          ],
          onChanged: widget.onGenderChanged,
        );
      case 'size':
        return DropdownButton<String>(
          value: _getSizeValue(),
          hint: const Text('選択'),
          items: const [
            DropdownMenuItem(value: 'small', child: Text('小型')),
            DropdownMenuItem(value: 'medium', child: Text('中型')),
            DropdownMenuItem(value: 'large', child: Text('大型')),
          ],
          onChanged: widget.onSizeChanged,
        );
      case 'weight':
        return SizedBox(
          width: 100,
          child: TextField(
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
            controller: _internalWeightController,
            onChanged: (value) {
              final weight = double.tryParse(value);
              widget.onWeightChanged?.call(weight);
            },
          ),
        );
      default:
        return Text(widget.value);
    }
  }

  String? _getGenderValue() {
    if (widget.value == 'オス') return 'male';
    if (widget.value == 'メス') return 'female';
    return null;
  }

  String? _getSizeValue() {
    if (widget.value == '小型') return 'small';
    if (widget.value == '中型') return 'medium';
    if (widget.value == '大型') return 'large';
    return null;
  }
}