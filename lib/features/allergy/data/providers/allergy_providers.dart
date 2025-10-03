import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/features/allergy/domain/services/allergy_analysis_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergy_providers.freezed.dart';
part 'allergy_providers.g.dart';

/// 알레르기 제품 데이터
@freezed
class AllergyProductData with _$AllergyProductData {
  const factory AllergyProductData({
    /// 알레르기 발생한 제품들
    @Default([]) List<ProductEntity> allergyProducts,

    /// 알레르기 없었던 제품들
    @Default([]) List<ProductEntity> nonAllergyProducts,
  }) = _AllergyProductData;
}

/// 선택된 알레르기 제품들을 관리하는 Provider
/// petId를 키로 각 펫의 알레르기 데이터를 관리
@riverpod
class SelectedAllergyProducts extends _$SelectedAllergyProducts {
  @override
  Map<String, AllergyProductData> build() {
    return {};
  }

  /// 제품 추가
  void addProduct(String petId, ProductEntity product, bool hasAllergy) {
    final currentData = state[petId] ?? const AllergyProductData();

    if (hasAllergy) {
      // 알레르기 있던 제품에 추가
      final allergyProducts = [...currentData.allergyProducts];

      // 중복 체크
      if (allergyProducts.any((p) => p.id == product.id)) {
        return;
      }

      allergyProducts.add(product);

      state = {
        ...state,
        petId: currentData.copyWith(allergyProducts: allergyProducts),
      };
    } else {
      // 알레르기 없던 제품에 추가
      final nonAllergyProducts = [...currentData.nonAllergyProducts];

      // 중복 체크
      if (nonAllergyProducts.any((p) => p.id == product.id)) {
        return;
      }

      nonAllergyProducts.add(product);

      state = {
        ...state,
        petId: currentData.copyWith(nonAllergyProducts: nonAllergyProducts),
      };
    }
  }

  /// 제품 제거
  void removeProduct(String petId, String productId, bool hasAllergy) {
    final currentData = state[petId] ?? const AllergyProductData();

    if (hasAllergy) {
      final allergyProducts = currentData.allergyProducts
          .where((p) => p.id != productId)
          .toList();

      state = {
        ...state,
        petId: currentData.copyWith(allergyProducts: allergyProducts),
      };
    } else {
      final nonAllergyProducts = currentData.nonAllergyProducts
          .where((p) => p.id != productId)
          .toList();

      state = {
        ...state,
        petId: currentData.copyWith(nonAllergyProducts: nonAllergyProducts),
      };
    }
  }

  /// 특정 펫의 알레르기 데이터 가져오기
  AllergyProductData? getDataByPet(String petId) {
    return state[petId];
  }

  /// 특정 펫의 알레르기 있던 제품 카테고리별로 가져오기
  Map<String, List<ProductEntity>> getAllergyProductsByCategory(String petId) {
    final data = state[petId];
    if (data == null) return {};

    return _groupByCategory(data.allergyProducts);
  }

  /// 특정 펫의 알레르기 없던 제품 카테고리별로 가져오기
  Map<String, List<ProductEntity>> getNonAllergyProductsByCategory(
    String petId,
  ) {
    final data = state[petId];
    if (data == null) return {};

    return _groupByCategory(data.nonAllergyProducts);
  }

  /// 카테고리별 그룹핑 헬퍼 함수
  Map<String, List<ProductEntity>> _groupByCategory(
    List<ProductEntity> products,
  ) {
    final Map<String, List<ProductEntity>> categoryMap = {
      'フード': [],
      'サプリメント': [],
      'おやつ': [],
      '生食': [],
    };

    for (final product in products) {
      if (categoryMap.containsKey(product.category)) {
        categoryMap[product.category]!.add(product);
      }
    }

    return categoryMap;
  }

  /// 특정 펫의 모든 제품 삭제
  void clearProducts(String petId) {
    final newState = Map<String, AllergyProductData>.from(state);
    newState.remove(petId);
    state = newState;
  }

  /// OpenAI로 알레르기 원료 분석
  Future<Map<String, dynamic>> analyzeAllergyIngredients(
    String petId,
    AllergyAnalysisService analysisService,
  ) async {
    final data = state[petId];
    if (data == null) {
      return {
        'error': 'No data found',
        'allergyProducts': 0,
        'nonAllergyProducts': 0,
        'suspectedIngredients': <String>[],
        'analysis': 'データが見つかりません',
        'confidence': 0.0,
        'recommendations': <String>[],
      };
    }

    // OpenAI API로 분석
    try {
      final result = await analysisService.analyzeIngredients(
        allergyProducts: data.allergyProducts,
        nonAllergyProducts: data.nonAllergyProducts,
      );

      return {
        'allergyProducts': data.allergyProducts.length,
        'nonAllergyProducts': data.nonAllergyProducts.length,
        'suspectedIngredients': result.suspectedIngredients,
        'analysis': result.analysis,
        'confidence': result.confidence,
        'recommendations': result.recommendations,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'allergyProducts': data.allergyProducts.length,
        'nonAllergyProducts': data.nonAllergyProducts.length,
        'suspectedIngredients': <String>[],
        'analysis': '分析中にエラーが発生しました: ${e.toString()}',
        'confidence': 0.0,
        'recommendations': <String>[],
      };
    }
  }
}
