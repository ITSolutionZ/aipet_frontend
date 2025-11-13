import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../screens/allergy_analysis_result_screen.dart';
import '../screens/saved_analysis_list_screen.dart';

/// 저장된 분석 결과 아코디언 위젯
class SavedAnalysisAccordion extends ConsumerStatefulWidget {
  final String? selectedPetId;

  const SavedAnalysisAccordion({super.key, this.selectedPetId});

  @override
  ConsumerState<SavedAnalysisAccordion> createState() =>
      _SavedAnalysisAccordionState();
}

class _SavedAnalysisAccordionState
    extends ConsumerState<SavedAnalysisAccordion> {
  @override
  Widget build(BuildContext context) {
    final savedAnalysesAsync = ref.watch(savedAnalysisProvider);

    return savedAnalysesAsync.when(
      data: (savedAnalyses) {
        // 선택된 펫의 분석 결과만 필터링
        final filteredAnalyses = widget.selectedPetId != null
            ? savedAnalyses
                  .where((analysis) => analysis.petId == widget.selectedPetId)
                  .toList()
            : savedAnalyses;

        if (filteredAnalyses.isEmpty) {
          return IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
            onPressed: () => Navigator.pop(context),
          );
        }

        return PopupMenuButton(
          icon: const Icon(Icons.folder_open, color: AppColors.pointBrown),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                enabled: false,
                padding: EdgeInsets.zero,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.medium),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history,
                              color: AppColors.pointBrown,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '保存された分析 (${filteredAnalyses.length})',
                              style: AppFonts.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.pointBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // 분석 결과 리스트
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          itemCount: filteredAnalyses.length > 5
                              ? 5
                              : filteredAnalyses.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final analysis = filteredAnalyses[index];
                            return _buildAnalysisItem(context, analysis);
                          },
                        ),
                      ),
                      // 더보기 버튼
                      if (filteredAnalyses.length > 5)
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            // 전체 리스트 화면으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SavedAnalysisListScreen(
                                  selectedPetId: widget.selectedPetId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(AppRadius.medium),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'もっと見る',
                                style: AppFonts.bodySmall.copyWith(
                                  color: AppColors.pointBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ];
          },
        );
      },
      loading: () => IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
        onPressed: () => Navigator.pop(context),
      ),
      error: (error, stackTrace) => IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildAnalysisItem(
    BuildContext context,
    SavedAnalysisEntity analysis,
  ) {
    final suspectedIngredients =
        analysis.analysisResult['suspectedIngredients'] as List<String>? ?? [];

    return InkWell(
      onTap: () {
        Navigator.pop(context); // 팝업 닫기

        // 분석 결과 페이지로 이동
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 펫 이름 + 날짜
            Row(
              children: [
                const Icon(Icons.pets, size: 16, color: AppColors.pointBrown),
                const SizedBox(width: 4),
                Text(
                  analysis.petName,
                  style: AppFonts.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(analysis.savedAt),
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 의심 원료 미리보기
            if (suspectedIngredients.isNotEmpty)
              Wrap(
                spacing: 4,
                children: suspectedIngredients.take(2).map((ing) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ing,
                      style: AppFonts.bodySmall.copyWith(
                        color: const Color(0xFFFF6B9D),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
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
