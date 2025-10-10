import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF 카드 빌더
///
/// PDF 카드 관련 위젯을 생성하는 책임을 가진 클래스
class PdfCardBuilder {
  /// 투명 배경 카드 스타일
  pw.Widget buildTransparentCard(List<pw.Widget> children) {
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
  pw.Widget buildPetInfoCard(
    String petName,
    String petType,
    int petAge,
    double petWeight,
  ) {
    final petTypeJp = _getPetTypeInJapanese(petType);

    return buildTransparentCard([
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

  /// AI 리포트 카드
  pw.Widget buildAiReportCard(String aiReport) {
    return buildTransparentCard([
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
  pw.Widget buildVaccineCard(List<Map<String, dynamic>> vaccineData) {
    return buildTransparentCard([
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
  pw.Widget buildWeightCard(List<Map<String, dynamic>> weightHistory) {
    return buildTransparentCard([
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
  pw.Widget buildAllergyCard(Map<String, dynamic>? allergyInfo) {
    final allergyItems = allergyInfo?['items'] as List<String>? ?? [];
    final allergySource = allergyInfo?['source'] as String? ?? 'ai';
    final isTestConfirmed = allergySource == 'test';

    return buildTransparentCard([
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

  /// 간단한 섹션 빌드 (심플 PDF용)
  pw.Widget buildSimpleSection(String title, List<String> items) {
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

  /// 정보 아이템 빌드
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
}

