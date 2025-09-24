import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class WeightSliderWidget extends StatelessWidget {
  final double weight;
  final ValueChanged<double> onWeightChanged;

  const WeightSliderWidget({
    super.key,
    required this.weight,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final width = MediaQuery.of(context).size.width - 32;

            final relativeX = localPosition.dx - 16;
            final normalizedX = (relativeX / width).clamp(0.0, 1.0);

            final newWeight = (0.5 + normalizedX * (50.0 - 0.5)).clamp(0.5, 50.0);

            if ((newWeight - weight).abs() > 0.05) {
              onWeightChanged(newWeight);
            }
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                ...List.generate(15, (index) {
                  final screenWidth = MediaQuery.of(context).size.width - 32;
                  final position = (screenWidth / 14) * index;

                  return Positioned(
                    left: position - 1,
                    top: 12,
                    child: Container(
                      width: 2,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.pointGray.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),
                Positioned(
                  top: 6,
                  left: () {
                    final screenWidth = MediaQuery.of(context).size.width - 32;
                    const thumbWidth = 32.0;
                    final normalizedPosition = (weight - 0.5) / (50.0 - 0.5);
                    final rawLeft =
                        normalizedPosition * screenWidth - (thumbWidth / 2);

                    return rawLeft.clamp(0.0, screenWidth - thumbWidth);
                  }(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.pointBrown,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pointBrown.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 1.5,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const const const SizedBox(width: 2),
                          Container(
                            width: 1.5,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const const const SizedBox(width: 2),
                          Container(
                            width: 1.5,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
