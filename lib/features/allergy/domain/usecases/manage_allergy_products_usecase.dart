import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/allergy_providers.dart';
import '../entities/product_entity.dart';
import '../repositories/allergy_analysis_repository.dart';

part 'manage_allergy_products_usecase.g.dart';

/// 알레르기 제품 관리 Use Case
class ManageAllergyProductsUseCase {
  final AllergyAnalysisRepository _repository;

  const ManageAllergyProductsUseCase(this._repository);

  /// 제품 추천 리스트 생성
  Future<ProductRecommendationResult> generateProductRecommendations({
    required String petId,
    required List<String> avoidIngredients,
    String? petType,
    String? category,
    int limit = 20,
  }) async {
    // 비즈니스 로직: 입력 검증
    if (avoidIngredients.isEmpty) {
      throw Exception('避ける成分を最低1つ以上指定してください');
    }

    // 1. 대체 제품 추천
    final alternativeProducts = await _repository.recommendAlternativeProducts(
      avoidIngredients: avoidIngredients,
      petType: petType,
      category: category,
    );

    // 2. 제품별 안전도 평가
    final productSafetyScores = await _evaluateProductSafety(
      alternativeProducts,
      avoidIngredients,
      petType,
    );

    // 3. 가격대별 분류
    final priceCategories = _categorizeByPrice(alternativeProducts);

    // 4. 브랜드별 분류
    final brandCategories = _categorizeByBrand(alternativeProducts);

    // 5. 최종 추천 순위 결정
    final rankedProducts = _rankProducts(
      alternativeProducts,
      productSafetyScores,
      avoidIngredients,
    );

    return ProductRecommendationResult(
      recommendedProducts: rankedProducts.take(limit).toList(),
      safetyScores: productSafetyScores,
      priceCategories: priceCategories,
      brandCategories: brandCategories,
      totalAvailableProducts: alternativeProducts.length,
      avoidanceCompliance: _calculateAvoidanceCompliance(
        rankedProducts,
        avoidIngredients,
      ),
    );
  }

  /// 제품 안전성 재평가
  Future<ProductSafetyUpdate> reevaluateProductSafety({
    required String petId,
    required List<ProductEntity> currentProducts,
    required List<String> newAllergyFindings,
  }) async {
    final unsafeProducts = <ProductEntity>[];
    final warningProducts = <ProductEntity>[];
    final safeProducts = <ProductEntity>[];

    for (final product in currentProducts) {
      final safetyResult = await _checkProductSafety(
        product,
        newAllergyFindings,
      );

      switch (safetyResult.level) {
        case SafetyLevel.unsafe:
          unsafeProducts.add(product);
          break;
        case SafetyLevel.warning:
          warningProducts.add(product);
          break;
        case SafetyLevel.safe:
          safeProducts.add(product);
          break;
      }
    }

    return ProductSafetyUpdate(
      unsafeProducts: unsafeProducts,
      warningProducts: warningProducts,
      safeProducts: safeProducts,
      newAllergyFindings: newAllergyFindings,
      actionRequired: unsafeProducts.isNotEmpty || warningProducts.isNotEmpty,
      updatedAt: DateTime.now(),
    );
  }

  /// 제품 비교 분석
  Future<ProductComparisonResult> compareProducts({
    required List<ProductEntity> products,
    required List<String> avoidIngredients,
    String? petType,
  }) async {
    final comparisons = <ProductComparison>[];

    for (final product in products) {
      final safety = await _checkProductSafety(product, avoidIngredients);
      final nutritionScore = _calculateNutritionScore(product);
      final priceScore = _calculatePriceScore(product);

      comparisons.add(
        ProductComparison(
          product: product,
          safetyScore: safety.score,
          nutritionScore: nutritionScore,
          priceScore: priceScore,
          overallScore: _calculateOverallScore(
            safety.score,
            nutritionScore,
            priceScore,
          ),
          pros: _identifyPros(product, safety),
          cons: _identifyCons(product, safety),
        ),
      );
    }

    // 점수순 정렬
    comparisons.sort((a, b) => b.overallScore.compareTo(a.overallScore));

    return ProductComparisonResult(
      comparisons: comparisons,
      bestChoice: comparisons.isNotEmpty ? comparisons.first : null,
      avgSafetyScore: _calculateAverageScore(
        comparisons.map((c) => c.safetyScore).toList(),
      ),
      avgNutritionScore: _calculateAverageScore(
        comparisons.map((c) => c.nutritionScore).toList(),
      ),
      avgPriceScore: _calculateAverageScore(
        comparisons.map((c) => c.priceScore).toList(),
      ),
    );
  }

  // Helper methods

  Future<Map<ProductEntity, double>> _evaluateProductSafety(
    List<ProductEntity> products,
    List<String> avoidIngredients,
    String? petType,
  ) async {
    final safetyScores = <ProductEntity, double>{};

    for (final product in products) {
      final safety = await _checkProductSafety(product, avoidIngredients);
      safetyScores[product] = safety.score;
    }

    return safetyScores;
  }

  Future<ProductSafetyResult> _checkProductSafety(
    ProductEntity product,
    List<String> avoidIngredients,
  ) async {
    // 제품 성분과 회피 성분 비교
    final productIngredients = product.ingredients?.toLowerCase() ?? '';
    final dangerousIngredients = <String>[];

    for (final avoid in avoidIngredients) {
      if (productIngredients.contains(avoid.toLowerCase())) {
        dangerousIngredients.add(avoid);
      }
    }

    SafetyLevel level;
    double score;

    if (dangerousIngredients.isNotEmpty) {
      level = SafetyLevel.unsafe;
      score = 0.0;
    } else if (_hasRelatedIngredients(productIngredients, avoidIngredients)) {
      level = SafetyLevel.warning;
      score = 0.5;
    } else {
      level = SafetyLevel.safe;
      score = 1.0;
    }

    return ProductSafetyResult(
      level: level,
      score: score,
      dangerousIngredients: dangerousIngredients,
      warnings: _generateSafetyWarnings(level, dangerousIngredients),
    );
  }

  bool _hasRelatedIngredients(String ingredients, List<String> avoidList) {
    // 관련 성분 체크 로직
    final relatedMap = {
      '鶏肉': ['チキン', 'ガムレウ', 'ポウルトリ'],
      '牛肉': ['ビーフ', 'ショウギ'],
      '麦': ['グルテン', 'ソマック'],
    };

    for (final avoid in avoidList) {
      final related = relatedMap[avoid] ?? [];
      if (related.any((r) => ingredients.contains(r))) {
        return true;
      }
    }

    return false;
  }

  Map<String, List<ProductEntity>> _categorizeByPrice(
    List<ProductEntity> products,
  ) {
    final categories = <String, List<ProductEntity>>{
      'budget': [],
      'mid-range': [],
      'premium': [],
    };

    for (final product in products) {
      final price = product.price;
      if (price < 30000) {
        categories['budget']!.add(product);
      } else if (price < 80000) {
        categories['mid-range']!.add(product);
      } else {
        categories['premium']!.add(product);
      }
    }

    return categories;
  }

  Map<String, List<ProductEntity>> _categorizeByBrand(
    List<ProductEntity> products,
  ) {
    final categories = <String, List<ProductEntity>>{};

    for (final product in products) {
      final brand = product.brand?.name ?? 'Unknown';
      categories.putIfAbsent(brand, () => []).add(product);
    }

    return categories;
  }

  List<ProductEntity> _rankProducts(
    List<ProductEntity> products,
    Map<ProductEntity, double> safetyScores,
    List<String> avoidIngredients,
  ) {
    return products..sort((a, b) {
      final safetyA = safetyScores[a] ?? 0;
      final safetyB = safetyScores[b] ?? 0;

      // 안전도 우선, 그 다음 가격
      if (safetyA != safetyB) {
        return safetyB.compareTo(safetyA);
      }

      final priceA = a.price;
      final priceB = b.price;
      return priceA.compareTo(priceB);
    });
  }

  double _calculateAvoidanceCompliance(
    List<ProductEntity> products,
    List<String> avoidIngredients,
  ) {
    if (products.isEmpty) return 0.0;

    var compliantCount = 0;
    for (final product in products) {
      if (!_containsAvoidIngredients(product, avoidIngredients)) {
        compliantCount++;
      }
    }

    return compliantCount / products.length;
  }

  bool _containsAvoidIngredients(
    ProductEntity product,
    List<String> avoidIngredients,
  ) {
    final ingredients = product.ingredients?.toLowerCase() ?? '';
    return avoidIngredients.any(
      (avoid) => ingredients.contains(avoid.toLowerCase()),
    );
  }

  double _calculateNutritionScore(ProductEntity product) {
    // 영양 점수 계산 로직
    return 0.8; // 임시값
  }

  double _calculatePriceScore(ProductEntity product) {
    // 가격 점수 계산 (가성비)
    final price = product.price;
    if (price < 30000) return 1.0;
    if (price < 80000) return 0.7;
    return 0.4;
  }

  double _calculateOverallScore(double safety, double nutrition, double price) {
    // 가중평균: 안전도 50%, 영양 30%, 가격 20%
    return (safety * 0.5) + (nutrition * 0.3) + (price * 0.2);
  }

  List<String> _identifyPros(
    ProductEntity product,
    ProductSafetyResult safety,
  ) {
    final pros = <String>[];

    if (safety.level == SafetyLevel.safe) {
      pros.add('アレルギーを引き起こす成分が含まれていません');
    }

    if (product.price < 50000) {
      pros.add('合理的な価格');
    }

    return pros;
  }

  List<String> _identifyCons(
    ProductEntity product,
    ProductSafetyResult safety,
  ) {
    final cons = <String>[];

    if (safety.level == SafetyLevel.unsafe) {
      cons.add('アレルギーを引き起こす成分が含まれています');
    }

    if (product.price > 100000) {
      cons.add('高い価格');
    }

    return cons;
  }

  double _calculateAverageScore(List<double> scores) {
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  List<String> _generateSafetyWarnings(
    SafetyLevel level,
    List<String> dangerousIngredients,
  ) {
    switch (level) {
      case SafetyLevel.unsafe:
        return ['この商品にはアレルギーを引き起こす成分が含まれています', '使用を推奨しません'];
      case SafetyLevel.warning:
        return ['関連成分が含まれているため注意が必要です', '少量から始めて反応を観察してください'];
      case SafetyLevel.safe:
        return [];
    }
  }
}

// Data classes

class ProductRecommendationResult {
  final List<ProductEntity> recommendedProducts;
  final Map<ProductEntity, double> safetyScores;
  final Map<String, List<ProductEntity>> priceCategories;
  final Map<String, List<ProductEntity>> brandCategories;
  final int totalAvailableProducts;
  final double avoidanceCompliance;

  const ProductRecommendationResult({
    required this.recommendedProducts,
    required this.safetyScores,
    required this.priceCategories,
    required this.brandCategories,
    required this.totalAvailableProducts,
    required this.avoidanceCompliance,
  });
}

class ProductSafetyUpdate {
  final List<ProductEntity> unsafeProducts;
  final List<ProductEntity> warningProducts;
  final List<ProductEntity> safeProducts;
  final List<String> newAllergyFindings;
  final bool actionRequired;
  final DateTime updatedAt;

  const ProductSafetyUpdate({
    required this.unsafeProducts,
    required this.warningProducts,
    required this.safeProducts,
    required this.newAllergyFindings,
    required this.actionRequired,
    required this.updatedAt,
  });
}

class ProductComparisonResult {
  final List<ProductComparison> comparisons;
  final ProductComparison? bestChoice;
  final double avgSafetyScore;
  final double avgNutritionScore;
  final double avgPriceScore;

  const ProductComparisonResult({
    required this.comparisons,
    this.bestChoice,
    required this.avgSafetyScore,
    required this.avgNutritionScore,
    required this.avgPriceScore,
  });
}

class ProductComparison {
  final ProductEntity product;
  final double safetyScore;
  final double nutritionScore;
  final double priceScore;
  final double overallScore;
  final List<String> pros;
  final List<String> cons;

  const ProductComparison({
    required this.product,
    required this.safetyScore,
    required this.nutritionScore,
    required this.priceScore,
    required this.overallScore,
    required this.pros,
    required this.cons,
  });
}

class ProductSafetyResult {
  final SafetyLevel level;
  final double score;
  final List<String> dangerousIngredients;
  final List<String> warnings;

  const ProductSafetyResult({
    required this.level,
    required this.score,
    required this.dangerousIngredients,
    required this.warnings,
  });
}

enum SafetyLevel { safe, warning, unsafe }

/// Use Case Provider
@riverpod
ManageAllergyProductsUseCase manageAllergyProductsUseCase(Ref ref) {
  final repository = ref.watch(allergyAnalysisRepositoryProvider);
  return ManageAllergyProductsUseCase(repository);
}
