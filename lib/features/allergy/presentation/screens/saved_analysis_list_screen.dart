import 'package:aipet_frontend/features/allergy/data/providers/saved_analysis_provider.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_analysis_result_screen.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// 저장된 분석 결과 전체 리스트 화면
class SavedAnalysisListScreen extends ConsumerStatefulWidget {
  final String? selectedPetId;

  const SavedAnalysisListScreen({super.key, this.selectedPetId});

  @override
  ConsumerState<SavedAnalysisListScreen> createState() =>
      _SavedAnalysisListScreenState();
}

class _SavedAnalysisListScreenState
    extends ConsumerState<SavedAnalysisListScreen> {
  @override
  Widget build(BuildContext context) {
    final savedAnalysesAsync = ref.watch(savedAnalysisNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '保存された分析',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
      ),
      body: savedAnalysesAsync.when(
        data: (savedAnalyses) {
          // 선택된 펫의 분석 결과만 필터링
          final filteredAnalyses = widget.selectedPetId != null
              ? savedAnalyses
                    .where((analysis) => analysis.petId == widget.selectedPetId)
                    .toList()
              : savedAnalyses;

          if (filteredAnalyses.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredAnalyses.length,
            itemBuilder: (context, index) {
              final analysis = filteredAnalyses[index];
              return _buildAnalysisCard(analysis);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.pointGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '保存された分析がありません',
              style: AppFonts.bodyLarge.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '分析を実行すると、ここに保存されます',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: AppSpacing.md),
            Text(
              'エラーが発生しました',
              style: AppFonts.bodyLarge.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              error,
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(savedAnalysisNotifierProvider);
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(SavedAnalysisEntity analysis) {
    final suspectedIngredients =
        analysis.analysisResult['suspectedIngredients'] as List<String>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllergyAnalysisResultScreen(
                  analysisResult: analysis.analysisResult,
                  petName: analysis.petName,
                  petId: analysis.petId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 펫 이름 + 날짜
                Row(
                  children: [
                    const Icon(
                      Icons.pets,
                      size: 20,
                      color: AppColors.pointBrown,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      analysis.petName,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(analysis.savedAt),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // 의심 원료
                if (suspectedIngredients.isNotEmpty) ...[
                  Text(
                    '疑われる成分',
                    style: AppFonts.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: suspectedIngredients.take(5).map((ingredient) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ingredient,
                          style: AppFonts.bodySmall.copyWith(
                            color: const Color(0xFFFF6B9D),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (suspectedIngredients.length > 5) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '他${suspectedIngredients.length - 5}個',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: AppSpacing.sm),

                // 하단 화살표
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '詳細を見る',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointBrown,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.pointBrown,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今日 ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return DateFormat('MM/dd').format(date);
    }
  }
}
