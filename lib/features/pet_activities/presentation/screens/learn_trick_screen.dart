import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

/// 새로운 트릭 학습 화면
class LearnTrickScreen extends ConsumerStatefulWidget {
  const LearnTrickScreen({super.key});

  @override
  ConsumerState<LearnTrickScreen> createState() => _LearnTrickScreenState();
}

class _LearnTrickScreenState extends ConsumerState<LearnTrickScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '新しいトリックを学ぶ',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 추천 트릭 섹션
            _buildRecommendedTricks(),
            const SizedBox(height: AppSpacing.xl),

            // 모든 트릭 카테고리
            _buildAllTricksCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTricks() {
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
              _buildTrickCard(
                'お手',
                '基本的なトリック',
                'assets/images/activities/trick_hand.png',
                1,
              ),
              _buildTrickCard(
                'お座り',
                '基本的なトリック',
                'assets/images/activities/trick_sit.png',
                1,
              ),
              _buildTrickCard(
                '伏せ',
                '基本的なトリック',
                'assets/images/activities/trick_down.png',
                2,
              ),
              _buildTrickCard(
                '待て',
                '基本的なトリック',
                'assets/images/activities/trick_wait.png',
                2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllTricksCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'すべてのトリック',
          style: AppFonts.fredoka(
            fontSize: AppFonts.xl,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCategoryCard(
          '基本トリック',
          'お手、お座り、伏せなど',
          Icons.star,
          AppColors.pointGreen,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCategoryCard(
          '高度なトリック',
          '回転、ジャンプ、ダンスなど',
          Icons.star_half,
          AppColors.pointBlue,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCategoryCard(
          '芸術的トリック',
          '絵を描く、楽器を演奏するなど',
          Icons.auto_awesome,
          AppColors.pointBrown,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCategoryCard(
          'スポーツトリック',
          'アジリティ、フリスビーなど',
          Icons.sports_soccer,
          AppColors.pointPink,
        ),
      ],
    );
  }

  Widget _buildTrickCard(
    String title,
    String description,
    String imagePath,
    int difficulty,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Card(
        child: InkWell(
          onTap: () => _openTrickDetail(title),
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

  Widget _buildCategoryCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _openCategoryDetail(title),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.bodyLarge.copyWith(
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
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.pointGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTrickDetail(String trickName) {
    // 트릭 상세 화면으로 이동 (구현 예정)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$trickName の詳細画面は実装予定です'),
        backgroundColor: AppColors.pointGreen,
      ),
    );
  }

  void _openCategoryDetail(String categoryName) {
    // 카테고리 상세 화면으로 이동 (구현 예정)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$categoryName カテゴリは実装予定です'),
        backgroundColor: AppColors.pointBlue,
      ),
    );
  }
}
