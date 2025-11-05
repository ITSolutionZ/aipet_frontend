import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
// TODO: google_mlkit_text_recognition 패키지 활성화 시 복원 필요
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 펫 등록증 OCR 처리 서비스
///
/// Google ML Kit을 사용한 텍스트 인식 및 정보 추출
/// 현재는 Mock 구현 (google_mlkit_text_recognition 패키지 호환성 문제로 임시 비활성화)
class PetOcrService {
  /// 이미지 선택 및 OCR 처리
  /// ✅ ImageService 사용으로 중복 제거
  Future<OcrResult> selectAndProcessImage(BuildContext context) async {
    final String? imagePath = await ImageService.pickFromGallery(
      context,
      imageQuality: 80,
    );

    if (imagePath == null) {
      return OcrResult.cancelled();
    }

    return processImageWithOCR(imagePath);
  }

  /// Google ML Kit을 사용한 OCR 처리
  /// TODO: google_mlkit_text_recognition 패키지 활성화 시 실제 OCR 로직으로 교체
  Future<OcrResult> processImageWithOCR(String imagePath) async {
    try {
      // Mock 구현: 실제 OCR 대신 임시 결과 반환
      // 추후 google_mlkit_text_recognition 패키지 활성화 시 아래 주석 해제
      /*
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      // OCR 결과에서 기관명과 등록번호 추출
      String? institutionName;
      String? registrationNumber;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final String lineText = line.text.toLowerCase();

          // 기관명 패턴 찾기
          if (lineText.contains('시청') ||
              lineText.contains('구청') ||
              lineText.contains('동물보호') ||
              lineText.contains('센터') ||
              lineText.contains('관리사업소')) {
            institutionName = line.text.trim();
          }

          // 등록번호 패턴 찾기 (숫자로만 구성된 10-15자리)
          if (RegExp(r'^\d{10,15}$').hasMatch(line.text.trim())) {
            registrationNumber = line.text.trim();
          }
        }
      }

      await textRecognizer.close();
      */

      // Mock 데이터 반환
      await Future.delayed(const Duration(milliseconds: 500)); // OCR 처리 시뮬레이션

      return OcrResult.success(
        imagePath: imagePath,
        institutionName: null, // 사용자가 직접 입력하도록 유도
        registrationNumber: null,
      );
    } catch (e) {
      return OcrResult.error(error: e.toString());
    }
  }
}

/// OCR 처리 결과
class OcrResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? imagePath;
  final String? institutionName;
  final String? registrationNumber;
  final String? error;

  const OcrResult({
    required this.isSuccess,
    required this.isCancelled,
    this.imagePath,
    this.institutionName,
    this.registrationNumber,
    this.error,
  });

  factory OcrResult.success({
    required String imagePath,
    String? institutionName,
    String? registrationNumber,
  }) {
    return OcrResult(
      isSuccess: true,
      isCancelled: false,
      imagePath: imagePath,
      institutionName: institutionName,
      registrationNumber: registrationNumber,
    );
  }

  factory OcrResult.cancelled() {
    return const OcrResult(isSuccess: false, isCancelled: true);
  }

  factory OcrResult.error({required String error}) {
    return OcrResult(isSuccess: false, isCancelled: false, error: error);
  }
}
