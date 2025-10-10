import 'package:aipet_frontend/features/allergy/data/providers/saved_analysis_provider.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_analysis_result_screen_widgets/allergy_analysis_result_screen_widgets.dart';
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
              context.push('/home/allergy/saved-analyses');
            },
          ),

          // 저장 버튼
          TextButton.icon(
            onPressed: () async {
              await _saveAnalysis(context, ref);
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
            AnalysisHeaderCard(
              petName: petName,
              allergyCount: allergyCount,
              nonAllergyCount: nonAllergyCount,
              confidence: confidence,
            ),

            const SizedBox(height: AppSpacing.md),

            // 의심 원료 섹션
            if (suspectedIngredients.isNotEmpty)
              SuspectedIngredientsSection(ingredients: suspectedIngredients),

            const SizedBox(height: AppSpacing.md),

            // 분석 내용 섹션
            AnalysisDetailSection(analysis: analysisResult['analysis'] ?? ''),

            const SizedBox(height: AppSpacing.md),

            // 권장사항 섹션
            if (recommendations.isNotEmpty)
              RecommendationsSection(
                recommendations: recommendations,
                analysisResult: analysisResult,
                petId: petId,
                petName: petName,
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// 분석 결과 저장
  Future<void> _saveAnalysis(BuildContext context, WidgetRef ref) async {
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存エラー: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
