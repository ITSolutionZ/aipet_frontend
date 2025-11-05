import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../shared/shared.dart';

/// アレルギー分析PDFジェネレーター
///
/// アレルギー分析結果をPDFレポートとして生成
class AllergyPdfGenerator {
  /// アレルギー分析PDFを生成
  ///
  /// [petName] ペット名
  /// [analysisResult] 分析結果データ
  /// 戻り値: PDF バイトデータ
  static Future<Uint8List> generatePdf({
    required String petName,
    required Map<String, dynamic> analysisResult,
  }) async {
    final pdf = pw.Document();

    // 日本語フォントをロード
    final regularFont = await _loadJapaneseFont(
      'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
    );
    final boldFont = await _loadJapaneseFont(
      'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
    );

    // 背景画像をロード
    final backgroundImage = await _loadBackgroundImage();

    // 分析データ抽出
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
          buildBackground: (context) {
            if (backgroundImage != null) {
              return pw.Positioned.fill(
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Image(backgroundImage, fit: pw.BoxFit.cover),
                ),
              );
            }
            return pw.Container();
          },
        ),
        build: (context) => [
          // ヘッダー
          _buildHeader(petName),
          pw.SizedBox(height: 20),

          // 分析サマリー
          _buildSummary(confidence, allergyCount, nonAllergyCount),
          pw.SizedBox(height: 20),

          // 疑いのある成分
          if (suspectedIngredients.isNotEmpty) ...[
            _buildSuspectedIngredients(suspectedIngredients),
            pw.SizedBox(height: 20),
          ],

          // 詳細分析
          _buildAnalysisDetail(analysis),
          pw.SizedBox(height: 20),

          // 推奨事項
          if (recommendations.isNotEmpty) ...[
            _buildRecommendations(recommendations),
            pw.SizedBox(height: 20),
          ],

          // 獣医師相談案内
          _buildVeterinarianConsultation(),

          // フッター
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  /// ヘッダーセクション
  static pw.Widget _buildHeader(String petName) {
    return pw.Header(
      level: 0,
      child: pw.Text(
        '$petNameのアレルギー分析結果',
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  /// サマリーセクション
  static pw.Widget _buildSummary(
    double confidence,
    int allergyCount,
    int nonAllergyCount,
  ) {
    return pw.Container(
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
    );
  }

  /// 疑いのある成分セクション
  static pw.Widget _buildSuspectedIngredients(List<String> ingredients) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
            children: ingredients
                .map(
                  (ingredient) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text('• $ingredient'),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// 詳細分析セクション
  static pw.Widget _buildAnalysisDetail(String analysis) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  /// 推奨事項セクション
  static pw.Widget _buildRecommendations(List<String> recommendations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  /// 獣医師相談案内セクション
  static pw.Widget _buildVeterinarianConsultation() {
    return pw.Container(
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
              '• 獣医師による詳細なアレルギー検査の実施\n'
              '• 血液検査や皮膚テストによる正確な診断\n'
              '• 適切な治療計画の策定\n'
              '• 定期的な健康状態のモニタリング',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.blue700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// フッターセクション
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text(
          '生成日時: ${DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  /// 日本語フォントをロード
  static Future<pw.Font> _loadJapaneseFont(String assetPath) async {
    try {
      final fontData = await rootBundle.load(assetPath);
      return pw.Font.ttf(fontData);
    } catch (e) {
      LoggerService.debug('フォントロード失敗: $e');
      return pw.Font.helvetica();
    }
  }

  /// 背景画像をロード
  static Future<pw.MemoryImage?> _loadBackgroundImage() async {
    try {
      final imageData = await rootBundle.load(
        'assets/images/aipet AI Report.png',
      );
      return pw.MemoryImage(imageData.buffer.asUint8List());
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('背景画像ロード失敗: $e');
      }
      return null;
    }
  }

  /// PDFファイル名を生成
  static String generatePdfFileName(String petName) {
    return '${petName}_アレルギー分析結果_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
  }
}
