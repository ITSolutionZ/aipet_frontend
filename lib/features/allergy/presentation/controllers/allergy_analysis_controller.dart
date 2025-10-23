import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/allergy_analysis_entities.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/analyze_allergy_usecase.dart';
import '../../domain/usecases/manage_allergy_products_usecase.dart';

part 'allergy_analysis_controller.g.dart';

/// 알레르기 분석 상태
class AllergyAnalysisState {
  final bool isLoading;
  final String? error;
  final AllergyAnalysisResult? analysisResult;
  final IngredientRiskAssessment? riskAssessment;
  final List<ProductEntity> recommendedProducts;
  final AllergyReport? report;

  const AllergyAnalysisState({
    this.isLoading = false,
    this.error,
    this.analysisResult,
    this.riskAssessment,
    this.recommendedProducts = const [],
    this.report,
  });

  AllergyAnalysisState copyWith({
    bool? isLoading,
    String? error,
    AllergyAnalysisResult? analysisResult,
    IngredientRiskAssessment? riskAssessment,
    List<ProductEntity>? recommendedProducts,
    AllergyReport? report,
  }) {
    return AllergyAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      analysisResult: analysisResult ?? this.analysisResult,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      report: report ?? this.report,
    );
  }
}

/// 알레르기 분석 컨트롤러
@riverpod
class AllergyAnalysisController extends _$AllergyAnalysisController {
  @override
  AllergyAnalysisState build() {
    return const AllergyAnalysisState();
  }

  /// 제품 기반 알레르기 분석 실행
  Future<void> analyzeProductAllergy({
    required List<ProductEntity> allergyProducts,
    required List<ProductEntity> nonAllergyProducts,
    String? petId,
    String? petType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final analyzeUseCase = ref.read(analyzeAllergyUseCaseProvider);

      // 1. 기본 분석 실행
      final analysis = await analyzeUseCase.analyzeProductAllergy(
        allergyProducts: allergyProducts,
        nonAllergyProducts: nonAllergyProducts,
        petType: petType,
        petId: petId,
      );

      // 2. 위험도 평가 (추후 사용 예정)
      // final riskAssessment = await analyzeUseCase.assessAllergyRisk(
      //   petId: petId ?? 'default',
      //   potentialAllergens: analysis.basicAnalysis.suspectedIngredients,
      // );

      // 3. 대체 제품 추천
      final recommendedProducts = analysis.alternativeProducts;

      // 4. 보고서 생성 (펫 ID가 있는 경우)
      AllergyReport? report;
      if (petId != null) {
        final petProfiles = await ref.read(petProfilesProvider.future);
        final pet = petProfiles.firstWhere(
          (p) => p.id == petId,
          orElse: () => petProfiles.first,
        );

        report = await analyzeUseCase.generateAndSaveReport(
          petId: petId,
          petName: pet.name,
          analysis: analysis,
        );
      }

      state = state.copyWith(
        isLoading: false,
        analysisResult: analysis.basicAnalysis,
        riskAssessment: analysis.ingredientRisk,
        recommendedProducts: recommendedProducts,
        report: report,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        LoggerService.debug('アレルギー分析エラー: $error');
        LoggerService.debug('StackTrace: $stackTrace');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'アレルギー分析中にエラーが発生しました。もう一度お試しください。',
      );
    }
  }

  /// 제품 추천 리스트 생성
  Future<void> generateProductRecommendations({
    required String petId,
    required List<String> avoidIngredients,
    String? petType,
    String? category,
    int limit = 20,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final manageUseCase = ref.read(manageAllergyProductsUseCaseProvider);

      final result = await manageUseCase.generateProductRecommendations(
        petId: petId,
        avoidIngredients: avoidIngredients,
        petType: petType,
        category: category,
        limit: limit,
      );

      state = state.copyWith(
        isLoading: false,
        recommendedProducts: result.recommendedProducts,
      );
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('제품 추천 에러: $error');
      }
      state = state.copyWith(
        isLoading: false,
        error: '제품 추천 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      );
    }
  }

  /// 제품 안전성 재평가
  Future<void> reevaluateProductSafety({
    required String petId,
    required List<ProductEntity> currentProducts,
    required List<String> newAllergyFindings,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final manageUseCase = ref.read(manageAllergyProductsUseCaseProvider);

      final safetyUpdate = await manageUseCase.reevaluateProductSafety(
        petId: petId,
        currentProducts: currentProducts,
        newAllergyFindings: newAllergyFindings,
      );

      // 안전하지 않은 제품이 발견되면 경고 표시
      if (safetyUpdate.actionRequired) {
        state = state.copyWith(
          isLoading: false,
          error:
              '주의: 안전하지 않은 제품이 ${safetyUpdate.unsafeProducts.length}개 발견되었습니다.',
        );
      } else {
        state = state.copyWith(isLoading: false, error: null);
      }
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('제품 안전성 재평가 에러: $error');
      }
      state = state.copyWith(
        isLoading: false,
        error: '제품 안전성 재평가 중 오류가 발생했습니다.',
      );
    }
  }

  /// 제품 비교 분석
  Future<ProductComparisonResult?> compareProducts({
    required List<ProductEntity> products,
    required List<String> avoidIngredients,
    String? petType,
  }) async {
    try {
      final manageUseCase = ref.read(manageAllergyProductsUseCaseProvider);

      return await manageUseCase.compareProducts(
        products: products,
        avoidIngredients: avoidIngredients,
        petType: petType,
      );
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('제품 비교 분석 에러: $error');
      }
      state = state.copyWith(error: '제품 비교 분석 중 오류가 발생했습니다.');
      return null;
    }
  }

  /// 상태 초기화
  void clearState() {
    state = const AllergyAnalysisState();
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}
