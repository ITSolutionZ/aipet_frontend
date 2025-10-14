import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 트릭 저장소 헬퍼
class TrickStorageHelper {
  static const String _keyTricks = 'pet_tricks';

  /// 트릭 가져오기
  static Future<List<Map<String, dynamic>>> getTricks({String? petId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tricksJson = prefs.getStringList(_keyTricks) ?? [];

      if (tricksJson.isEmpty) {
        return await _initializeDefaultTricks();
      }

      final tricks = tricksJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      if (petId != null) {
        return tricks.where((t) => t['petId'] == petId).toList();
      }

      return tricks;
    } catch (e) {
      debugPrint('트릭 로드 실패: $e');
      return [];
    }
  }

  /// 트릭 추가
  static Future<void> addTrick(Map<String, dynamic> trick) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tricks = prefs.getStringList(_keyTricks) ?? [];

      if (trick['id'] == null || (trick['id'] as String).isEmpty) {
        trick['id'] = 'trick-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (trick['createdAt'] == null) {
        trick['createdAt'] = DateTime.now().toIso8601String();
      }

      if (trick['updatedAt'] == null) {
        trick['updatedAt'] = DateTime.now().toIso8601String();
      }

      tricks.add(jsonEncode(trick));
      await prefs.setStringList(_keyTricks, tricks);

      if (kDebugMode) {
        debugPrint('트릭 추가 완료: ${trick['name']}');
      }
    } catch (e) {
      debugPrint('트릭 추가 실패: $e');
      rethrow;
    }
  }

  /// 트릭 업데이트
  static Future<void> updateTrick(
    String trickId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tricks = prefs.getStringList(_keyTricks) ?? [];

      final updatedTricks = tricks.map((json) {
        final trick = jsonDecode(json) as Map<String, dynamic>;
        if (trick['id'] == trickId) {
          trick.addAll(updates);
          trick['updatedAt'] = DateTime.now().toIso8601String();
        }
        return jsonEncode(trick);
      }).toList();

      await prefs.setStringList(_keyTricks, updatedTricks);

      if (kDebugMode) {
        debugPrint('트릭 업데이트 완료: $trickId');
      }
    } catch (e) {
      debugPrint('트릭 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 트릭 삭제
  static Future<void> deleteTrick(String trickId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tricks = prefs.getStringList(_keyTricks) ?? [];

      final filteredTricks = tricks.where((json) {
        final trick = jsonDecode(json) as Map<String, dynamic>;
        return trick['id'] != trickId;
      }).toList();

      await prefs.setStringList(_keyTricks, filteredTricks);

      if (kDebugMode) {
        debugPrint('트릭 삭제 완료: $trickId');
      }
    } catch (e) {
      debugPrint('트릭 삭제 실패: $e');
      rethrow;
    }
  }

  /// 트릭 검색
  static Future<List<Map<String, dynamic>>> searchTricks(String query) async {
    try {
      final allTricks = await getTricks();
      final lowerQuery = query.toLowerCase();

      return allTricks.where((trick) {
        final name = (trick['name'] as String? ?? '').toLowerCase();
        final description = (trick['description'] as String? ?? '')
            .toLowerCase();
        final category = (trick['category'] as String? ?? '').toLowerCase();

        return name.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            category.contains(lowerQuery);
      }).toList();
    } catch (e) {
      debugPrint('트릭 검색 실패: $e');
      return [];
    }
  }

  /// 트릭 통계
  static Future<Map<String, int>> getTrickStats({String? petId}) async {
    try {
      final tricks = await getTricks(petId: petId);

      return {
        'total': tricks.length,
        'completed': tricks.where((t) => t['isCompleted'] == true).length,
        'inProgress': tricks.where((t) => t['isCompleted'] == false).length,
      };
    } catch (e) {
      debugPrint('트릭 통계 실패: $e');
      return {'total': 0, 'completed': 0, 'inProgress': 0};
    }
  }

  /// 기본 트릭 초기화
  static Future<List<Map<String, dynamic>>> _initializeDefaultTricks() async {
    final defaultTricks = [
      {
        'id': 'trick-1',
        'name': 'おすわり',
        'description': '座ることを教える',
        'category': '基本',
        'difficulty': 'easy',
        'petId': 'default',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'trick-2',
        'name': 'お手',
        'description': '手を上げることを教える',
        'category': '基本',
        'difficulty': 'easy',
        'petId': 'default',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    try {
      final prefs = await SharedPreferences.getInstance();
      final tricksJson = defaultTricks
          .map((trick) => jsonEncode(trick))
          .toList();
      await prefs.setStringList(_keyTricks, tricksJson);

      if (kDebugMode) {
        debugPrint('기본 트릭 초기화 완료');
      }

      return defaultTricks;
    } catch (e) {
      debugPrint('기본 트릭 초기화 실패: $e');
      return [];
    }
  }
}
