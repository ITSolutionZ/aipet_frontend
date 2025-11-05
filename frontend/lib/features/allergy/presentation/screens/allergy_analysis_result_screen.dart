import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';


import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../services/allergy_pdf_generator.dart';
import 'allergy_analysis_result_screen_widgets/allergy_analysis_result_screen_widgets.dart';



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
      backgroundColor: AppColors.pointOffWhite, // PDF 출력에 적합한 고정 배경색
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

            const SizedBox(height: AppSpacing.md),

            // PDF 다운로드 버튼
            _buildPdfDownloadSection(context),

            const SizedBox(height: AppSpacing.md),

            // 수의사 상담 안내
            _buildVeterinarianConsultationNotice(context),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// PDF 다운로드 섹션
  Widget _buildPdfDownloadSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointDark.withValues(alpha: 0.05),
          width: 1,
        ),
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
                Icons.picture_as_pdf,
                size: 20,
                color: AppColors.pointRed,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'PDFレポート',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'アレルギー分析結果をPDFでダウンロードできます',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadPdfReport(context),
              icon: const Icon(
                Icons.download,
                size: 20,
                color: AppColors.pureWhite,
              ),
              label: Text(
                'PDFダウンロード',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pureWhite),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 수의사 상담 안내 섹션
  Widget _buildVeterinarianConsultationNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_services,
                color: AppColors.pointBlue,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '獣医師への相談をお勧めします',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'この分析結果はAIが作成した内容です。詳細な診断や治療については、必ず獣医師にご相談ください。',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.pointBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.pointBlue,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'AI分析は参考情報であり、獣医師の診断を代替するものではありません。',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PDF 리포트 다운로드
  Future<void> _downloadPdfReport(BuildContext context) async {
    try {
      // ローディング画面表示
      _showLoadingDialog(context);

      // PDF生成 (AllergyPdfGeneratorを使用)
      final pdfBytes = await AllergyPdfGenerator.generatePdf(
        petName: petName,
        analysisResult: analysisResult,
      );

      // ローディングダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // PDFプレビューとダウンロード (非同期で実行)
      unawaited(
        Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: AllergyPdfGenerator.generatePdfFileName(petName),
        ),
      );

      // 完了モーダル表示
      if (context.mounted) {
        await _showCompletionModal(context);
      }
    } catch (e) {
      // ローディングダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackBarService.showError(context, 'PDF生成エラー: $e');
      }
    }
  }

  /// 로딩 다이얼로그 표시
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'PDFを生成中...',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'しばらくお待ちください',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // PDF 생성 취소 처리
                        _cancelPdfGeneration(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.pointGray,
                        side: const BorderSide(color: AppColors.pointGray),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child: Text(
                        'キャンセル',
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// PDF 생성 취소 처리
  void _cancelPdfGeneration(BuildContext context) {
    // PDF 생성 취소 시 사용자에게 알림
    SnackBarService.showInfo(
      context,
      'PDF生成がキャンセルされました',
      duration: const Duration(seconds: 2),
    );
  }

  /// 완료 모달 표시
  Future<void> _showCompletionModal(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  'assets/lottie/checked.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'PDF生成完了！',
                style: AppFonts.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'アレルギー分析結果のPDFが正常に生成されました',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: Text(
                    '閉じる',
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          .read(savedAnalysisProvider.notifier)
          .saveAnalysis(savedAnalysis);
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, '保存エラー: $e');
      }
    }
  }
}
