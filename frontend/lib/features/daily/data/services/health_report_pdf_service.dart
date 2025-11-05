import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


import '../../../../shared/shared.dart';
import 'pdf/builders/pdf_card_builder.dart';
import 'pdf/builders/pdf_footer_builder.dart';
import 'pdf/builders/pdf_header_builder.dart';
import 'pdf/pdf_assets_loader.dart';
import 'pdf/pdf_file_manager.dart';



/// 건강 리포트 PDF 생성 서비스
///
/// 분리된 빌더들과 매니저를 사용하여 PDF를 생성하는 메인 서비스
class HealthReportPdfService {
  final PdfAssetsLoader _assetsLoader;
  final PdfFileManager _fileManager;
  final PdfHeaderBuilder _headerBuilder;
  final PdfCardBuilder _cardBuilder;
  final PdfFooterBuilder _footerBuilder;

  HealthReportPdfService({
    PdfAssetsLoader? assetsLoader,
    PdfFileManager? fileManager,
    PdfHeaderBuilder? headerBuilder,
    PdfCardBuilder? cardBuilder,
    PdfFooterBuilder? footerBuilder,
  }) : _assetsLoader = assetsLoader ?? PdfAssetsLoader(),
       _fileManager = fileManager ?? PdfFileManager(),
       _headerBuilder = headerBuilder ?? PdfHeaderBuilder(),
       _cardBuilder = cardBuilder ?? PdfCardBuilder(),
       _footerBuilder = footerBuilder ?? PdfFooterBuilder();

  /// 1개월 건강 리포트 PDF 생성
  Future<File> generateHealthReportPdf({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required String aiReport,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) async {
    try {
      LoggerService.debug('');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('🚀 [PDF SERVICE] PDF 생성 시작: $petName');
      LoggerService.debug('  - 백신 데이터: ${vaccineData.length}개');
      LoggerService.debug('  - 체중 기록: ${weightHistory.length}개');
      LoggerService.debug('  - 알레르기 정보: ${allergyInfo != null ? "있음" : "없음"}');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('');

      final pdf = pw.Document();

      // 에셋 로드
      final fontSet = await _assetsLoader.loadJapaneseFonts();
      final backgroundImage = await _assetsLoader.loadBackgroundImage();

      LoggerService.debug('📄 PDF 생성 중...');
      return await _generatePdfWithAssets(
        pdf,
        fontSet,
        backgroundImage,
        petName: petName,
        petType: petType,
        petAge: petAge,
        petWeight: petWeight,
        aiReport: aiReport,
        vaccineData: vaccineData,
        weightHistory: weightHistory,
        allergyInfo: allergyInfo,
      );
    } catch (e, stackTrace) {
      LoggerService.debug('');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('❌ [PDF SERVICE] 풀 PDF 생성 실패!');
      LoggerService.debug('🔴 에러: $e');
      LoggerService.debug('📋 Stack trace: $stackTrace');
      LoggerService.debug('⚠️ 간단한 버전으로 대체합니다...');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('');
      // Fallback to simple PDF without assets
      return _generateSimplePdf(
        petName: petName,
        petType: petType,
        petAge: petAge,
        petWeight: petWeight,
        aiReport: aiReport,
        vaccineData: vaccineData,
        weightHistory: weightHistory,
        allergyInfo: allergyInfo,
      );
    }
  }

  /// 에셋을 사용한 PDF 생성
  Future<File> _generatePdfWithAssets(
    pw.Document pdf,
    PdfFontSet fontSet,
    pw.MemoryImage? backgroundImage, {
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required String aiReport,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) async {
    // AI 리포트 길이 제한
    final limitedAiReport = aiReport.length > 2000
        ? '${aiReport.substring(0, 2000)}...\n\n※ レポートが長いため一部省略されました'
        : aiReport;

    LoggerService.debug(
      '📊 AI 리포트 길이: ${aiReport.length} → ${limitedAiReport.length}',
    );

    // PDF 페이지 생성
    pdf.addPage(
      pw.MultiPage(
        maxPages: 10,
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: fontSet.regular,
            bold: fontSet.bold,
          ),
          buildBackground: (context) =>
              _headerBuilder.buildGlobalBackground(backgroundImage),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        build: (context) => _buildContentList(
          petName: petName,
          petType: petType,
          petAge: petAge,
          petWeight: petWeight,
          aiReport: limitedAiReport,
          vaccineData: vaccineData,
          weightHistory: weightHistory,
          allergyInfo: allergyInfo,
        ),
      ),
    );

    // PDF 파일 저장
    LoggerService.debug('');
    LoggerService.debug('💾 [PDF SERVICE] PDF 파일 저장 시작');
    final output = await _fileManager.savePdfFile(pdf, petName);
    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('✅ [PDF SERVICE] PDF 생성 완료!');
    LoggerService.debug('📁 경로: ${output.path}');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');
    return output;
  }

  /// 콘텐츠 리스트 빌드 (MultiPage용)
  List<pw.Widget> _buildContentList({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required String aiReport,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) {
    return [
      pw.SizedBox(height: 60),
      _headerBuilder.buildHeaderWithBackground(petName),
      pw.SizedBox(height: 25),
      _cardBuilder.buildPetInfoCard(petName, petType, petAge, petWeight),
      pw.SizedBox(height: 15),
      _cardBuilder.buildAiReportCard(aiReport),
      pw.SizedBox(height: 15),
      if (vaccineData.isNotEmpty) ...[
        _cardBuilder.buildVaccineCard(vaccineData),
        pw.SizedBox(height: 15),
      ],
      if (weightHistory.isNotEmpty) ...[
        _cardBuilder.buildWeightCard(weightHistory),
        pw.SizedBox(height: 12),
      ],
      _cardBuilder.buildAllergyCard(allergyInfo),
      pw.SizedBox(height: 30),
      _footerBuilder.buildFooter(),
    ];
  }

  /// 간단한 PDF 생성 (에셋 없이)
  Future<File> _generateSimplePdf({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required String aiReport,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) async {
    LoggerService.debug('📄 간단한 PDF 생성 시작');
    final pdf = pw.Document();

    // 일본어 폰트 로드
    final fontSet = await _assetsLoader.loadJapaneseFonts();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: fontSet.regular, bold: fontSet.bold),
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 제목
              pw.Text(
                'AI健康レポート',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '$petNameの1ヶ月健康分析',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildSimpleDateText(),
              pw.SizedBox(height: 30),

              // 기본 정보
              _cardBuilder.buildSimpleSection('基本情報', [
                '名前: $petName',
                '種類: ${_getPetTypeInJapanese(petType)}',
                '年齢: $petAge歳',
                '体重: ${petWeight}kg',
              ]),
              pw.SizedBox(height: 20),

              // AI 분석
              _cardBuilder.buildSimpleSection('AI健康分析', [aiReport]),
              pw.SizedBox(height: 20),

              // 백신 정보
              if (vaccineData.isNotEmpty) ...[
                _buildSimpleVaccineSection(vaccineData),
                pw.SizedBox(height: 20),
              ],

              // 체중 변화
              if (weightHistory.isNotEmpty) ...[
                _buildSimpleWeightSection(weightHistory),
                pw.SizedBox(height: 20),
              ],

              // 알레르기 정보
              _buildSimpleAllergySection(allergyInfo),
              pw.SizedBox(height: 40),

              // 푸터
              _footerBuilder.buildSimpleFooter(),
            ],
          ),
        ),
      ),
    );

    LoggerService.debug('💾 간단한 PDF 파일 저장 시작');
    final output = await _fileManager.savePdfFile(pdf, petName);
    LoggerService.debug('✅ 간단한 PDF 생성 완료: ${output.path}');
    return output;
  }

  /// PDF 미리보기 (선택적)
  Future<void> previewPdf(pw.Document pdf) async {
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// 1개월 건강 리포트 PNG 이미지 생성
  Future<File> generateHealthReportPng({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required String aiReport,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) async {
    try {
      LoggerService.debug('');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('🖼️ [PNG SERVICE] PNG 생성 시작: $petName');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('');

      // 먼저 PDF를 생성
      final pdfFile = await generateHealthReportPdf(
        petName: petName,
        petType: petType,
        petAge: petAge,
        petWeight: petWeight,
        aiReport: aiReport,
        vaccineData: vaccineData,
        weightHistory: weightHistory,
        allergyInfo: allergyInfo,
      );

      // PDF 파일을 PNG로 변환
      final pdfBytes = await pdfFile.readAsBytes();
      final pngStream = Printing.raster(
        pdfBytes,
        pages: [0], // 첫 번째 페이지만 변환
        dpi: 300, // 고해상도
      );

      // Stream에서 첫 번째 PdfRaster 가져오기
      final pngRaster = await pngStream.first;
      final pngBytes = await pngRaster.toPng();

      // PNG 파일로 저장
      final file = await _fileManager.savePngFile(pngBytes, petName);

      LoggerService.debug('');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('✅ [PNG SERVICE] PNG 생성 완료!');
      LoggerService.debug('📁 경로: ${file.path}');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('');
      return file;
    } catch (e, stackTrace) {
      LoggerService.debug('');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('❌ [PNG SERVICE] PNG 생성 실패!');
      LoggerService.debug('🔴 에러: $e');
      LoggerService.debug('📋 Stack trace: $stackTrace');
      LoggerService.debug('⚠️ 간단한 버전으로 대체합니다...');
      LoggerService.debug('═══════════════════════════════════════════════');
      LoggerService.debug('');
      // 폴백: 간단한 PNG 생성
      return _generateSimplePng(
        petName: petName,
        petType: petType,
        petAge: petAge,
        petWeight: petWeight,
        aiReport: aiReport,
        vaccineData: vaccineData,
        weightHistory: weightHistory,
        allergyInfo: allergyInfo,
      );
    }
  }

  /// 간단한 PNG 생성 (폴백용)
  Future<File> _generateSimplePng({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required String aiReport,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) async {
    LoggerService.debug('🔄 간단한 PNG 생성 시작...');

    // 간단한 PDF 생성
    final pdfFile = await _generateSimplePdf(
      petName: petName,
      petType: petType,
      petAge: petAge,
      petWeight: petWeight,
      aiReport: aiReport,
      vaccineData: vaccineData,
      weightHistory: weightHistory,
      allergyInfo: allergyInfo,
    );

    // PNG로 변환
    final pdfBytes = await pdfFile.readAsBytes();
    final pngStream = Printing.raster(pdfBytes, pages: [0], dpi: 300);
    final pngRaster = await pngStream.first;
    final pngBytes = await pngRaster.toPng();

    // 파일로 저장
    final file = await _fileManager.savePngFile(
      pngBytes,
      petName,
      isSimple: true,
    );

    LoggerService.debug('✅ 간단한 PNG 생성 완료: ${file.path}');
    return file;
  }

  // ===== 헬퍼 메서드 =====

  pw.Widget _buildSimpleDateText() {
    return pw.Text(
      DateFormat('yyyy年MM月dd日').format(DateTime.now()),
      style: const pw.TextStyle(fontSize: 12),
    );
  }

  pw.Widget _buildSimpleVaccineSection(List<Map<String, dynamic>> vaccineData) {
    return _cardBuilder.buildSimpleSection(
      'ワクチン接種記録',
      vaccineData.map((v) {
        final name = v['vaccineName'] ?? '不明';
        final date = v['vaccinatedDate'] as DateTime?;
        final dateStr = date != null
            ? DateFormat('yyyy年MM月dd日').format(date)
            : '日付不明';
        return '$name: $dateStr';
      }).toList(),
    );
  }

  pw.Widget _buildSimpleWeightSection(
    List<Map<String, dynamic>> weightHistory,
  ) {
    return _cardBuilder.buildSimpleSection(
      '体重変化記録',
      weightHistory.take(5).map((w) {
        final date = w['date'] as DateTime;
        final dateStr = DateFormat('MM/dd').format(date);
        return '$dateStr: ${w['weight']}kg';
      }).toList(),
    );
  }

  pw.Widget _buildSimpleAllergySection(Map<String, dynamic>? allergyInfo) {
    return _cardBuilder.buildSimpleSection('アレルギー情報', [
      allergyInfo != null &&
              (allergyInfo['items'] as List<String>?)?.isNotEmpty == true
          ? '除外が必要な食材: ${(allergyInfo['items'] as List<String>).join('、')}'
          : 'アレルギー情報なし',
    ]);
  }

  String _getPetTypeInJapanese(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'hamster':
        return 'ハムスター';
      case 'rabbit':
        return 'うさぎ';
      case 'turtle':
        return '亀';
      default:
        return 'ペット';
    }
  }
}
