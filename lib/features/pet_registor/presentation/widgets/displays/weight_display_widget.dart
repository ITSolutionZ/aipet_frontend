import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class WeightDisplayWidget extends StatelessWidget {
  final double weight;
  final TextEditingController? weightController;
  final FocusNode? weightFocusNode;
  final ValueChanged<double>? onWeightChanged;

  const WeightDisplayWidget({
    super.key,
    required this.weight,
    this.weightController,
    this.weightFocusNode,
    this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          if (weightController != null && weightFocusNode != null) {
            weightController!.text = weight.toStringAsFixed(1);
            weightController!.selection = TextSelection(
              baseOffset: 0,
              extentOffset: weightController!.text.length,
            );
            weightFocusNode!.requestFocus();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (weightController != null && weightFocusNode != null)
                Positioned(
                  left: -1000,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      controller: weightController,
                      focusNode: weightFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 1),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        final newWeight = double.tryParse(value.trim());
                        if (newWeight != null &&
                            newWeight >= 0.5 &&
                            newWeight <= 50.0) {
                          onWeightChanged?.call(newWeight);
                        }
                      },
                      onSubmitted: (value) {
                        final newWeight = double.tryParse(value.trim());
                        if (newWeight != null &&
                            newWeight >= 0.5 &&
                            newWeight <= 50.0) {
                          onWeightChanged?.call(newWeight);
                        } else {
                          weightController!.text = weight.toStringAsFixed(1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('0.5kg ~ 50.0kg 사이의 값을 입력해주세요'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                        weightFocusNode?.unfocus();
                      },
                    ),
                  ),
                ),
              Text(
                weight.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
