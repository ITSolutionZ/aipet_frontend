import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/shared.dart';

part 'weight_input.g.dart';

/// 🎯 Weight Input State Provider
@riverpod
class WeightInputController extends _$WeightInputController {
  @override
  WeightInputState build(String inputId) => const WeightInputState();

  void initialize(
    double weight, {
    TextEditingController? controller,
    FocusNode? focusNode,
  }) {
    final textController =
        controller ?? TextEditingController(text: weight.toStringAsFixed(1));
    final inputFocusNode = focusNode ?? FocusNode();

    state = state.copyWith(
      controller: textController,
      focusNode: inputFocusNode,
      currentWeight: weight,
    );
  }

  void updateWeight(double weight) {
    state = state.copyWith(currentWeight: weight);
    if (state.controller != null) {
      state.controller!.text = weight.toStringAsFixed(1);
    }
  }
}

class WeightInputState {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double currentWeight;

  const WeightInputState({
    this.controller,
    this.focusNode,
    this.currentWeight = 0.0,
  });

  WeightInputState copyWith({
    TextEditingController? controller,
    FocusNode? focusNode,
    double? currentWeight,
  }) {
    return WeightInputState(
      controller: controller ?? this.controller,
      focusNode: focusNode ?? this.focusNode,
      currentWeight: currentWeight ?? this.currentWeight,
    );
  }
}

/// 범용 체중 입력 위젯
class WeightInput extends ConsumerStatefulWidget {
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final String? errorText;
  final double minWeight;
  final double maxWeight;
  final String unit;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const WeightInput({
    super.key,
    required this.weight,
    required this.onWeightChanged,
    this.errorText,
    this.minWeight = 0.5,
    this.maxWeight = 50.0,
    this.unit = 'kg',
    this.controller,
    this.focusNode,
  });

  @override
  ConsumerState<WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends ConsumerState<WeightInput> {
  final String _inputId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(weightInputControllerProvider(_inputId).notifier)
          .initialize(
            widget.weight,
            controller: widget.controller,
            focusNode: widget.focusNode,
          );

      final state = ref.read(weightInputControllerProvider(_inputId));
      state.focusNode?.addListener(() {
        if (!(state.focusNode?.hasFocus ?? false)) {
          _validateAndUpdate();
        }
      });
    });
  }

  @override
  void didUpdateWidget(WeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weight != widget.weight) {
      ref
          .read(weightInputControllerProvider(_inputId).notifier)
          .updateWeight(widget.weight);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _validateAndUpdate() {
    final state = ref.read(weightInputControllerProvider(_inputId));
    if (state.controller == null) return;

    final text = state.controller!.text.trim();
    if (text.isNotEmpty) {
      final newWeight = double.tryParse(text);
      if (newWeight != null &&
          newWeight >= widget.minWeight &&
          newWeight <= widget.maxWeight) {
        widget.onWeightChanged(newWeight);
      } else {
        state.controller!.text = widget.weight.toStringAsFixed(1);
        if (mounted) {
          UiService.showWarning(
            context,
            '${widget.minWeight}${widget.unit} ~ ${widget.maxWeight}${widget.unit} 사이의 값을 입력해주세요',
          );
        }
      }
    } else {
      state.controller!.text = widget.weight.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(weightInputControllerProvider(_inputId));

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
            controller: inputState.controller,
            focusNode: inputState.focusNode,
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
              inputState.focusNode?.unfocus();
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
