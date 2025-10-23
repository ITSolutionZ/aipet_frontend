import 'dart:convert';

import 'package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 레시피 매퍼 헬퍼
class RecipeMapperHelper {
  /// 레시피 엔티티를 JSON으로 변환
  static Map<String, dynamic> entityToJson(RecipeEntity recipe) {
    return recipe.toJson();
  // ✅ SharedPreferences 인스턴스 재사용
  static SharedPreferences? _prefs;
  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  }

  /// JSON을 레시피 엔티티로 변환
  static RecipeEntity jsonToEntity(Map<String, dynamic> json) {
    return RecipeEntity.fromJson(json);
  }

  /// 레시피 리스트를 엔티티 리스트로 변환
  static List<RecipeEntity> jsonListToEntityList(
    List<Map<String, dynamic>> jsonList,
  ) {
    return jsonList.map((json) => jsonToEntity(json)).toList();
  }

  /// 엔티티 리스트를 JSON 리스트로 변환
  static List<Map<String, dynamic>> entityListToJsonList(
    List<RecipeEntity> entities,
  ) {
    return entities.map((entity) => entityToJson(entity)).toList();
  }

  /// SharedPreferences에 레시피 저장
  static Future<void> saveRecipesToPreferences(
    List<Map<String, dynamic>> recipes,
  ) async {
    await _init();
    final recipesJson = recipes.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList('pet_recipes', recipesJson);
  }

  /// 레시피 업데이트 시 타임스탬프 추가
  static Map<String, dynamic> addUpdateTimestamp(Map<String, dynamic> recipe) {
    final updatedRecipe = Map<String, dynamic>.from(recipe);
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 생성 시 타임스탬프 추가
  static Map<String, dynamic> addCreateTimestamp(Map<String, dynamic> recipe) {
    final newRecipe = Map<String, dynamic>.from(recipe);
    if (newRecipe['createdAt'] == null) {
      newRecipe['createdAt'] = DateTime.now().toIso8601String();
    }
    return newRecipe;
  }
}
