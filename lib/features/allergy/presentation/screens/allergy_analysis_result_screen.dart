import 'dart:async';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
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
      // 로딩 화면 표시
      _showLoadingDialog(context);

      // PDF 생성
      final pdf = await _generateAllergyAnalysisPdf();

      // 로딩 다이얼로그 닫기 (PDF 생성 완료 후 즉시)
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // PDF 미리보기 및 다운로드 (비동기로 실행)
      unawaited(
        Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf,
          name:
              '${petName}_アレルギー分析結果_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
        ),
      );

      // 완료 모달 표시 (PDF 미리보기와 동시에)
      if (context.mounted) {
        await _showCompletionModal(context);
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
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

  /// 알레르기 분석 결과 PDF 생성
  Future<Uint8List> _generateAllergyAnalysisPdf() async {
    final pdf = pw.Document();

    // 일본어 폰트 로드
    final regularFont = await _loadJapaneseFont(
      'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
    );
    final boldFont = await _loadJapaneseFont(
      'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
    );

    // 배경 이미지 로드
    final backgroundImage = await _loadBackgroundImage();

    final suspectedIngredients =
        analysisResult['suspectedIngredients'] as List<String>? ?? [];
    final recommendations =
        analysisResult['recommendations'] as List<String>? ?? [];
    final confidence = analysisResult['confidence'] as double? ?? 0.0;
    final allergyCount = analysisResult['allergyProducts'] as int? ?? 0;
    final nonAllergyCount = analysisResult['nonAllergyProducts'] as int? ?? 0;
    final analysis = analysisResult['analysis'] ?? '';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          // 배경 이미지를 페이지 테마로 설정
          buildBackground: (context) {
            if (backgroundImage != null) {
              return pw.Positioned.fill(
                child: pw.Opacity(
                  opacity: 0.1, // 배경 이미지를 더 희미하게
                  child: pw.Image(backgroundImage, fit: pw.BoxFit.cover),
                ),
              );
            }
            return pw.Container();
          },
        ),
        build: (context) => [
          // 헤더
          pw.Header(
            level: 0,
            child: pw.Text(
              '$petNameのアレルギー分析結果',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // 분석 요약
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '分析サマリー',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('信頼度: ${(confidence * 100).toStringAsFixed(1)}%'),
                pw.Text('アレルギー反応商品数: $allergyCount個'),
                pw.Text('非アレルギー商品数: $nonAllergyCount個'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // 의심 성분
          if (suspectedIngredients.isNotEmpty) ...[
            pw.Text(
              '疑いのある成分',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                border: pw.Border.all(color: PdfColors.red200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: suspectedIngredients
                    .map(
                      (ingredient) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text('• $ingredient'),
                      ),
                    )
                    .toList(),
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // 분석 내용
          pw.Text(
            '詳細分析',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(analysis, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.SizedBox(height: 20),

          // 권장사항
          if (recommendations.isNotEmpty) ...[
            pw.Text(
              '推奨事項',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: recommendations
                    .map(
                      (recommendation) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text('• $recommendation'),
                      ),
                    )
                    .toList(),
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // 수의사 상담 안내
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '獣医師への相談をお勧めします',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'この分析結果はAIが作成した内容です。詳細な診断や治療については、必ず獣医師にご相談ください。',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '⚠️ ',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'AI分析は参考情報であり、獣医師の診断を代替するものではありません。',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.blue800,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '推奨される次のステップ：',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    '• 獣医師による詳細なアレルギー検査の実施\n• 血液検査や皮膚テストによる正確な診断\n• 適切な治療計画の策定\n• 定期的な健康状態のモニタリング',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.blue700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 푸터
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            '生成日時: ${DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// 일본어 폰트 로드
  Future<pw.Font> _loadJapaneseFont(String assetPath) async {
    try {
      final fontData = await rootBundle.load(assetPath);
      return pw.Font.ttf(fontData);
    } catch (e) {
      // 폰트 로드 실패 시 기본 폰트 사용
      return pw.Font.helvetica();
    }
  }

  /// 배경 이미지 로드
  Future<pw.MemoryImage?> _loadBackgroundImage() async {
    try {
      final imageData = await rootBundle.load(
        'assets/images/aipet AI Report.png',
      );
      return pw.MemoryImage(imageData.buffer.asUint8List());
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('배경 이미지 로드 실패: $e');
      }
      return null;
    }
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
