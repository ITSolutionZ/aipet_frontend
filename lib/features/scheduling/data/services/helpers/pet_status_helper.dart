import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 펫 상태 관리 헬퍼
class PetStatusHelper {
  static const String _keyPetStatuses = 'pet_statuses';

  /// 펫 상태 저장
  static Future<void> updatePetStatus(
    String petId,
    Map<String, String> statusValues,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusKey = '${_keyPetStatuses}_$petId';

      final statusData = {
        ...statusValues,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await prefs.setString(statusKey, jsonEncode(statusData));
      debugPrint('ペット状態更新成功: $petId');
    } catch (e) {
      debugPrint('ペット状態更新エラー: $e');
    }
  }

  /// 펫 상태 가져오기
  static Future<Map<String, dynamic>> getPetStatus(String petId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusKey = '${_keyPetStatuses}_$petId';
      final statusJson = prefs.getString(statusKey);

      if (statusJson != null) {
        return jsonDecode(statusJson) as Map<String, dynamic>;
      }

      return {
        'selectedStatuses': [],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('ペット状態取得エラー: $e');
      return {
        'selectedStatuses': [],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
}
