import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared.dart';

/// 범용 체중 입력 위젯
class WeightInput extends StatefulWidget {
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final String? errorText;
  final double minWeight;
  final double maxWeight;
  final String unit;

  const WeightInput({
    super.key,
    required this.weight,
    required this.onWeightChanged,
    this.errorText,
    this.minWeight = 0.5,
    this.maxWeight = 50.0,
    this.unit = 'kg',
  });

  @override
  State<WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<WeightInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.weight.toStringAsFixed(1));
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validateAndUpdate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weight != widget.weight) {
      _controller.text = widget.weight.toStringAsFixed(1);
    }
  }

  void _validateAndUpdate() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final newWeight = double.tryParse(text);
      if (newWeight != null &&
          newWeight >= widget.minWeight &&
          newWeight <= widget.maxWeight) {
        widget.onWeightChanged(newWeight);
      } else {
        _controller.text = widget.weight.toStringAsFixed(1);
        if (mounted) {
          UiService.showWarning(
            context,
            '${widget.minWeight}${widget.unit} ~ ${widget.maxWeight}${widget.unit} 사이의 값을 입력해주세요',
          );
        }
      }
    } else {
      _controller.text = widget.weight.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.pointPink
                  : AppColors.pointGray.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pointGray.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppFonts.titleLarge.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              suffixText: widget.unit,
              suffixStyle: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointGray,
              ),
            ),
            onChanged: (value) {
              final newWeight = double.tryParse(value.trim());
              if (newWeight != null &&
                  newWeight >= widget.minWeight &&
                  newWeight <= widget.maxWeight) {
                widget.onWeightChanged(newWeight);
              }
            },
            onSubmitted: (value) {
              _validateAndUpdate();
              _focusNode.unfocus();
            },
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointPink),
          ),
        ],
      ],
    );
  }
}
