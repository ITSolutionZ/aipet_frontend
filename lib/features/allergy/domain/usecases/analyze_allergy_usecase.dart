import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/allergy_analysis_entities.dart';
import '../entities/product_entity.dart';
import '../repositories/allergy_analysis_repository.dart';

part 'analyze_allergy_usecase.g.dart';

/// 알레르기 분석 Use Case
class AnalyzeAllergyUseCase {
  final AllergyAnalysisRepository _repository;

  const AnalyzeAllergyUseCase(this._repository);

  /// 제품 기반 알레르기 분석
  Future<ComprehensiveAllergyAnalysis> analyzeProductAllergy({
    required List<ProductEntity> allergyProducts,
    required List<ProductEntity> nonAllergyProducts,
    String? petType,
    String? petId,
  }) async {
    // 비즈니스 로직: 입력 데이터 검증
    if (allergyProducts.isEmpty) {
      throw Exception('알레르기 반응이 있었던 제품을 최소 1개 이상 선택해주세요');
    }

    if (nonAllergyProducts.isEmpty) {
      throw Exception('알레르기 반응이 없었던 제품을 최소 1개 이상 선택해주세요');
    }

    // 1. 기본 알레르기 분석
    final analysisResult = await _repository.analyzeProductAllergy(
      allergyProducts: allergyProducts,
      nonAllergyProducts: nonAllergyProducts,
      petType: petType,
      petId: petId,
    );

    // 2. 성분별 위험도 평가
    final ingredientRisk = await _repository.assessIngredientRisk(
      ingredients: analysisResult.suspectedIngredients,
      petType: petType,
    );

    // 3. 대체 제품 추천
    final alternatives = await _repository.recommendAlternativeProducts(
      avoidIngredients: analysisResult.suspectedIngredients,
      petType: petType,
    );

    // 4. 패턴 분석 (펫 ID가 있는 경우)
    AllergyPatternAnalysis? patternAnalysis;
    if (petId != null) {
      try {
        patternAnalysis = await _repository.analyzeAllergyPattern(
          petId: petId,
          allergyHistory: await _buildAllergyHistory(petId),
        );
      } catch (e) {
        // 패턴 분석 실패는 전체 분석을 실패시키지 않음
      }
    }

    // 5. 종합 권장사항 생성
    final recommendations = _generateRecommendations(
      analysisResult,
      ingredientRisk,
      patternAnalysis,
    );

    return ComprehensiveAllergyAnalysis(
      basicAnalysis: analysisResult,
      ingredientRisk: ingredientRisk,
      alternativeProducts: alternatives,
      patternAnalysis: patternAnalysis,
      recommendations: recommendations,
      confidenceScore: _calculateOverallConfidence(
        analysisResult.confidence,
        ingredientRisk.overallRiskScore,
        patternAnalysis?.patternConfidence,
      ),
    );
  }

  /// 알레르기 보고서 생성 및 저장
  Future<AllergyReport> generateAndSaveReport({
    required String petId,
    required String petName,
    required ComprehensiveAllergyAnalysis analysis,
  }) async {
    // 비즈니스 로직: 보고서 생성
    final report = await _repository.generateAllergyReport(
      petId: petId,
      analysisResult: analysis.basicAnalysis,
    );

    // 보고서에 추가 정보 포함
    final enhancedReport = AllergyReport(
      id: report.id,
      petId: petId,
      petName: petName,
      analysisResult: analysis.basicAnalysis,
      recommendations: analysis.recommendations,
      alternativeProducts: analysis.alternativeProducts,
      avoidanceGuidelines: _generateAvoidanceGuidelines(analysis),
      generatedAt: DateTime.now(),
    );

    return enhancedReport;
  }

  /// 알레르기 위험도 평가
  Future<RiskAssessmentResult> assessAllergyRisk({
    required String petId,
    required List<String> potentialAllergens,
  }) async {
    // 1. 성분별 위험도 평가
    final ingredientRisk = await _repository.assessIngredientRisk(
      ingredients: potentialAllergens,
    );

    // 2. 개별 펫의 히스토리 기반 위험도
    final personalRisk = await _calculatePersonalRisk(
      petId,
      potentialAllergens,
    );

    // 3. 전체 위험도 계산
    final overallRisk = _calculateOverallRisk(
      ingredientRisk.overallRiskScore,
      personalRisk,
    );

    return RiskAssessmentResult(
      overallRiskLevel: overallRisk,
      ingredientRisks: ingredientRisk.ingredientRisks,
      personalRiskFactors: personalRisk,
      riskMitigationSteps: _generateRiskMitigationSteps(overallRisk),
    );
  }

  /// 알레르기 히스토리 구성 (임시 구현)
  Future<List<AllergyRecord>> _buildAllergyHistory(String petId) async {
    // TODO: 실제 히스토리 데이터 로드
    return [];
  }

  /// 종합 권장사항 생성
  List<String> _generateRecommendations(
    AllergyAnalysisResult basicAnalysis,
    IngredientRiskAssessment ingredientRisk,
    AllergyPatternAnalysis? patternAnalysis,
  ) {
    final recommendations = <String>[];

    // 기본 권장사항
    recommendations.addAll(basicAnalysis.recommendations);

    // 고위험 성분 기반 권장사항
    if (ingredientRisk.highRiskIngredients.isNotEmpty) {
      recommendations.add(
        '${ingredientRisk.highRiskIngredients.join(', ')}이 포함된 제품은 피해주세요',
      );
    }

    // 패턴 기반 권장사항
    if (patternAnalysis != null && patternAnalysis.predictedRisks.isNotEmpty) {
      recommendations.add(
        '과거 패턴을 고려할 때 ${patternAnalysis.predictedRisks.join(', ')}에 주의하세요',
      );
    }

    // 일반적인 관리 권장사항
    recommendations.addAll([
      '새로운 사료 도입 시 점진적으로 바꿔주세요',
      '알레르기 증상 발생 시 즉시 사용을 중단하고 수의사와 상담하세요',
      '정기적인 알레르기 테스트를 받아보시는 것을 권장합니다',
    ]);

    return recommendations.toSet().toList(); // 중복 제거
  }

  /// 회피 가이드라인 생성
  List<String> _generateAvoidanceGuidelines(
    ComprehensiveAllergyAnalysis analysis,
  ) {
    final guidelines = <String>[];

    // 의심 성분 회피
    for (final ingredient in analysis.basicAnalysis.suspectedIngredients) {
      guidelines.add('$ingredient이 포함된 모든 제품을 피하세요');
    }

    // 교차 반응 주의
    guidelines.add('관련 성분들도 함께 주의해서 확인하세요');

    // 대체 제품 안내
    if (analysis.alternativeProducts.isNotEmpty) {
      guidelines.add('추천 대체 제품들을 우선적으로 고려해보세요');
    }

    return guidelines;
  }

  /// 개인별 위험도 계산
  Future<double> _calculatePersonalRisk(
    String petId,
    List<String> potentialAllergens,
  ) async {
    // TODO: 개별 펫의 히스토리 기반 계산
    return 0.5; // 임시값
  }

  /// 전체 위험도 계산
  String _calculateOverallRisk(double ingredientRisk, double personalRisk) {
    final combined = (ingredientRisk + personalRisk) / 2;

    if (combined > 0.8) return 'high';
    if (combined > 0.5) return 'moderate';
    return 'low';
  }

  /// 위험도 완화 단계 생성
  List<String> _generateRiskMitigationSteps(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return [
          '즉시 해당 성분이 포함된 모든 제품 사용 중단',
          '수의사와 긴급 상담',
          '알레르기 테스트 예약',
          '응급처치 방법 숙지',
        ];
      case 'moderate':
        return ['해당 성분 포함 제품 사용 주의', '수의사 상담 예약', '증상 모니터링 강화', '대체 제품 준비'];
      default:
        return ['정기적인 모니터링', '예방적 관리', '정기 건강검진'];
    }
  }

  /// 전체 신뢰도 계산
  double _calculateOverallConfidence(
    double basicConfidence,
    double riskScore,
    double? patternConfidence,
  ) {
    final scores = [basicConfidence, 1.0 - riskScore];
    if (patternConfidence != null) {
      scores.add(patternConfidence);
    }

    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

/// 종합 알레르기 분석 결과
class ComprehensiveAllergyAnalysis {
  final AllergyAnalysisResult basicAnalysis;
  final IngredientRiskAssessment ingredientRisk;
  final List<ProductEntity> alternativeProducts;
  final AllergyPatternAnalysis? patternAnalysis;
  final List<String> recommendations;
  final double confidenceScore;

  const ComprehensiveAllergyAnalysis({
    required this.basicAnalysis,
    required this.ingredientRisk,
    required this.alternativeProducts,
    this.patternAnalysis,
    required this.recommendations,
    required this.confidenceScore,
  });
}

/// 위험도 평가 결과
class RiskAssessmentResult {
  final String overallRiskLevel;
  final Map<String, IngredientRisk> ingredientRisks;
  final double personalRiskFactors;
  final List<String> riskMitigationSteps;

  const RiskAssessmentResult({
    required this.overallRiskLevel,
    required this.ingredientRisks,
    required this.personalRiskFactors,
    required this.riskMitigationSteps,
  });
}

/// Use Case Provider
@riverpod
AnalyzeAllergyUseCase analyzeAllergyUseCase(AnalyzeAllergyUseCaseRef ref) {
  throw UnimplementedError('Repository provider not implemented');
}
