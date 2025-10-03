import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';

/// 알레르기 분석 결과
class AllergyAnalysisResult {
  /// 의심 원료 리스트
  final List<String> suspectedIngredients;

  /// 분석 설명
  final String analysis;

  /// 신뢰도 (0.0 ~ 1.0)
  final double confidence;

  /// 추가 권장사항
  final List<String> recommendations;

  const AllergyAnalysisResult({
    required this.suspectedIngredients,
    required this.analysis,
    required this.confidence,
    required this.recommendations,
  });
}

/// 알레르기 분석 서비스 인터페이스
abstract class AllergyAnalysisService {
  /// 알레르기 원료 분석
  ///
  /// [allergyProducts]: 알레르기가 발생한 제품 리스트
  /// [nonAllergyProducts]: 알레르기가 없었던 제품 리스트
  /// [petType]: 펫 타입 (dog/cat)
  Future<AllergyAnalysisResult> analyzeIngredients({
    required List<ProductEntity> allergyProducts,
    required List<ProductEntity> nonAllergyProducts,
    String? petType,
  });
}
