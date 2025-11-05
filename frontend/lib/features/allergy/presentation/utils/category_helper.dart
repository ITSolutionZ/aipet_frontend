import '../../../../../features/allergy/domain/constants/allergy_constants.dart';

/// 카테고리 판별 유틸리티
class CategoryHelper {
  // Private constructor to prevent instantiation
  CategoryHelper._();

  /// 프리푸드 카테고리 판별
  static bool isFoodCategory(String category) {
    return AllergyConstants.foodCategoryKeywords.any(
      (keyword) => category == keyword || category.contains(keyword),
    );
  }

  /// 서플리먼트 카테고리 판별
  static bool isSupplementCategory(String category) {
    return AllergyConstants.supplementCategoryKeywords.any(
      (keyword) => category == keyword || category.contains(keyword),
    );
  }

  /// 스낵 카테고리 판별
  static bool isSnackCategory(String category) {
    return AllergyConstants.snackCategoryKeywords.any(
      (keyword) => category == keyword || category.contains(keyword),
    );
  }

  /// 생식 카테고리 판별
  static bool isRawFoodCategory(String category) {
    return AllergyConstants.rawFoodCategoryKeywords.any(
      (keyword) => category == keyword || category.contains(keyword),
    );
  }

  /// 카테고리별 제품 분류
  static Map<String, List<T>> categorizeProducts<T>({
    required List<T> products,
    required String Function(T) getCategoryName,
  }) {
    final categorized = <String, List<T>>{
      AllergyConstants.foodCategoryLabel: [],
      AllergyConstants.supplementCategoryLabel: [],
      AllergyConstants.snackCategoryLabel: [],
      AllergyConstants.rawFoodCategoryLabel: [],
    };

    for (final product in products) {
      final category = getCategoryName(product);

      if (isFoodCategory(category)) {
        categorized[AllergyConstants.foodCategoryLabel]!.add(product);
      } else if (isSupplementCategory(category)) {
        categorized[AllergyConstants.supplementCategoryLabel]!.add(product);
      } else if (isSnackCategory(category)) {
        categorized[AllergyConstants.snackCategoryLabel]!.add(product);
      } else if (isRawFoodCategory(category)) {
        categorized[AllergyConstants.rawFoodCategoryLabel]!.add(product);
      }
    }

    return categorized;
  }
}
