import '../entities/allergy_analysis_entities.dart';
import '../entities/product_entity.dart';

/// 알레르기 분석 Repository 인터페이스
abstract class AllergyAnalysisRepository {
  /// 제품별 알레르기 분석
  Future<AllergyAnalysisResult> analyzeProductAllergy({
    required List<ProductEntity> allergyProducts,
    required List<ProductEntity> nonAllergyProducts,
    String? petType,
    String? petId,
  });

  /// 성분별 알레르기 위험도 평가
  Future<IngredientRiskAssessment> assessIngredientRisk({
    required List<String> ingredients,
    String? petType,
  });

  /// 알레르기 패턴 분석
  Future<AllergyPatternAnalysis> analyzeAllergyPattern({
    required String petId,
    required List<AllergyRecord> allergyHistory,
  });

  /// 대체 제품 추천
  Future<List<ProductEntity>> recommendAlternativeProducts({
    required List<String> avoidIngredients,
    String? petType,
    String? category,
  });

  /// 알레르기 보고서 생성
  Future<AllergyReport> generateAllergyReport({
    required String petId,
    required AllergyAnalysisResult analysisResult,
  });
}
