import 'package:aipet_frontend/features/allergy/data/providers/saved_analysis_provider.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 알레르기 분석 결과 화면
class AllergyAnalysisResultScreen extends ConsumerWidget {
  final Map<String, dynamic> analysisResult;
  final String petName;
  final String petId;

  const AllergyAnalysisResultScreen({
    super.key,
    required this.analysisResult,
    required this.petName,
    required this.petId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suspectedIngredients =
        analysisResult['suspectedIngredients'] as List<String>? ?? [];
    final recommendations =
        analysisResult['recommendations'] as List<String>? ?? [];
    final confidence = analysisResult['confidence'] as double? ?? 0.0;
    final allergyCount = analysisResult['allergyProducts'] as int? ?? 0;
    final nonAllergyCount = analysisResult['nonAllergyProducts'] as int? ?? 0;

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 히스토리 버튼
          IconButton(
            icon: const Icon(Icons.list_alt, color: AppColors.pointDark),
            onPressed: () {
              // 저장된 리스트 페이지로 이동
              context.push('/home/allergy/saved-analyses');
            },
          ),
          // 저장 버튼
          TextButton.icon(
            onPressed: () async {
              // 분석 결과 저장
              final savedAnalysis = SavedAnalysisEntity(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                petId: petId,
                petName: petName,
                analysisResult: analysisResult,
                savedAt: DateTime.now(),
              );

              try {
                await ref
                    .read(savedAnalysisNotifierProvider.notifier)
                    .saveAnalysis(savedAnalysis);

                // 저장 완료 후 추가 동작 없음
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('保存エラー: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save_outlined, color: AppColors.pointBrown),
            label: Text(
              '保存',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // 헤더 카드
            _buildHeaderCard(
              petName,
              allergyCount,
              nonAllergyCount,
              confidence,
            ),

            const SizedBox(height: AppSpacing.md),

            // 의심 원료 섹션
            if (suspectedIngredients.isNotEmpty)
              _buildSuspectedIngredientsSection(suspectedIngredients),

            const SizedBox(height: AppSpacing.md),

            // 분석 내용 섹션
            _buildAnalysisSection(analysisResult['analysis'] ?? ''),

            const SizedBox(height: AppSpacing.md),

            // 권장사항 섹션
            if (recommendations.isNotEmpty)
              _buildRecommendationsSection(recommendations),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// 헤더 카드
  Widget _buildHeaderCard(
    String petName,
    int allergyCount,
    int nonAllergyCount,
    double confidence,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pointBrown,
            AppColors.pointBrown.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointBrown.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, color: Colors.white, size: 32),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$petNameの分析結果',
                style: AppFonts.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '⚠ アレルギー',
                '$allergyCount個',
                const Color(0xFFFF6B9D),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                '✓ なし',
                '$nonAllergyCount個',
                const Color(0xFF4CAF50),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                '信頼度',
                '${(confidence * 100).toInt()}%',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppFonts.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 의심 원료 섹션
  Widget _buildSuspectedIngredientsSection(List<String> ingredients) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF6B9D),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '疑わしい原料',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...ingredients.map(
            (ingredient) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFFF6B9D), size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 내용 섹션
  Widget _buildAnalysisSection(String analysis) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.article_outlined,
                color: AppColors.pointBrown,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '詳細分析',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            analysis,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 권장사항 섹션
  Widget _buildRecommendationsSection(List<String> recommendations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '推奨事項',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...recommendations.asMap().entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // 상품보기 버튼
          _buildViewProductsButton(),
        ],
      ),
    );
  }

  /// 상품보기 버튼
  Widget _buildViewProductsButton() {
    return SizedBox(
      width: double.infinity,
      child: Builder(
        builder: (context) {
          return TextButton.icon(
            onPressed: () {
              context.push(
                '/home/allergy/recommended-products',
                extra: {
                  'suspectedIngredients':
                      analysisResult['suspectedIngredients'] as List<String>? ??
                      [],
                  'petId': petId,
                  'petName': petName,
                },
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
              ),
            ),
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF4CAF50),
            ),
            label: Text(
              '推奨商品を見る',
              style: AppFonts.bodyMedium.copyWith(
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
