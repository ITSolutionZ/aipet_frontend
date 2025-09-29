import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 트릭 상세 다이얼로그
class TrickDetailDialog extends StatelessWidget {
  final TrickEntity trick;

  const TrickDetailDialog({super.key, required this.trick});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const const const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.lg),
                  topRight: Radius.circular(AppSpacing.lg),
                ),
              ),
              child: Row(
                children: [
                  // 트릭 이미지
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: trick.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                            child: Image.asset(
                              trick.imagePath!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            color: AppColors.pointBrown,
                            size: 30,
                          ),
                  ),
                  const const const SizedBox(width: AppSpacing.md),

                  // 트릭 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trick.name,
                          style: AppFonts.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const const const SizedBox(height: AppSpacing.xs),
                        Text(
                          trick.description,
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 닫기 버튼
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 내용
            Flexible(
              child: SingleChildScrollView(
                padding: const const const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 난이도와 시간
                    _buildInfoRow(),
                    const const const SizedBox(height: AppSpacing.lg),

                    // 단계별 설명
                    if (trick.steps.isNotEmpty) ...[
                      _buildSectionTitle('学習ステップ'),
                      const const const SizedBox(height: AppSpacing.md),
                      ...trick.steps.asMap().entries.map(
                        (entry) => _buildStepItem(entry.key + 1, entry.value),
                      ),
                      const const const SizedBox(height: AppSpacing.lg),
                    ],

                    // 팁
                    if (trick.tips.isNotEmpty) ...[
                      _buildSectionTitle('コツ'),
                      const const const SizedBox(height: AppSpacing.md),
                      ...trick.tips.map((tip) => _buildTipItem(tip)),
                      const const const SizedBox(height: AppSpacing.lg),
                    ],

                    // 비디오 링크
                    if (trick.videoUrl != null) ...[
                      _buildSectionTitle('参考動画'),
                      const const const SizedBox(height: AppSpacing.md),
                      _buildVideoLink(),
                      const const const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Container(
              padding: const const const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('閉じる'),
                    ),
                  ),
                  const const const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: 학습 시작 로직
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('学習開始'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoChip(
          icon: Icons.trending_up,
          label: _getDifficultyText(trick.difficulty),
          color: _getDifficultyColor(trick.difficulty),
        ),
        const const const SizedBox(width: AppSpacing.sm),
        _buildInfoChip(
          icon: Icons.access_time,
          label: '${trick.estimatedTime}分',
          color: AppColors.pointBlue,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const const const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const const const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.pointDark,
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String step) {
    return Padding(
      padding: const const const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.pointGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const const const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(step, style: AppFonts.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const const const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.pointBrown,
            size: 20,
          ),
          const const const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(tip, style: AppFonts.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildVideoLink() {
    return Container(
      padding: const const const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.play_circle_outline,
            color: AppColors.pointBlue,
            size: 24,
          ),
          const const const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '参考動画を見る',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.pointBlue,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return '簡単';
      case DifficultyLevel.medium:
        return '普通';
      case DifficultyLevel.hard:
        return '難しい';
      case DifficultyLevel.expert:
        return '専門家';
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.pointGreen;
      case DifficultyLevel.medium:
        return AppColors.pointBlue;
      case DifficultyLevel.hard:
        return AppColors.pointBrown;
      case DifficultyLevel.expert:
        return AppColors.pointPink;
    }
  }
}
