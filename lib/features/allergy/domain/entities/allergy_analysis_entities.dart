import 'product_entity.dart';

/// 위험도 레벨
enum RiskLevel { low, moderate, high, critical }

/// 알레르기 분석 결과
class AllergyAnalysisResult {
  final List<String> suspectedIngredients;
  final String analysis;
  final List<String> recommendations;
  final double confidence;
  final List<String> detectedPatterns;
  final List<String> riskFactors;

  const AllergyAnalysisResult({
    required this.suspectedIngredients,
    this.analysis = '',
    required this.recommendations,
    required this.confidence,
    this.detectedPatterns = const [],
    this.riskFactors = const [],
  });
}

/// 성분 위험도 정보
class IngredientRisk {
  final String ingredient;
  final RiskLevel level;
  final double score;
  final String reason;
  final List<String> commonReactions;

  const IngredientRisk({
    required this.ingredient,
    required this.level,
    required this.score,
    required this.reason,
    this.commonReactions = const [],
  });
}

/// 성분 위험도 평가 결과
class IngredientRiskAssessment {
  final Map<String, IngredientRisk> ingredientRisks;
  final List<String> highRiskIngredients;
  final List<String> moderateRiskIngredients;
  final List<String> lowRiskIngredients;
  final double overallRiskScore;

  const IngredientRiskAssessment({
    required this.ingredientRisks,
    this.highRiskIngredients = const [],
    this.moderateRiskIngredients = const [],
    this.lowRiskIngredients = const [],
    this.overallRiskScore = 0.0,
  });
}

/// 알레르기 패턴 분석
class AllergyPatternAnalysis {
  final String petId;
  final List<String> frequentAllergens;
  final Map<String, int> allergenFrequency;
  final List<AllergyTrend> trends;
  final List<String> predictedRisks;
  final double patternConfidence;

  const AllergyPatternAnalysis({
    required this.petId,
    this.frequentAllergens = const [],
    this.allergenFrequency = const {},
    this.trends = const [],
    this.predictedRisks = const [],
    this.patternConfidence = 0.0,
  });
}

/// 알레르기 트렌드
class AllergyTrend {
  final String period;
  final List<String> increasingAllergens;
  final List<String> decreasingAllergens;
  final String analysis;

  const AllergyTrend({
    required this.period,
    this.increasingAllergens = const [],
    this.decreasingAllergens = const [],
    required this.analysis,
  });
}

/// 알레르기 기록
class AllergyRecord {
  final String id;
  final String petId;
  final List<String> products;
  final List<String> reactions;
  final String severity;
  final DateTime occurredAt;
  final String? notes;

  const AllergyRecord({
    required this.id,
    required this.petId,
    this.products = const [],
    this.reactions = const [],
    required this.severity,
    required this.occurredAt,
    this.notes,
  });
}

/// 알레르기 리포트
class AllergyReport {
  final String id;
  final String petId;
  final String petName;
  final AllergyAnalysisResult analysisResult;
  final List<String> recommendations;
  final List<ProductEntity> alternativeProducts;
  final List<String> avoidanceGuidelines;
  final DateTime generatedAt;

  const AllergyReport({
    required this.id,
    required this.petId,
    required this.petName,
    required this.analysisResult,
    this.recommendations = const [],
    this.alternativeProducts = const [],
    this.avoidanceGuidelines = const [],
    required this.generatedAt,
  });
}
