import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알레르기 분석 버튼
class AllergyAnalyzeButton extends StatelessWidget {
  final bool isAnalyzing;
  final VoidCallback onPressed;

  const AllergyAnalyzeButton({
    super.key,
    required this.isAnalyzing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ElevatedButton(
        onPressed: isAnalyzing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: isAnalyzing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '分析中...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'アレルギー原料を分析',
                    style: AppFonts.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
