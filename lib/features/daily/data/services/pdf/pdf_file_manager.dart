import 'dart:io';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF 파일 관리 서비스
///
/// PDF 파일 저장 및 경로 관리 책임을 가진 클래스
class PdfFileManager {
  /// PDF 파일 저장
  Future<File> savePdfFile(pw.Document pdf, String petName) async {
    try {
      LoggerService.debug('📄 PDF 바이트 생성 중...');
      final bytes = await pdf.save();
      LoggerService.debug('✅ PDF 바이트 생성 완료: ${bytes.length} bytes');

      final dir = await getApplicationDocumentsDirectory();
      LoggerService.debug('📁 저장 디렉토리: ${dir.path}');

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final safeName = _sanitizePetName(petName);
      final fileName = 'health_report_${safeName}_$timestamp.pdf';
      final file = File('${dir.path}/$fileName');

      LoggerService.debug('💾 파일 저장 중: $fileName');
      await file.writeAsBytes(bytes);
      LoggerService.debug('✅ 파일 저장 완료: ${file.path}');

      return file;
    } catch (e) {
      LoggerService.debug('❌ PDF 파일 저장 실패: $e');
      rethrow;
    }
  }

  /// PNG 파일 저장
  Future<File> savePngFile(
    List<int> pngBytes,
    String petName, {
    bool isSimple = false,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final safeName = _sanitizePetName(petName);
    final prefix = isSimple ? 'health_report_simple_' : 'health_report_';
    final file = File('${dir.path}/$prefix${safeName}_$timestamp.png');

    await file.writeAsBytes(pngBytes);

    LoggerService.debug('✅ PNG 파일 저장 완료: ${file.path}');
    return file;
  }

  /// 펫 이름을 파일명에 안전한 형식으로 변환
  String _sanitizePetName(String petName) {
    return petName
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9가-힣ぁ-んァ-ン一-龥_\-]'), '_');
  }
}
