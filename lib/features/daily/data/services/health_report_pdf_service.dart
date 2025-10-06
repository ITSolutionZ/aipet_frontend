import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// 건강 리포트 PDF 생성 서비스
class HealthReportPdfService {
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
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('🚀 [PDF SERVICE] PDF 생성 시작: $petName');
      debugPrint('  - 백신 데이터: ${vaccineData.length}개');
      debugPrint('  - 체중 기록: ${weightHistory.length}개');
      debugPrint('  - 알레르기 정보: ${allergyInfo != null ? "있음" : "없음"}');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('');

      final pdf = pw.Document();

      // 일본어 폰트 로드 (번들 TTF)
      debugPrint('📝 폰트 로드 시작...');
      final font = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
      );
      final fontBold = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
      );
      debugPrint('✅ 폰트 로드 완료');

      // 배경 이미지 로드
      debugPrint('🖼️ 배경 이미지 로드 시작...');
      final backgroundImage = await _loadBackgroundImage();
      debugPrint('✅ 배경 이미지 로드 완료');

      debugPrint('📄 PDF 생성 중...');
      return await _generatePdfWithAssets(
        pdf,
        font,
        fontBold,
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
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('❌ [PDF SERVICE] 풀 PDF 생성 실패!');
      debugPrint('🔴 에러: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      debugPrint('⚠️ 간단한 버전으로 대체합니다...');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('');
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
    pw.Font font,
    pw.Font fontBold,
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
    // AI 리포트 길이 제한 (너무 길면 잘라내기)
    final limitedAiReport = aiReport.length > 2000
        ? '${aiReport.substring(0, 2000)}...\n\n※ レポートが長いため一部省略されました'
        : aiReport;

    debugPrint('📊 AI 리포트 길이: ${aiReport.length} → ${limitedAiReport.length}');

    // PDF 페이지 생성 (자동 페이지 분할 + 페이지 번호 푸터)
    pdf.addPage(
      pw.MultiPage(
        maxPages: 10, // 최대 10페이지로 제한
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          buildBackground: (context) =>
              _buildGlobalBackground(backgroundImage), // Changed
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
    debugPrint('');
    debugPrint('💾 [PDF SERVICE] PDF 파일 저장 시작');
    final output = await _savePdfFile(pdf, petName);
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════');
    debugPrint('✅ [PDF SERVICE] PDF 생성 완료!');
    debugPrint('📁 경로: ${output.path}');
    debugPrint('═══════════════════════════════════════════════');
    debugPrint('');
    return output;
  }

  /// 배경 이미지 로드
  Future<pw.MemoryImage?> _loadBackgroundImage() async {
    try {
      debugPrint('🔍 배경 이미지 로드 시도: assets/images/aipet_AI_Report.png');
      final imageData = await rootBundle.load(
        'assets/images/aipet_AI_Report.png',
      );
      debugPrint('✅ 배경 이미지 로드 성공');
      return pw.MemoryImage(imageData.buffer.asUint8List());
    } catch (e) {
      debugPrint('❌ 배경 이미지 로드 실패: $e');
      return null;
    }
  }

  /// 번들 폰트 로드 // Changed
  Future<pw.Font> _loadBundledFont(String assetPath) async {
    // Changed
    try {
      debugPrint('🔍 폰트 로드 시도: $assetPath');
      final fontData = await rootBundle.load(assetPath); // Changed
      debugPrint('✅ 폰트 로드 성공: $assetPath');
      return pw.Font.ttf(fontData); // Changed
    } catch (e) {
      debugPrint('❌ 폰트 로드 실패: $assetPath - $e');
      // 기본 폰트 사용
      return pw.Font.helvetica();
    }
  } // Changed

  /// 전역 배경 빌드 // Changed
  pw.Widget _buildGlobalBackground(pw.MemoryImage? backgroundImage) {
    // Changed
    if (backgroundImage == null) return pw.SizedBox.expand(); // Changed
    return pw.Container(
      // Changed
      decoration: pw.BoxDecoration(
        // Changed
        image: pw.DecorationImage(
          // Changed
          image: backgroundImage, // Changed
          fit: pw.BoxFit.cover, // Changed
        ), // Changed
      ), // Changed
    ); // Changed
  } // Changed

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
      pw.SizedBox(height: 60), // 상단 여백
      // 날짜와 펫 이름
      _buildHeaderWithBackground(petName),
      pw.SizedBox(height: 25),

      // 펫 기본 정보
      _buildPetInfoCard(petName, petType, petAge, petWeight),
      pw.SizedBox(height: 15),

      // AI 분석 리포트
      _buildAiReportCard(aiReport),
      pw.SizedBox(height: 15),

      // 백신 접종 기록
      if (vaccineData.isNotEmpty) ...[
        _buildVaccineCard(vaccineData),
        pw.SizedBox(height: 15),
      ],

      // 체중 변화 기록
      if (weightHistory.isNotEmpty) ...[
        _buildWeightCard(weightHistory),
        pw.SizedBox(height: 12),
      ],

      // 알레르기 정보
      _buildAllergyCard(allergyInfo),

      pw.SizedBox(height: 30),

      // 푸터
      _buildFooter(),
    ];
  }

  /// 배경용 헤더
  pw.Widget _buildHeaderWithBackground(String petName) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年MM月dd日').format(now);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'AI健康レポート',
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '$petNameの1ヶ月健康分析',
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          dateStr,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
        ),
      ],
    );
  }

  /// 투명 배경 카드 스타일
  pw.Widget _buildTransparentCard(List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xCCFFFFFF), // 80% 투명 흰색
        borderRadius: pw.BorderRadius.circular(12),
        boxShadow: const [
          pw.BoxShadow(
            color: PdfColor.fromInt(0x30000000),
            blurRadius: 8,
            offset: PdfPoint(0, 4),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 펫 정보 카드
  pw.Widget _buildPetInfoCard(
    String petName,
    String petType,
    int petAge,
    double petWeight,
  ) {
    final petTypeJp = _getPetTypeInJapanese(petType);

    return _buildTransparentCard([
      pw.Row(
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF2196F3),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                'i',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            '基本情報',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem('名前', petName),
          _buildInfoItem('種類', petTypeJp),
          _buildInfoItem('年齢', '$petAge歳'),
          _buildInfoItem('体重', '${petWeight}kg'),
        ],
      ),
    ]);
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// AI 리포트 카드
  pw.Widget _buildAiReportCard(String aiReport) {
    return _buildTransparentCard([
      pw.Row(
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF667EEA),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                'AI',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            'AI健康分析',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF667EEA),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Text(aiReport, style: const pw.TextStyle(fontSize: 10)),
    ]);
  }

  /// 백신 카드
  pw.Widget _buildVaccineCard(List<Map<String, dynamic>> vaccineData) {
    return _buildTransparentCard([
      pw.Row(
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF4CAF50),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                '注',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            'ワクチン接種記録',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      // 리스트 형태로 변경
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: vaccineData.take(5).map((vaccine) {
          final vaccineName = vaccine['vaccineName'] ?? '不明';
          final vaccinatedDate = vaccine['vaccinatedDate'] as DateTime?;
          final dateStr = vaccinatedDate != null
              ? DateFormat('yyyy年MM月dd日').format(vaccinatedDate)
              : '日付不明';

          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 4,
                  height: 4,
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF4CAF50),
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.Text(
                    '$vaccineName: $dateStr',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ]);
  }

  /// 체중 카드
  pw.Widget _buildWeightCard(List<Map<String, dynamic>> weightHistory) {
    return _buildTransparentCard([
      pw.Row(
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF00BCD4),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                '重',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            '体重変化記録',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Wrap(
        spacing: 8,
        runSpacing: 6,
        children: weightHistory.take(8).map((weight) {
          final date = weight['date'] as DateTime;
          final dateStr = DateFormat('MM/dd').format(date);
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFE3F2FD),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              '$dateStr: ${weight['weight']}kg',
              style: const pw.TextStyle(fontSize: 8),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  /// 알레르기 카드
  pw.Widget _buildAllergyCard(Map<String, dynamic>? allergyInfo) {
    final allergyItems = allergyInfo?['items'] as List<String>? ?? [];
    final allergySource = allergyInfo?['source'] as String? ?? 'ai';
    final isTestConfirmed = allergySource == 'test';

    return _buildTransparentCard([
      pw.Row(
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFE57373),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                '!',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            'アレルギー情報',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFFE57373),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        children: [
          pw.Text('除外が必要な食材:', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(width: 6),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: isTestConfirmed
                  ? const PdfColor.fromInt(0xFF4CAF50)
                  : const PdfColor.fromInt(0xFFFF9800),
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              isTestConfirmed ? '検査完了' : 'AI推定',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      // 리스트 형태로 변경
      if (allergyItems.isNotEmpty)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: allergyItems.map((allergy) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 4,
                    height: 4,
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFE57373),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(allergy, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        )
      else
        pw.Text(
          'アレルギー情報なし',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
    ]);
  }

  /// 푸터 빌드
  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xCCFFFFFF), // 80% 불투명도
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '※ このレポートは参考情報です。気になる症状がある場合は、必ず獣医師にご相談ください。',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated by AI Pet Health Management System',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// PDF 파일 저장
  Future<File> _savePdfFile(pw.Document pdf, String petName) async {
    try {
      debugPrint('📄 PDF 바이트 생성 중...');
      final bytes = await pdf.save();
      debugPrint('✅ PDF 바이트 생성 완료: ${bytes.length} bytes');

      final dir = await getApplicationDocumentsDirectory();
      debugPrint('📁 저장 디렉토리: ${dir.path}');

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final safeName = petName
          .trim()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^A-Za-z0-9가-힣ぁ-んァ-ン一-龥_\-]'), '_');
      final fileName = 'health_report_${safeName}_$timestamp.pdf';
      final file = File('${dir.path}/$fileName');

      debugPrint('💾 파일 저장 중: $fileName');
      await file.writeAsBytes(bytes);
      debugPrint('✅ 파일 저장 완료: ${file.path}');

      return file;
    } catch (e) {
      debugPrint('❌ PDF 파일 저장 실패: $e');
      rethrow;
    }
  }

  /// 펫 타입을 일본어로 변환
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
    debugPrint('📄 간단한 PDF 생성 시작');
    final pdf = pw.Document();

    // 일본어 폰트 로드
    pw.Font? font;
    pw.Font? fontBold;

    try {
      font = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
      );
      fontBold = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
      );
      debugPrint('✅ 간단한 PDF용 일본어 폰트 로드 성공');
    } catch (e) {
      debugPrint('⚠️ 일본어 폰트 로드 실패, 기본 폰트 사용: $e');
      font = pw.Font.helvetica();
      fontBold = pw.Font.helvetica();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
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
              pw.Text(
                DateFormat('yyyy年MM月dd日').format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),

              // 기본 정보
              _buildSimpleSection('基本情報', [
                '名前: $petName',
                '種類: ${_getPetTypeInJapanese(petType)}',
                '年齢: $petAge歳',
                '体重: ${petWeight}kg',
              ]),
              pw.SizedBox(height: 20),

              // AI 분석
              _buildSimpleSection('AI健康分析', [aiReport]),
              pw.SizedBox(height: 20),

              // 백신 정보
              if (vaccineData.isNotEmpty) ...[
                _buildSimpleSection(
                  'ワクチン接種記録',
                  vaccineData.map((v) {
                    final name = v['vaccineName'] ?? '不明';
                    final date = v['vaccinatedDate'] as DateTime?;
                    final dateStr = date != null
                        ? DateFormat('yyyy年MM月dd日').format(date)
                        : '日付不明';
                    return '$name: $dateStr';
                  }).toList(),
                ),
                pw.SizedBox(height: 20),
              ],

              // 체중 변화
              if (weightHistory.isNotEmpty) ...[
                _buildSimpleSection(
                  '体重変化記録',
                  weightHistory.take(5).map((w) {
                    final date = w['date'] as DateTime;
                    final dateStr = DateFormat('MM/dd').format(date);
                    return '$dateStr: ${w['weight']}kg';
                  }).toList(),
                ),
                pw.SizedBox(height: 20),
              ],

              // 알레르기 정보
              _buildSimpleSection('アレルギー情報', [
                allergyInfo != null &&
                        (allergyInfo['items'] as List<String>?)?.isNotEmpty ==
                            true
                    ? '除外が必要な食材: ${(allergyInfo['items'] as List<String>).join('、')}'
                    : 'アレルギー情報なし',
              ]),

              pw.SizedBox(height: 40),

              // 푸터
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      '※ このレポートは参考情報です。気になる症状がある場合は、必ず獣医師にご相談ください。',
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated by AI Pet Health Management System',
                      style: const pw.TextStyle(fontSize: 7),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    debugPrint('💾 간단한 PDF 파일 저장 시작');
    final output = await _savePdfFile(pdf, petName);
    debugPrint('✅ 간단한 PDF 생성 완료: ${output.path}');
    return output;
  }

  /// 간단한 섹션 빌드
  pw.Widget _buildSimpleSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
            child: pw.Text(item, style: const pw.TextStyle(fontSize: 10)),
          ),
        ),
      ],
    );
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
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('🖼️ [PNG SERVICE] PNG 생성 시작: $petName');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('');

      // 먼저 PDF를 생성
      final pdf = pw.Document();

      // 일본어 폰트 로드 (번들 TTF)
      final font = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
      );
      final fontBold = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
      );

      // 배경 이미지 로드
      final backgroundImage = await _loadBackgroundImage();

      // PDF 파일을 먼저 생성
      final pdfFile = await _generatePdfWithAssets(
        pdf,
        font,
        fontBold,
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

      // PDF 파일을 PNG로 변환
      final pdfBytes = await pdfFile.readAsBytes();
      final pngStream = Printing.raster(
        pdfBytes,
        pages: [0], // 첫 번째 페이지만 변환
        dpi: 300, // 고해상도
      );

      // Stream에서 첫 번째 PdfRaster 가져오기
      final pngRaster = await pngStream.first;

      // PNG 파일로 저장
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${dir.path}/health_report_${petName}_$timestamp.png');

      await file.writeAsBytes(await pngRaster.toPng());

      debugPrint('');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('✅ [PNG SERVICE] PNG 생성 완료!');
      debugPrint('📁 경로: ${file.path}');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('');
      return file;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('❌ [PNG SERVICE] PNG 생성 실패!');
      debugPrint('🔴 에러: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      debugPrint('⚠️ 간단한 버전으로 대체합니다...');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('');
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
    debugPrint('🔄 간단한 PNG 생성 시작...');

    final pdf = pw.Document();

    // 일본어 폰트 로드
    pw.Font? font;
    pw.Font? fontBold;

    try {
      font = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
      );
      fontBold = await _loadBundledFont(
        'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
      );
      debugPrint('✅ 간단한 PNG용 일본어 폰트 로드 성공');
    } catch (e) {
      debugPrint('⚠️ 일본어 폰트 로드 실패, 기본 폰트 사용: $e');
      font = pw.Font.helvetica();
      fontBold = pw.Font.helvetica();
    }

    // 일본어 폰트로 PDF 생성
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '$petNameの健康レポート',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('ペット名: $petName'),
                pw.Text('種類: $petType'),
                pw.Text('年齢: $petAge歳'),
                pw.Text('体重: ${petWeight}kg'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'AI健康分析',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  aiReport.length > 500
                      ? '${aiReport.substring(0, 500)}...'
                      : aiReport,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '生成日時: ${DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          );
        },
      ),
    );

    // PNG로 변환
    final pdfBytes = await pdf.save();
    final pngStream = Printing.raster(pdfBytes, pages: [0], dpi: 300);

    // Stream에서 첫 번째 PdfRaster 가져오기
    final pngRaster = await pngStream.first;

    // 파일로 저장
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(
      '${dir.path}/health_report_simple_${petName}_$timestamp.png',
    );

    await file.writeAsBytes(await pngRaster.toPng());

    debugPrint('✅ 간단한 PNG 생성 완료: ${file.path}');
    return file;
  }
}
