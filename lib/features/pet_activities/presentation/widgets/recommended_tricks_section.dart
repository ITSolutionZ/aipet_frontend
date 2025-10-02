import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/learn_trick_card.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 추천 트릭 섹션
class RecommendedTricksSection extends StatelessWidget {
  final Function(String) onTrickTap;

  const RecommendedTricksSection({super.key, required this.onTrickTap});

  @override
  Widget build(BuildContext context) {
    // Mock TrickEntity instances
    final trick1 = TrickEntity(
      id: '1',
      name: 'お手',
      description: '基本的なトリック',
      category: 'Basic',
      difficulty: DifficultyLevel.easy,
      estimatedTime: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imagePath: 'assets/images/activities/trick_hand.png',
    );
    final trick2 = TrickEntity(
      id: '2',
      name: 'お座り',
      description: '基本的なトリック',
      category: 'Basic',
      difficulty: DifficultyLevel.easy,
      estimatedTime: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imagePath: 'assets/images/activities/trick_sit.png',
    );
    final trick3 = TrickEntity(
      id: '3',
      name: '伏せ',
      description: '基本的なトリック',
      category: 'Basic',
      difficulty: DifficultyLevel.medium,
      estimatedTime: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imagePath: 'assets/images/activities/trick_down.png',
    );
    final trick4 = TrickEntity(
      id: '4',
      name: '待て',
      description: '基本的なトリック',
      category: 'Basic',
      difficulty: DifficultyLevel.medium,
      estimatedTime: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imagePath: 'assets/images/activities/trick_wait.png',
    );

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
              LearnTrickCard(trick: trick1, onTap: () => onTrickTap(trick1.name)),
              LearnTrickCard(trick: trick2, onTap: () => onTrickTap(trick2.name)),
              LearnTrickCard(trick: trick3, onTap: () => onTrickTap(trick3.name)),
              LearnTrickCard(trick: trick4, onTap: () => onTrickTap(trick4.name)),
            ],
          ),
        ),
      ],
    );
  }
}
