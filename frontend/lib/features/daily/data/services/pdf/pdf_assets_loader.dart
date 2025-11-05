import 'package:flutter/services.dart';

import 'package:pdf/widgets.dart' as pw;


import '../../../../../shared/shared.dart';
/// PDF 에셋 로드 서비스
///
/// 폰트, 이미지 등의 에셋을 로드하는 책임을 가진 클래스
class PdfAssetsLoader {
  /// 번들 폰트 로드
  Future<pw.Font> loadBundledFont(String assetPath) async {
    try {
      LoggerService.debug('🔍 폰트 로드 시도: $assetPath');
      final fontData = await rootBundle.load(assetPath);
      LoggerService.debug('✅ 폰트 로드 성공: $assetPath');
      return pw.Font.ttf(fontData);
    } catch (e) {
      LoggerService.debug('❌ 폰트 로드 실패: $assetPath - $e');
      // 기본 폰트 사용
      return pw.Font.helvetica();
    }
  }

  /// 배경 이미지 로드
  Future<pw.MemoryImage?> loadBackgroundImage() async {
    try {
      LoggerService.debug('🔍 배경 이미지 로드 시도: assets/images/aipet_AI_Report.png');
      final imageData = await rootBundle.load(
        'assets/images/aipet_AI_Report.png',
      );
      LoggerService.debug('✅ 배경 이미지 로드 성공');
      return pw.MemoryImage(imageData.buffer.asUint8List());
    } catch (e) {
      LoggerService.debug('❌ 배경 이미지 로드 실패: $e');
      return null;
    }
  }

  /// 일본어 폰트 세트 로드 (Regular + Bold)
  Future<PdfFontSet> loadJapaneseFonts() async {
    LoggerService.debug('📝 일본어 폰트 로드 시작...');
    final font = await loadBundledFont(
      'assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf',
    );
    final fontBold = await loadBundledFont(
      'assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf',
    );
    LoggerService.debug('✅ 일본어 폰트 로드 완료');
    return PdfFontSet(regular: font, bold: fontBold);
  }
}

/// PDF 폰트 세트
class PdfFontSet {
  final pw.Font regular;
  final pw.Font bold;

  const PdfFontSet({required this.regular, required this.bold});
}
