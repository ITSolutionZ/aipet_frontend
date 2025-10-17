import 'dart:io';

import '../data/services/health_report_pdf_service.dart';
import '../domain/models/health_report_template.dart';

class HealthReportPdfAdapter {
  const HealthReportPdfAdapter(this._pdfService);

  final HealthReportPdfService _pdfService;

  /// DTO를 서비스 파라미터로 변환하여 PDF 생성
  Future<File> fromTemplate(HealthReportTemplate template) async {
    // DTO를 서비스가 요구하는 Map 형태로 변환
    final vaccineData = template.report.vaccines
        .map(
          (vaccine) => {
            'vaccineName': vaccine.name,
            'vaccinatedDate': vaccine.date,
          },
        )
        .toList();

    final weightHistory = template.report.weights
        .map((weight) => {'date': weight.date, 'weight': weight.value})
        .toList();

    final allergyInfo = {
      'source': template.report.allergy.source,
      'items': template.report.allergy.items,
    };

    // 기존 서비스 시그니처 유지하여 호출
    return _pdfService.generateHealthReportPdf(
      petName: template.pet.name,
      petType: template.pet.type,
      petAge: template.pet.age,
      petWeight: template.pet.weight,
      aiReport: template.report.aiSummary,
      vaccineData: vaccineData,
      weightHistory: weightHistory,
      allergyInfo: allergyInfo,
    );
  }
}
