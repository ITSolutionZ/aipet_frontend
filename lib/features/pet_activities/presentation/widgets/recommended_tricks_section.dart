import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/learn_trick_card.dart';
import 'package:flutter/material.dart';

/// 추천 트릭 섹션
class RecommendedTricksSection extends StatelessWidget {
  final Function(String) onTrickTap;

  const RecommendedTricksSection({super.key, required this.onTrickTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'おすすめのトリック',
          style: AppFonts.fredoka(
            fontSize: AppFonts.xl,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              LearnTrickCard(
                title: 'お手',
                description: '基本的なトリック',
                imagePath: 'assets/images/activities/trick_hand.png',
                difficulty: 1,
                onTap: () => onTrickTap('お手'),
              ),
              LearnTrickCard(
                title: 'お座り',
                description: '基本的なトリック',
                imagePath: 'assets/images/activities/trick_sit.png',
                difficulty: 1,
                onTap: () => onTrickTap('お座り'),
              ),
              LearnTrickCard(
                title: '伏せ',
                description: '基本的なトリック',
                imagePath: 'assets/images/activities/trick_down.png',
                difficulty: 2,
                onTap: () => onTrickTap('伏せ'),
              ),
              LearnTrickCard(
                title: '待て',
                description: '基本的なトリック',
                imagePath: 'assets/images/activities/trick_wait.png',
                difficulty: 2,
                onTap: () => onTrickTap('待て'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
