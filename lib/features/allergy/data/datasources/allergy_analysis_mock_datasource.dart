import '../../../allergy/domain/entities/allergy_analysis_entities.dart';
import '../../../allergy/domain/entities/product_entity.dart';
import 'allergy_analysis_datasource.dart';

/// Mock 알레르기 분석 데이터소스 구현체
class AllergyAnalysisMockDatasource implements AllergyAnalysisLocalDatasource {
  // Mock 데이터 저장소
  final Map<String, IngredientRisk> _mockRiskData = {};
  final List<ProductEntity> _mockProducts = [];
  final Map<String, Map<String, dynamic>> _mockPetInfo = {};
  final Map<String, List<AllergyAnalysisResult>> _analysisHistory = {};
  final List<AllergyReport> _savedReports = [];

  AllergyAnalysisMockDatasource() {
    _initializeMockData();
  }

  @override
  Future<Map<String, IngredientRisk>> getIngredientRiskData(
    List<String> ingredients,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

    final result = <String, IngredientRisk>{};
    for (final ingredient in ingredients) {
      if (_mockRiskData.containsKey(ingredient)) {
        result[ingredient] = _mockRiskData[ingredient]!;
      }
    }
    return result;
  }

  @override
  Future<List<ProductEntity>> getAllProducts({
    String? petType,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filteredProducts = List<ProductEntity>.from(_mockProducts);

    // 카테고리별 필터링
    if (category != null) {
      filteredProducts = filteredProducts
          .where(
            (product) =>
                product.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }

    // petType 필터링은 현재 ProductEntity에 해당 필드가 없으므로 생략
    // 실제 구현에서는 Brand나 다른 방식으로 펫 타입을 구분할 수 있음

    return filteredProducts;
  }

  @override
  Future<Map<String, dynamic>> getPetInfo(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _mockPetInfo[petId] ??
        {'name': '알 수 없는 펫', 'type': '기타', 'age': 0, 'weight': 0.0};
  }

  @override
  Future<AllergyAnalysisResult> performBasicAnalysis(
    List<ProductEntity> allergyProducts,
    List<ProductEntity> nonAllergyProducts,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 간소화된 분석 로직: 제품명을 기반으로 분석
    final suspectedIngredients = <String>[];
    final productNames = allergyProducts
        .map((p) => p.name.toLowerCase())
        .toList();

    // 제품명에서 알레르기 성분 추출
    for (final name in productNames) {
      if (name.contains('닭') || name.contains('치킨')) {
        suspectedIngredients.add('닭고기');
      }
      if (name.contains('소') || name.contains('비프')) {
        suspectedIngredients.add('소고기');
      }
      if (name.contains('밀') || name.contains('글루텐')) {
        suspectedIngredients.add('밀');
      }
      if (name.contains('옥수수')) {
        suspectedIngredients.add('옥수수');
      }
      if (name.contains('콩')) {
        suspectedIngredients.add('콩');
      }
    }

    // 중복 제거
    final uniqueSuspected = suspectedIngredients.toSet().toList();

    // 기본 권장사항 생성
    final recommendations = [
      '의심 성분이 포함된 제품을 피해주세요',
      '새로운 사료 도입 시 점진적으로 바꿔주세요',
      '알레르기 증상 발생 시 즉시 사용을 중단하고 수의사와 상담하세요',
    ];

    if (uniqueSuspected.isNotEmpty) {
      recommendations.insert(0, '${uniqueSuspected.join(", ")} 성분에 특히 주의하세요');
    }

    return AllergyAnalysisResult(
      suspectedIngredients: uniqueSuspected,
      recommendations: recommendations,
      confidence: uniqueSuspected.isNotEmpty ? 0.7 : 0.3,
    );
  }

  @override
  Future<void> saveAnalysisResult(
    String petId,
    AllergyAnalysisResult result,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _analysisHistory.putIfAbsent(petId, () => []);
    _analysisHistory[petId]!.add(result);
  }

  @override
  Future<void> saveAllergyReport(AllergyReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _savedReports.add(report);
  }

  @override
  Future<Map<String, IngredientRisk>> getCachedIngredientRiskData() async {
    return Map.from(_mockRiskData);
  }

  @override
  Future<void> cacheIngredientRiskData(
    Map<String, IngredientRisk> riskData,
  ) async {
    _mockRiskData.addAll(riskData);
  }

  @override
  Future<List<ProductEntity>> getLocalProducts() async {
    return List.from(_mockProducts);
  }

  @override
  Future<List<AllergyAnalysisResult>> getAnalysisHistory(String petId) async {
    return _analysisHistory[petId] ?? [];
  }

  // Mock 데이터 초기화
  void _initializeMockData() {
    // 성분별 위험도 데이터
    _mockRiskData.addAll({
      '닭고기': const IngredientRisk(
        ingredient: '닭고기',
        level: RiskLevel.moderate,
        score: 0.5,
        reason: '일반적인 알레르기 유발 성분',
        commonReactions: ['피부염', '가려움', '소화불량'],
      ),
      '소고기': const IngredientRisk(
        ingredient: '소고기',
        level: RiskLevel.moderate,
        score: 0.5,
        reason: '일반적인 알레르기 유발 성분',
        commonReactions: ['피부염', '소화불량'],
      ),
      '밀': const IngredientRisk(
        ingredient: '밀',
        level: RiskLevel.high,
        score: 0.8,
        reason: '글루텐으로 인한 알레르기 위험성',
        commonReactions: ['소화불량', '설사', '구토'],
      ),
      '옥수수': const IngredientRisk(
        ingredient: '옥수수',
        level: RiskLevel.moderate,
        score: 0.5,
        reason: '일반적인 알레르기 유발 성분',
        commonReactions: ['소화불량', '가스'],
      ),
      '콩': const IngredientRisk(
        ingredient: '콩',
        level: RiskLevel.moderate,
        score: 0.5,
        reason: '단백질 알레르기 위험성',
        commonReactions: ['가스', '소화불량', '피부염'],
      ),
    });

    // Mock 제품 데이터
    _mockProducts.addAll([
      const ProductEntity(
        id: 'product_001',
        name: '로얄캐닌 독 디제스티브 케어',
        price: 45000,
        brandId: 'brand_001',
        category: '사료',
      ),
      const ProductEntity(
        id: 'product_002',
        name: '힐스 z/d 알레르기 케어',
        price: 65000,
        brandId: 'brand_002',
        category: '사료',
      ),
      const ProductEntity(
        id: 'product_003',
        name: '오리젠 독 오리지널',
        price: 89000,
        brandId: 'brand_003',
        category: '사료',
      ),
      const ProductEntity(
        id: 'product_004',
        name: '아카나 싱글 프로테인',
        price: 72000,
        brandId: 'brand_004',
        category: '사료',
      ),
      const ProductEntity(
        id: 'product_005',
        name: '내츄럴코어 에코 라이트',
        price: 35000,
        brandId: 'brand_005',
        category: '사료',
      ),
    ]);

    // Mock 펫 정보
    _mockPetInfo.addAll({
      'pet_001': {
        'name': '뽀삐',
        'type': 'dog',
        'breed': '골든리트리버',
        'age': 3,
        'weight': 25.5,
      },
      'pet_002': {
        'name': '야옹이',
        'type': 'cat',
        'breed': '브리티시숏헤어',
        'age': 2,
        'weight': 4.2,
      },
    });
  }

  // 테스트용 헬퍼 메서드들
  void addMockProduct(ProductEntity product) {
    _mockProducts.add(product);
  }

  void addMockPetInfo(String petId, Map<String, dynamic> info) {
    _mockPetInfo[petId] = info;
  }

  void clearMockData() {
    _mockProducts.clear();
    _mockPetInfo.clear();
    _analysisHistory.clear();
    _savedReports.clear();
  }

  List<AllergyReport> getSavedReports() {
    return List.from(_savedReports);
  }
}
