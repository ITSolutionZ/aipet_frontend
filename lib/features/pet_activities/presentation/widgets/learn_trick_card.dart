import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 학습 트릭 카드 위젯
class LearnTrickCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int difficulty;
  final VoidCallback onTap;

  const LearnTrickCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.difficulty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.pointGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 40,
                    color: AppColors.pointGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star,
                      size: 12,
                      color: index < difficulty
                          ? AppColors.pointGreen
                          : AppColors.pointGray.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
