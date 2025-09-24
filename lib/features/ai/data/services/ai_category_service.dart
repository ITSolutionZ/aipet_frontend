import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/ai/ai_categories_mock_data.dart';

/// AI 카테고리 데이터 관리 서비스
///
/// 카테고리 데이터를 중앙에서 관리하며, 향후 데이터베이스나 설정 파일에서 로드할 수 있도록 설계
class AiCategoryService {
  /// 기본 카테고리 목록
  static List<AiCategoryEntity> getDefaultCategories() {
    return AiCategoriesMockData.getDefaultCategories();
  }

  /// ID로 카테고리 찾기
  static AiCategoryEntity? findById(String id) {
    return AiCategoriesMockData.findById(id);
  }

  /// 카테고리 이름으로 찾기
  static AiCategoryEntity? findByName(String name) {
    return AiCategoriesMockData.findByName(name);
  }
}
