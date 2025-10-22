import '../../domain/entities/allergy_analysis_entities.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/allergy_analysis_repository.dart';
import '../../domain/services/allergy_analysis_service.dart';
import '../datasources/allergy_analysis_datasource.dart';

/// 알레르기 분석 Repository 구현체
class AllergyAnalysisRepositoryImpl implements AllergyAnalysisRepository {
  final AllergyAnalysisService _analysisService;
  final AllergyAnalysisDatasource _datasource;

  const AllergyAnalysisRepositoryImpl(this._analysisService, this._datasource);

  @override
  Future<AllergyAnalysisResult> analyzeProductAllergy({
    required List<ProductEntity> allergyProducts,
    required List<ProductEntity> nonAllergyProducts,
    String? petType,
    String? petId,
  }) async {
    try {
      // AI 서비스를 통한 분석
      final serviceResult = await _analysisService.analyzeIngredients(
        allergyProducts: allergyProducts,
        nonAllergyProducts: nonAllergyProducts,
        petType: petType,
      );

      // 서비스 결과를 도메인 엔티티로 변환
      final domainResult = AllergyAnalysisResult(
        suspectedIngredients: serviceResult.suspectedIngredients,
        recommendations: serviceResult.recommendations,
        confidence: serviceResult.confidence,
      );

      // 로컬 저장 (기록 유지용)
      if (petId != null) {
        await _datasource.saveAnalysisResult(petId, domainResult);
      }

      return domainResult;
    } catch (error) {
      // AI 분석 실패 시 기본 분석으로 폴백
      return _datasource.performBasicAnalysis(
        allergyProducts,
        nonAllergyProducts,
      );
    }
  }

  @override
  Future<IngredientRiskAssessment> assessIngredientRisk({
    required List<String> ingredients,
    String? petType,
  }) async {
    // 성분별 위험도 데이터베이스 조회
    final riskData = await _datasource.getIngredientRiskData(ingredients);

    final ingredientRisks = <String, IngredientRisk>{};
    final highRisk = <String>[];
    final moderateRisk = <String>[];
    final lowRisk = <String>[];

    var totalRiskScore = 0.0;

    for (final ingredient in ingredients) {
      final risk = riskData[ingredient] ?? _getDefaultRisk(ingredient);
      ingredientRisks[ingredient] = risk;

      switch (risk.level) {
        case RiskLevel.high:
        case RiskLevel.critical:
          highRisk.add(ingredient);
          totalRiskScore += 0.8;
          break;
        case RiskLevel.moderate:
          moderateRisk.add(ingredient);
          totalRiskScore += 0.5;
          break;
        case RiskLevel.low:
          lowRisk.add(ingredient);
          totalRiskScore += 0.2;
          break;
      }
    }

    final overallRisk = ingredients.isEmpty
        ? 0.0
        : totalRiskScore / ingredients.length;

    return IngredientRiskAssessment(
      ingredientRisks: ingredientRisks,
      highRiskIngredients: highRisk,
      moderateRiskIngredients: moderateRisk,
      lowRiskIngredients: lowRisk,
      overallRiskScore: overallRisk,
    );
  }

  @override
  Future<AllergyPatternAnalysis> analyzeAllergyPattern({
    required String petId,
    required List<AllergyRecord> allergyHistory,
  }) async {
    if (allergyHistory.isEmpty) {
      return AllergyPatternAnalysis(
        petId: petId,
        frequentAllergens: [],
        allergenFrequency: {},
        trends: [],
        predictedRisks: [],
        patternConfidence: 0.0,
      );
    }

    // 빈도 분석
    final allergenFreq = <String, int>{};
    for (final record in allergyHistory) {
      for (final product in record.products) {
        allergenFreq[product] = (allergenFreq[product] ?? 0) + 1;
      }
    }

    // 상위 알레르기 유발 제품
    final frequentAllergens =
        allergenFreq.entries
            .where((e) => e.value > 1)
            .map((e) => e.key)
            .toList()
          ..sort((a, b) => allergenFreq[b]!.compareTo(allergenFreq[a]!));

    // 트렌드 분석
    final trends = await _analyzeTrends(allergyHistory);

    // 예측 위험 요소
    final predictedRisks = await _predictFutureRisks(allergyHistory);

    // 패턴 신뢰도
    final confidence = _calculatePatternConfidence(
      allergyHistory,
      frequentAllergens,
    );

    return AllergyPatternAnalysis(
      petId: petId,
      frequentAllergens: frequentAllergens.take(5).toList(),
      allergenFrequency: allergenFreq,
      trends: trends,
      predictedRisks: predictedRisks,
      patternConfidence: confidence,
    );
  }

  @override
  Future<List<ProductEntity>> recommendAlternativeProducts({
    required List<String> avoidIngredients,
    String? petType,
    String? category,
  }) async {
    // 데이터소스에서 제품 목록 조회
    final allProducts = await _datasource.getAllProducts(
      petType: petType,
      category: category,
    );

    // 회피 성분이 포함되지 않은 제품만 필터링
    final safeProducts = allProducts.where((product) {
      return !_containsAvoidIngredients(product, avoidIngredients);
    }).toList();

    // 안전도와 인기도에 따라 정렬
    safeProducts.sort((a, b) {
      final safetyA = _calculateProductSafety(a, avoidIngredients);
      final safetyB = _calculateProductSafety(b, avoidIngredients);

      if (safetyA != safetyB) {
        return safetyB.compareTo(safetyA);
      }

      // 안전도가 같으면 평점순
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    });

    return safeProducts.take(20).toList();
  }

  @override
  Future<AllergyReport> generateAllergyReport({
    required String petId,
    required AllergyAnalysisResult analysisResult,
  }) async {
    final petInfo = await _datasource.getPetInfo(petId);
    final alternatives = await recommendAlternativeProducts(
      avoidIngredients: analysisResult.suspectedIngredients,
      petType: petInfo['type'],
    );

    final report = AllergyReport(
      id: _generateReportId(),
      petId: petId,
      petName: petInfo['name'] ?? 'Unknown',
      analysisResult: analysisResult,
      recommendations: _generateDetailedRecommendations(analysisResult),
      alternativeProducts: alternatives.take(10).toList(),
      avoidanceGuidelines: _generateAvoidanceGuidelines(analysisResult),
      generatedAt: DateTime.now(),
    );

    // 보고서 저장
    await _datasource.saveAllergyReport(report);

    return report;
  }

  @override
  Future<List<AllergyAnalysisResult>> getAnalysisHistory(String petId) async {
    try {
      return await _datasource.getAnalysisHistory(petId);
    } catch (e) {
      return [];
    }
  }

  // Helper methods

  IngredientRisk _getDefaultRisk(String ingredient) {
    // 일반적인 알레르기 성분 기본 위험도
    final commonAllergens = {
      '닭고기': RiskLevel.moderate,
      '소고기': RiskLevel.moderate,
      '밀': RiskLevel.high,
      '옥수수': RiskLevel.moderate,
      '콩': RiskLevel.moderate,
    };

    final level = commonAllergens[ingredient] ?? RiskLevel.low;

    return IngredientRisk(
      ingredient: ingredient,
      level: level,
      score: _levelToScore(level),
      reason: '일반적인 알레르기 위험도 기준',
      commonReactions: _getCommonReactions(ingredient),
    );
  }

  double _levelToScore(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return 1.0;
      case RiskLevel.high:
        return 0.8;
      case RiskLevel.moderate:
        return 0.5;
      case RiskLevel.low:
        return 0.2;
    }
  }

  List<String> _getCommonReactions(String ingredient) {
    final reactions = {
      '닭고기': ['피부염', '가려움', '소화불량'],
      '밀': ['소화불량', '설사', '구토'],
      '콩': ['가스', '소화불량', '피부염'],
    };

    return reactions[ingredient] ?? ['일반적인 알레르기 반응'];
  }

  Future<List<AllergyTrend>> _analyzeTrends(List<AllergyRecord> history) async {
    // 간단한 트렌드 분석
    final trends = <AllergyTrend>[];

    if (history.length >= 3) {
      final recent = history.take(history.length ~/ 2).toList();
      final older = history.skip(history.length ~/ 2).toList();

      final recentAllergens = recent.expand((r) => r.products).toSet();
      final olderAllergens = older.expand((r) => r.products).toSet();

      final increasing = recentAllergens.difference(olderAllergens).toList();
      final decreasing = olderAllergens.difference(recentAllergens).toList();

      trends.add(
        AllergyTrend(
          period: '최근 vs 과거',
          increasingAllergens: increasing,
          decreasingAllergens: decreasing,
          analysis: increasing.isNotEmpty
              ? '새로운 알레르기 패턴이 발견되었습니다'
              : '알레르기 패턴이 안정적입니다',
        ),
      );
    }

    return trends;
  }

  Future<List<String>> _predictFutureRisks(List<AllergyRecord> history) async {
    // 과거 패턴을 기반으로 미래 위험 예측
    final productFreq = <String, int>{};
    for (final record in history) {
      for (final product in record.products) {
        productFreq[product] = (productFreq[product] ?? 0) + 1;
      }
    }

    // 빈도가 높은 제품들의 관련 성분 예측
    final predictions = <String>[];
    productFreq.entries.where((e) => e.value > 1).forEach((e) {
      predictions.addAll(_getRelatedIngredients(e.key));
    });

    return predictions.toSet().take(5).toList();
  }

  List<String> _getRelatedIngredients(String product) {
    // 제품명에서 관련 성분 추출
    final related = <String>[];

    if (product.contains('닭') || product.contains('치킨')) {
      related.addAll(['가금류', '닭고기 부산물']);
    }

    if (product.contains('소') || product.contains('비프')) {
      related.addAll(['쇠고기', '소고기 부산물']);
    }

    return related;
  }

  double _calculatePatternConfidence(
    List<AllergyRecord> history,
    List<String> frequentAllergens,
  ) {
    if (history.length < 3) return 0.3;
    if (frequentAllergens.isEmpty) return 0.2;

    final consistency = frequentAllergens.length / history.length;
    return (consistency * 0.7 + (history.length / 10) * 0.3).clamp(0.0, 1.0);
  }

  bool _containsAvoidIngredients(
    ProductEntity product,
    List<String> avoidIngredients,
  ) {
    final productName = product.name.toLowerCase();
    return avoidIngredients.any(
      (avoid) => productName.contains(avoid.toLowerCase()),
    );
  }

  double _calculateProductSafety(
    ProductEntity product,
    List<String> avoidIngredients,
  ) {
    if (_containsAvoidIngredients(product, avoidIngredients)) {
      return 0.0;
    }
    return 1.0;
  }

  List<String> _generateDetailedRecommendations(
    AllergyAnalysisResult analysisResult,
  ) {
    final recommendations = <String>[];

    recommendations.addAll(analysisResult.recommendations);

    // 추가 상세 권장사항
    recommendations.addAll([
      '의심 성분이 포함된 제품 사용 즉시 중단',
      '새로운 사료 도입 시 7-10일간 점진적으로 교체',
      '알레르기 증상 일지 작성 권장',
      '정기적인 수의사 상담 및 알레르기 테스트',
    ]);

    return recommendations.toSet().toList();
  }

  List<String> _generateAvoidanceGuidelines(
    AllergyAnalysisResult analysisResult,
  ) {
    return analysisResult.suspectedIngredients
        .map((ingredient) => '$ingredient 성분 완전 회피')
        .toList();
  }

  String _generateReportId() {
    return 'report_${DateTime.now().millisecondsSinceEpoch}';
  }
}
