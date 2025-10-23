import 'package:flutter/foundation.dart';

import 'helpers/helpers.dart';

/// 펫 급여 로컬 저장소 서비스 (리팩토링됨)
import 'package:aipet_frontend/shared/services/cache_service.dart';
///
/// 급여 기록을 SharedPreferences에 저장/관리합니다
class PetFeedingLocalStorageService {
  // ========== 급여 기록 관련 메서드 (헬퍼 위임) ==========

  /// 급여 기록 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getFeedingRecords({
    String? petId,
  }) async {
    return FeedingStorageHelper.getFeedingRecords(petId: petId);
  }

  /// 급여 기록 추가 (헬퍼 위임)
  static Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    return FeedingStorageHelper.addFeedingRecord(record);
  }

  /// 급여 기록 업데이트 (헬퍼 위임)
  static Future<void> updateFeedingRecord(Map<String, dynamic> record) async {
    return FeedingStorageHelper.updateFeedingRecord(record);
  }

  /// 급여 기록 삭제 (헬퍼 위임)
  static Future<void> deleteFeedingRecord(String recordId) async {
    return FeedingStorageHelper.deleteFeedingRecord(recordId);
  }

  /// 날짜별 급여 기록 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    return FeedingStorageHelper.getFeedingRecordsByDate(petId, date);
  }

  /// 급여 기록 통계 (헬퍼 위임)
  static Future<Map<String, dynamic>> getFeedingStats(String petId) async {
    return FeedingStorageHelper.getFeedingStats(petId);
  }

  // ========== 레시피 관련 메서드 (헬퍼 위임) ==========

  /// 레시피 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getRecipes() async {
    return RecipeStorageHelper.getRecipes();
  }

  /// 레시피 추가 (헬퍼 위임)
  static Future<void> addRecipe(Map<String, dynamic> recipe) async {
    return RecipeStorageHelper.addRecipe(recipe);
  }

  /// 레시피 업데이트 (헬퍼 위임)
  static Future<void> updateRecipe(
    String recipeId,
    Map<String, dynamic> updates,
  ) async {
    return RecipeStorageHelper.updateRecipe(recipeId, updates);
  }

  /// 레시피 삭제 (헬퍼 위임)
  static Future<void> deleteRecipe(String recipeId) async {
    return RecipeStorageHelper.deleteRecipe(recipeId);
  }

  /// 레시피 검색 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> searchRecipes(String query) async {
    return RecipeStorageHelper.searchRecipes(query);
  }

  /// 난이도별 레시피 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getRecipesByDifficulty(
    String difficulty,
  ) async {
    return RecipeStorageHelper.getRecipesByDifficulty(difficulty);
  }

  /// 즐겨찾기 레시피 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getFavoriteRecipes(
    String userId,
  ) async {
    return RecipeStorageHelper.getFavoriteRecipes(userId);
  }

  /// 최고 평점 레시피 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getTopRatedRecipes({
    int limit = 5,
  }) async {
    return RecipeStorageHelper.getTopRatedRecipes(limit: limit);
  }

  /// 빠른 조리 레시피 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getQuickRecipes() async {
    return RecipeStorageHelper.getQuickRecipes();
  }

  // ========== 통합 관리 메서드 ==========

  /// 모든 데이터 초기화
  static Future<void> clearAllData() async {
    try {
      await _cache.initialize();
      await prefs.remove('pet_feeding_records');
      await prefs.remove('pet_recipes');

      if (kDebugMode) {
        LoggerService.debug('모든 급여 데이터 초기화 완료');
      }
    } catch (e) {
      LoggerService.debug('데이터 초기화 실패: $e');
      rethrow;
    }
  }
}
