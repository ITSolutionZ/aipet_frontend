import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF 헤더 빌더
///
/// PDF 헤더 관련 위젯을 생성하는 책임을 가진 클래스
class PdfHeaderBuilder {
  /// 배경용 헤더 빌드
  pw.Widget buildHeaderWithBackground(String petName) {
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

  /// 전역 배경 빌드
  pw.Widget buildGlobalBackground(pw.MemoryImage? backgroundImage) {
    if (backgroundImage == null) return pw.SizedBox.expand();
    return pw.Container(
      decoration: pw.BoxDecoration(
        image: pw.DecorationImage(
          image: backgroundImage,
          fit: pw.BoxFit.cover,
        ),
      ),
    );
  }
}

