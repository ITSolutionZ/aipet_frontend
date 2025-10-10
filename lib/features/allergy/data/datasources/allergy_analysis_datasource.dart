import '../../../allergy/domain/entities/product_entity.dart';
import '../../../allergy/domain/entities/allergy_analysis_entities.dart';

/// 알레르기 분석 데이터소스 인터페이스
abstract class AllergyAnalysisDatasource {
  /// 성분별 위험도 데이터 조회
  Future<Map<String, IngredientRisk>> getIngredientRiskData(List<String> ingredients);

  /// 모든 제품 목록 조회
  Future<List<ProductEntity>> getAllProducts({
    String? petType,
    String? category,
  });

  /// 펫 정보 조회
  Future<Map<String, dynamic>> getPetInfo(String petId);

  /// 기본 분석 수행 (AI 실패 시 폴백)
  Future<AllergyAnalysisResult> performBasicAnalysis(
    List<ProductEntity> allergyProducts,
    List<ProductEntity> nonAllergyProducts,
  );

  /// 분석 결과 저장
  Future<void> saveAnalysisResult(String petId, AllergyAnalysisResult result);

  /// 알레르기 리포트 저장
  Future<void> saveAllergyReport(AllergyReport report);
}

/// Local 알레르기 분석 데이터소스
abstract class AllergyAnalysisLocalDatasource extends AllergyAnalysisDatasource {
  /// 캐시된 성분 위험도 데이터 조회
  Future<Map<String, IngredientRisk>> getCachedIngredientRiskData();

  /// 성분 위험도 데이터 캐시
  Future<void> cacheIngredientRiskData(Map<String, IngredientRisk> riskData);

  /// 로컬 제품 데이터 조회
  Future<List<ProductEntity>> getLocalProducts();

  /// 분석 기록 조회
  Future<List<AllergyAnalysisResult>> getAnalysisHistory(String petId);
}

/// Remote 알레르기 분석 데이터소스
abstract class AllergyAnalysisRemoteDatasource extends AllergyAnalysisDatasource {
  /// 서버에서 성분 위험도 데이터 조회
  Future<Map<String, IngredientRisk>> fetchIngredientRiskData(List<String> ingredients);

  /// 서버에서 제품 목록 조회
  Future<List<ProductEntity>> fetchProducts({
    String? petType,
    String? category,
  });

  /// 서버에 분석 결과 업로드
  Future<void> uploadAnalysisResult(String petId, AllergyAnalysisResult result);

  /// 서버에 알레르기 리포트 업로드
  Future<void> uploadAllergyReport(AllergyReport report);
}

