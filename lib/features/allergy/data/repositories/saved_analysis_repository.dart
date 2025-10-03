import 'dart:convert';

import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 저장된 알레르기 분석 결과 Repository
class SavedAnalysisRepository {
  static const String _key = 'saved_allergy_analyses';

  /// 모든 분석 결과 로드
  Future<List<SavedAnalysisEntity>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => _fromJson(json)).toList();
    } catch (e) {
      print('Error loading saved analyses: $e');
      return [];
    }
  }

  /// 분석 결과 저장
  Future<void> save(SavedAnalysisEntity analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyses = await loadAll();

      // 새 분석 추가
      analyses.insert(0, analysis);

      // JSON으로 변환하여 저장
      final jsonList = analyses.map((a) => _toJson(a)).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving analysis: $e');
      rethrow;
    }
  }

  /// 분석 결과 삭제
  Future<void> delete(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyses = await loadAll();

      // ID로 찾아서 삭제
      analyses.removeWhere((analysis) => analysis.id == id);

      // JSON으로 변환하여 저장
      final jsonList = analyses.map((a) => _toJson(a)).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      print('Error deleting analysis: $e');
      rethrow;
    }
  }

  /// 모든 분석 결과 삭제
  Future<void> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error deleting all analyses: $e');
      rethrow;
    }
  }

  /// Entity를 JSON으로 변환
  Map<String, dynamic> _toJson(SavedAnalysisEntity entity) {
    return {
      'id': entity.id,
      'petId': entity.petId,
      'petName': entity.petName,
      'analysisResult': entity.analysisResult,
      'savedAt': entity.savedAt.toIso8601String(),
    };
  }

  /// JSON을 Entity로 변환
  SavedAnalysisEntity _fromJson(Map<String, dynamic> json) {
    final analysisResult = Map<String, dynamic>.from(json['analysisResult']);

    // List<dynamic>을 List<String>으로 명시적 변환
    if (analysisResult['suspectedIngredients'] is List) {
      analysisResult['suspectedIngredients'] = List<String>.from(
        analysisResult['suspectedIngredients'] as List,
      );
    }

    if (analysisResult['recommendations'] is List) {
      analysisResult['recommendations'] = List<String>.from(
        analysisResult['recommendations'] as List,
      );
    }

    return SavedAnalysisEntity(
      id: json['id'],
      petId: json['petId'],
      petName: json['petName'],
      analysisResult: analysisResult,
      savedAt: DateTime.parse(json['savedAt']),
    );
  }
}
