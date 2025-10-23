import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 펫 상태 관리 헬퍼
class PetStatusHelper {
  static const String _keyPetStatuses = 'pet_statuses';

  /// 펫 상태 저장
  // ✅ SharedPreferences 인스턴스 재사용
  static SharedPreferences? _prefs;
  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  static Future<void> updatePetStatus(
    String petId,
    Map<String, String> statusValues,
  ) async {
    try {
      await _init();
      final statusKey = '${_keyPetStatuses}_$petId';

      final statusData = {
        ...statusValues,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await prefs.setString(statusKey, jsonEncode(statusData));
      LoggerService.debug('ペット状態更新成功: $petId');
    } catch (e) {
      LoggerService.debug('ペット状態更新エラー: $e');
    }
  }

  /// 펫 상태 가져오기
  static Future<Map<String, dynamic>> getPetStatus(String petId) async {
    try {
      await _init();
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
      LoggerService.debug('ペット状態取得エラー: $e');
      return {
        'selectedStatuses': [],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
}
