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
      throw Exception('あれるリアルグアゲンハイゲンエンテン アレルギー反応があった商品を最低1つ以上選択してください');
    }

    if (nonAllergyProducts.isEmpty) {
      throw Exception('あれるリアルグアゲンハイゲンエンテン アレルギー反応がなかった商品を最低1つ以上選択してください');
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
        '${ingredientRisk.highRiskIngredients.join(', ')}が含まれている商品は避けてください',
      );
    }

    // 패턴 기반 권장사항
    if (patternAnalysis != null && patternAnalysis.predictedRisks.isNotEmpty) {
      recommendations.add(
        '過去のパターンを考慮した場合 ${patternAnalysis.predictedRisks.join(', ')}に注意してください',
      );
    }

    // 일반적인 관리 권장사항
    recommendations.addAll([
      '新しいドッグフードを導入する場合は段階的に変えてください',
      'アレルギーの症状が出た場合はすぐに使用を中止し、獣医と相談してください',
      '定期的なアレルギーテストを受けることをお勧めします',
    ]);

    return recommendations.toSet().toList(); // 重複排除
  }

  /// 회피 가이드라인 생성
  List<String> _generateAvoidanceGuidelines(
    ComprehensiveAllergyAnalysis analysis,
  ) {
    final guidelines = <String>[];

    // 의심 성분 회피
    for (final ingredient in analysis.basicAnalysis.suspectedIngredients) {
      guidelines.add('$ingredientが含まれているすべての商品を避けてください');
    }

    // 교차 반응 주의
    guidelines.add('関連成分も注意して確認してください');

    // 대체 제품 안내
    if (analysis.alternativeProducts.isNotEmpty) {
      guidelines.add('推奨の代替商品を優先的に検討してください');
    }

    return guidelines;
  }

  /// 개인별 위험도 계산
  Future<double> _calculatePersonalRisk(
    String petId,
    List<String> potentialAllergens,
  ) async {
    // TODO: 개별 펫의 히스토리 기반 계산
    return 0.5; // 仮値
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
          'すぐにその成分を含むすべての商品の使用を中止してください',
          '獣医と緊急相談',
          'アレルギーテストの予約',
          '緊急処置の方法を確認してください',
        ];
      case 'moderate':
        return ['その成分を含む商品の使用に注意してください', '獣医と相談の予約', '症状の監視を強化', '代替商品の準備'];
      default:
        return ['定期的な監視', '予防的な管理', '定期的な健康検査'];
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
AnalyzeAllergyUseCase analyzeAllergyUseCase(Ref ref) {
  throw UnimplementedError('Repository provider not implemented');
}
