import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/constants/allergy_constants.dart';
import '../../domain/entities/allergy_analysis_entities.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/allergy_analysis_repository.dart';
import '../../domain/services/allergy_analysis_service.dart';
import '../datasources/allergy_analysis_datasource.dart';
import '../repositories/allergy_analysis_repository_impl.dart';
import 'allergy_service_providers.dart';

part 'allergy_providers.g.dart';

/// 펫별 알레르기 제품 데이터
class AllergyProductData {
  final List<ProductEntity> allergyProducts;
  final List<ProductEntity> nonAllergyProducts;

  const AllergyProductData({
    this.allergyProducts = const [],
    this.nonAllergyProducts = const [],
  });

  AllergyProductData copyWith({
    List<ProductEntity>? allergyProducts,
    List<ProductEntity>? nonAllergyProducts,
  }) {
    return AllergyProductData(
      allergyProducts: allergyProducts ?? this.allergyProducts,
      nonAllergyProducts: nonAllergyProducts ?? this.nonAllergyProducts,
    );
  }
}

/// 선택된 알레르기 제품 관리 Provider
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
      final updated = List<ProductEntity>.from(currentData.allergyProducts)
        ..add(product);
      state = {...state, petId: currentData.copyWith(allergyProducts: updated)};
    } else {
      final updated = List<ProductEntity>.from(currentData.nonAllergyProducts)
        ..add(product);
      state = {
        ...state,
        petId: currentData.copyWith(nonAllergyProducts: updated),
      };
    }
  }

  /// 제품 제거
  void removeProduct(String petId, String productId, bool isAllergyTab) {
    final currentData = state[petId];
    if (currentData == null) return;

    if (isAllergyTab) {
      final updated = currentData.allergyProducts
          .where((p) => p.id != productId)
          .toList();
      state = {...state, petId: currentData.copyWith(allergyProducts: updated)};
    } else {
      final updated = currentData.nonAllergyProducts
          .where((p) => p.id != productId)
          .toList();
      state = {
        ...state,
        petId: currentData.copyWith(nonAllergyProducts: updated),
      };
    }
  }

  /// 알레르기 성분 분석 (Result 패턴)
  Future<Result<Map<String, dynamic>>> analyzeAllergyIngredients(
    String petId,
    AllergyAnalysisService service,
  ) async {
    try {
      final data = state[petId];
      if (data == null) {
        return Result.failure(AllergyConstants.noProductsSelectedError);
      }

      if (data.allergyProducts.isEmpty) {
        return Result.failure(AllergyConstants.noAllergyProductsError);
      }

      if (data.nonAllergyProducts.isEmpty) {
        return Result.failure(AllergyConstants.noNonAllergyProductsError);
      }

      final result = await service.analyzeIngredients(
        allergyProducts: data.allergyProducts,
        nonAllergyProducts: data.nonAllergyProducts,
      );

      final analysisData = {
        'suspectedIngredients': result.suspectedIngredients,
        'analysis': result.analysis,
        'recommendations': result.recommendations,
        'confidence': result.confidence,
        'allergyProducts': data.allergyProducts.length,
        'nonAllergyProducts': data.nonAllergyProducts.length,
      };

      return Result.success('分析が正常に完了しました', analysisData);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('アレルギー分析エラー: $error');
        debugPrint('StackTrace: $stackTrace');
      }
      return Result.failure(
        AllergyConstants.analysisErrorMessage,
        error is Exception ? error : Exception(error.toString()),
      );
    }
  }
}

// Datasource Implementations
class AllergyAnalysisDatasourceImpl implements AllergyAnalysisDatasource {
  @override
  Future<Map<String, IngredientRisk>> getIngredientRiskData(
    List<String> ingredients,
  ) async {
    return {};
  }

  @override
  Future<List<ProductEntity>> getAllProducts({
    String? petType,
    String? category,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getPetInfo(String petId) async {
    return {};
  }

  @override
  Future<AllergyAnalysisResult> performBasicAnalysis(
    List<ProductEntity> allergyProducts,
    List<ProductEntity> nonAllergyProducts,
  ) async {
    return const AllergyAnalysisResult(
      suspectedIngredients: [],
      analysis: '기본 분석 결과',
      recommendations: [],
      confidence: 0.5,
    );
  }

  @override
  Future<void> saveAnalysisResult(
    String petId,
    AllergyAnalysisResult result,
  ) async {}

  @override
  Future<void> saveAllergyReport(AllergyReport report) async {}
}

class AllergyAnalysisLocalDatasourceImpl
    implements AllergyAnalysisLocalDatasource {
  @override
  Future<Map<String, IngredientRisk>> getIngredientRiskData(
    List<String> ingredients,
  ) async {
    return {};
  }

  @override
  Future<List<ProductEntity>> getAllProducts({
    String? petType,
    String? category,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getPetInfo(String petId) async {
    return {};
  }

  @override
  Future<AllergyAnalysisResult> performBasicAnalysis(
    List<ProductEntity> allergyProducts,
    List<ProductEntity> nonAllergyProducts,
  ) async {
    return const AllergyAnalysisResult(
      suspectedIngredients: [],
      analysis: '로컬 분석 결과',
      recommendations: [],
      confidence: 0.7,
    );
  }

  @override
  Future<void> saveAnalysisResult(
    String petId,
    AllergyAnalysisResult result,
  ) async {}

  @override
  Future<void> saveAllergyReport(AllergyReport report) async {}

  @override
  Future<Map<String, IngredientRisk>> getCachedIngredientRiskData() async {
    return {};
  }

  @override
  Future<void> cacheIngredientRiskData(
    Map<String, IngredientRisk> riskData,
  ) async {}

  @override
  Future<List<ProductEntity>> getLocalProducts() async {
    return [];
  }

  @override
  Future<List<AllergyAnalysisResult>> getAnalysisHistory(String petId) async {
    return [];
  }
}

// Datasource Providers
@riverpod
AllergyAnalysisDatasource allergyAnalysisDatasource(Ref ref) {
  return AllergyAnalysisDatasourceImpl();
}

@riverpod
AllergyAnalysisLocalDatasource allergyAnalysisLocalDatasource(Ref ref) {
  return AllergyAnalysisLocalDatasourceImpl();
}

// Repository Providers
@riverpod
AllergyAnalysisRepository allergyAnalysisRepository(Ref ref) {
  final service = ref.watch(allergyAnalysisServiceProvider);
  final datasource = ref.watch(allergyAnalysisDatasourceProvider);

  return AllergyAnalysisRepositoryImpl(service, datasource);
}

/// 제품 목록 Provider
@riverpod
Future<List<ProductEntity>> allergyProducts(Ref ref, {String? category}) async {
  final datasource = ref.watch(allergyAnalysisLocalDatasourceProvider);
  return datasource.getLocalProducts();
}

/// 브랜드 정보 조회 Provider (제품의 brandId로 브랜드명 찾기)
@riverpod
String getBrandName(Ref ref, String brandId) {
  // TODO: 실제로는 brand repository나 datasource에서 가져와야 함
  // 현재는 임시로 brandId를 반환
  return brandId;
}
