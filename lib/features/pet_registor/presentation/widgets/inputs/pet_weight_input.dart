import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/shared.dart';

/// 펫 체중 입력 위젯
class PetWeightInput extends StatefulWidget {
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final String? errorText;
  
  const PetWeightInput({
    super.key,
    required this.weight,
    required this.onWeightChanged,
    this.errorText,
  });

  @override
  State<PetWeightInput> createState() => _PetWeightInputState();
}

class _PetWeightInputState extends State<PetWeightInput> {
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
  void didUpdateWidget(PetWeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weight != widget.weight) {
      _controller.text = widget.weight.toStringAsFixed(1);
    }
  }
  
  void _validateAndUpdate() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final newWeight = double.tryParse(text);
      if (newWeight != null && newWeight >= 0.5 && newWeight <= 50.0) {
        widget.onWeightChanged(newWeight);
      } else {
        // 유효하지 않은 값이면 원래 값으로 복원
        _controller.text = widget.weight.toStringAsFixed(1);
        _showErrorSnackBar();
      }
    } else {
      _controller.text = widget.weight.toStringAsFixed(1);
    }
  }
  
  void _showErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('0.5kg ~ 50.0kg 사이의 값을 입력해주세요'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '体重を入力してください',
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: '体重入力フィールド',
          hint: '0.5キロから50キロまでの体重を入力してください',
          textField: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: widget.errorText != null 
                    ? Colors.red 
                    : AppColors.pointBrown.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              style: AppFonts.titleLarge.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '22.2',
                hintStyle: AppFonts.titleLarge.copyWith(
                  color: AppColors.pointGray.withValues(alpha: 0.5),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      'kg',
                      style: AppFonts.bodyLarge.copyWith(
                        color: AppColors.pointGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.md,
                ),
              ),
              onFieldSubmitted: (_) => _validateAndUpdate(),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppFonts.bodySmall.copyWith(color: Colors.red),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          '推奨体重範囲: 0.5kg - 50.0kg',
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointGray,
          ),
        ),
      ],
    );
  }
}