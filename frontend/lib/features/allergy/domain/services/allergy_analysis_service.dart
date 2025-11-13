import '../entities/allergy_analysis_entities.dart';
import '../entities/product_entity.dart';

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
