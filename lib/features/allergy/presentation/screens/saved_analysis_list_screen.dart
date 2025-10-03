import 'package:aipet_frontend/features/allergy/data/providers/saved_analysis_provider.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_analysis_result_screen.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// 저장된 알레르기 분석 결과 리스트 화면
class SavedAnalysisListScreen extends ConsumerStatefulWidget {
  const SavedAnalysisListScreen({super.key});

  @override
  ConsumerState<SavedAnalysisListScreen> createState() =>
      _SavedAnalysisListScreenState();
}

class _SavedAnalysisListScreenState
    extends ConsumerState<SavedAnalysisListScreen> {
  String? _selectedPetId;

  @override
  Widget build(BuildContext context) {
    final savedAnalysesAsync = ref.watch(savedAnalysisNotifierProvider);
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          onPressed: () {
            // 알레르기 메인 화면으로 이동
            context.go('/home/allergy');
          },
        ),
      ),
      body: Column(
        children: [
          // 펫 필터링 섹션
          petsAsync.when(
            data: (pets) {
              if (pets.isEmpty) return const SizedBox.shrink();

              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ペットでフィルター',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // 전체 선택 칩
                          _buildPetFilterChip(
                            petId: null,
                            petName: 'すべて',
                            isSelected: _selectedPetId == null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // 각 펫별 칩
                          ...pets.map(
                            (pet) => Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: _buildPetFilterChip(
                                petId: pet.id,
                                petName: pet.name,
                                isSelected: _selectedPetId == pet.id,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 분석 결과 리스트
          Expanded(
            child: savedAnalysesAsync.when(
              data: (savedAnalyses) {
                // 펫 필터링 적용
                final filteredAnalyses = _selectedPetId != null
                    ? savedAnalyses
                          .where((analysis) => analysis.petId == _selectedPetId)
                          .toList()
                    : savedAnalyses;

                if (filteredAnalyses.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filteredAnalyses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final analysis = filteredAnalyses[index];
                    return _buildAnalysisCard(context, ref, analysis);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラー: $error')),
            ),
          ),
        ],
      ),
    );
  }

  /// 펫 필터링 칩
  Widget _buildPetFilterChip({
    required String? petId,
    required String petName,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPetId = petId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown
              : AppColors.pointBrown.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointBrown.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (petId != null) ...[
              const Icon(Icons.pets, size: 16, color: AppColors.pointBrown),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              petName,
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.pointBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppColors.pointGray.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '保存された分析結果がありません',
            style: AppFonts.bodyLarge.copyWith(
              color: AppColors.pointGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '分析結果ページで「保存」をタップすると\nここに表示されます',
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 분석 결과 카드
  Widget _buildAnalysisCard(
    BuildContext context,
    WidgetRef ref,
    SavedAnalysisEntity analysis,
  ) {
    final result = analysis.analysisResult;
    final suspectedIngredients =
        result['suspectedIngredients'] as List<String>? ?? [];
    final allergyCount = result['allergyProducts'] as int? ?? 0;
    final nonAllergyCount = result['nonAllergyProducts'] as int? ?? 0;

    return Container(
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
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 (펫 이름 + 날짜)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.pointBrown.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 16,
                        color: AppColors.pointBrown,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${analysis.petName}の分析',
                            style: AppFonts.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.pointDark,
                            ),
                          ),
                          Text(
                            _formatDate(analysis.savedAt),
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 삭제 버튼
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.pointGray,
                      ),
                      onPressed: () {
                        _showDeleteConfirmDialog(context, ref, analysis.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 통계
                Row(
                  children: [
                    _buildStatChip(
                      Icons.warning_amber_rounded,
                      'あった',
                      allergyCount.toString(),
                      const Color(0xFFFF6B9D),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatChip(
                      Icons.check_circle,
                      'なかった',
                      nonAllergyCount.toString(),
                      const Color(0xFF4CAF50),
                    ),
                  ],
                ),

                // 의심 원료 미리보기
                if (suspectedIngredients.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: suspectedIngredients.take(3).map((ing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Text(
                          ing,
                          style: AppFonts.bodySmall.copyWith(
                            color: const Color(0xFFFF6B9D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label $value個',
            style: AppFonts.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(date);
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String analysisId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この分析結果を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(savedAnalysisNotifierProvider.notifier)
                  .deleteAnalysis(analysisId);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('削除しました')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
