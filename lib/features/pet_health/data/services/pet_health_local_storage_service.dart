import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 펫 건강 로컬 저장소 서비스
///
/// 건강 기록(백신, 체중)을 SharedPreferences에 저장/관리합니다
class PetHealthLocalStorageService {
  static const String _keyVaccineRecords = 'pet_vaccine_records';
  // ✅ SharedPreferences 인스턴스 재사용
  static SharedPreferences? _prefs;
  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  static const String _keyWeightRecords = 'pet_weight_records';

  /// 백신 기록 가져오기
  static Future<List<Map<String, dynamic>>> getVaccineRecords({
    String? petId,
  }) async {
    try {
      await _init();
      final recordsJson = prefs.getStringList(_keyVaccineRecords) ?? [];

      if (recordsJson.isEmpty) {
        return await _initializeDefaultVaccineRecords();
      }

      final records = recordsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      if (petId != null) {
        return records.where((r) => r['petId'] == petId).toList();
      }

      return records;
    } catch (e) {
      LoggerService.debug('백신 기록 로드 실패: $e');
      return [];
    }
  }

  /// 백신 기록 추가
  static Future<void> addVaccineRecord(Map<String, dynamic> record) async {
    try {
      await _init();
      final records = prefs.getStringList(_keyVaccineRecords) ?? [];

      if (record['id'] == null || (record['id'] as String).isEmpty) {
        record['id'] = 'vaccine-${DateTime.now().millisecondsSinceEpoch}';
      }

      records.add(jsonEncode(record));
      await prefs.setStringList(_keyVaccineRecords, records);

      LoggerService.debug('백신 기록 추가 성공: ${record['id']}');
    } catch (e) {
      LoggerService.debug('백신 기록 추가 실패: $e');
    }
  }

  /// 백신 기록 업데이트
  static Future<void> updateVaccineRecord(Map<String, dynamic> record) async {
    try {
      await _init();
      final records = prefs.getStringList(_keyVaccineRecords) ?? [];

      final index = records.indexWhere((r) {
        final recordData = jsonDecode(r) as Map<String, dynamic>;
        return recordData['id'] == record['id'];
      });

      if (index != -1) {
        records[index] = jsonEncode(record);
        await prefs.setStringList(_keyVaccineRecords, records);
        LoggerService.debug('백신 기록 업데이트 성공: ${record['id']}');
      }
    } catch (e) {
      LoggerService.debug('백신 기록 업데이트 실패: $e');
    }
  }

  /// 백신 기록 삭제
  static Future<void> deleteVaccineRecord(String recordId) async {
    try {
      await _init();
      final records = prefs.getStringList(_keyVaccineRecords) ?? [];

      records.removeWhere((r) {
        final recordData = jsonDecode(r) as Map<String, dynamic>;
        return recordData['id'] == recordId;
      });

      await prefs.setStringList(_keyVaccineRecords, records);
      LoggerService.debug('백신 기록 삭제 성공: $recordId');
    } catch (e) {
      LoggerService.debug('백신 기록 삭제 실패: $e');
    }
  }

  /// 체중 기록 가져오기
  static Future<List<Map<String, dynamic>>> getWeightRecords({
    String? petId,
  }) async {
    try {
      await _init();
      final recordsJson = prefs.getStringList(_keyWeightRecords) ?? [];

      if (recordsJson.isEmpty) {
        return await _initializeDefaultWeightRecords();
      }

      final records = recordsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      if (petId != null) {
        return records.where((r) => r['petId'] == petId).toList();
      }

      return records;
    } catch (e) {
      LoggerService.debug('체중 기록 로드 실패: $e');
      return [];
    }
  }

  /// 체중 기록 추가
  static Future<void> addWeightRecord(Map<String, dynamic> record) async {
    try {
      await _init();
      final records = prefs.getStringList(_keyWeightRecords) ?? [];

      if (record['id'] == null || (record['id'] as String).isEmpty) {
        record['id'] = 'weight-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (record['recordedDate'] == null) {
        record['recordedDate'] = DateTime.now().toIso8601String();
      }

      records.add(jsonEncode(record));
      await prefs.setStringList(_keyWeightRecords, records);

      LoggerService.debug('체중 기록 추가 성공: ${record['id']}');
    } catch (e) {
      LoggerService.debug('체중 기록 추가 실패: $e');
    }
  }

  /// 체중 기록 업데이트
  static Future<void> updateWeightRecord(Map<String, dynamic> record) async {
    try {
      await _init();
      final records = prefs.getStringList(_keyWeightRecords) ?? [];

      final index = records.indexWhere((r) {
        final recordData = jsonDecode(r) as Map<String, dynamic>;
        return recordData['id'] == record['id'];
      });

      if (index != -1) {
        record['updatedAt'] = DateTime.now().toIso8601String();
        records[index] = jsonEncode(record);
        await prefs.setStringList(_keyWeightRecords, records);
        LoggerService.debug('체중 기록 업데이트 성공: ${record['id']}');
      }
    } catch (e) {
      LoggerService.debug('체중 기록 업데이트 실패: $e');
    }
  }

  /// 체중 기록 삭제
  static Future<void> deleteWeightRecord(String recordId) async {
    try {
      await _init();
      final records = prefs.getStringList(_keyWeightRecords) ?? [];

      records.removeWhere((r) {
        final recordData = jsonDecode(r) as Map<String, dynamic>;
        return recordData['id'] == recordId;
      });

      await prefs.setStringList(_keyWeightRecords, records);
      LoggerService.debug('체중 기록 삭제 성공: $recordId');
    } catch (e) {
      LoggerService.debug('체중 기록 삭제 실패: $e');
    }
  }

  /// 초기 기본 백신 기록 생성
  static Future<List<Map<String, dynamic>>>
  _initializeDefaultVaccineRecords() async {
    await _init();
    final defaultRecords = [
      {
        'id': 'vaccine-1',
        'petId': 'default',
        'vaccineName': '狂犬病ワクチン',
        'vaccineDate': DateTime(2024, 3, 15).toIso8601String(),
        'veterinarian': '田中獣医師',
        'notes': '年1回の予防接種',
      },
      {
        'id': 'vaccine-2',
        'petId': 'default',
        'vaccineName': '混合ワクチン（5種）',
        'vaccineDate': DateTime(2024, 2, 10).toIso8601String(),
        'veterinarian': '田中獣医師',
        'notes': 'ジステンパー、パルボウイルスなど',
      },
    ];

    final recordsJson = defaultRecords.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(_keyVaccineRecords, recordsJson);

    return defaultRecords;
  }

  /// 초기 기본 체중 기록 생성
  static Future<List<Map<String, dynamic>>>
  _initializeDefaultWeightRecords() async {
    await _init();
    final now = DateTime.now();
    final defaultRecords = [
      {
        'id': 'weight-1',
        'petId': 'default',
        'petName': 'Max',
        'measurementDate': now
            .subtract(const Duration(days: 60))
            .toIso8601String(),
        'weight': 5.2,
        'notes': '定期検診',
      },
      {
        'id': 'weight-2',
        'petId': 'default',
        'petName': 'Max',
        'measurementDate': now
            .subtract(const Duration(days: 30))
            .toIso8601String(),
        'weight': 5.4,
        'notes': '体重増加',
      },
      {
        'id': 'weight-3',
        'petId': 'default',
        'petName': 'Max',
        'measurementDate': now.toIso8601String(),
        'weight': 5.5,
        'notes': '健康状態良好',
      },
    ];

    final recordsJson = defaultRecords.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(_keyWeightRecords, recordsJson);

    return defaultRecords;
  }
}
