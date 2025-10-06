import 'dart:convert';
import 'dart:io';

import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/home/home_mock_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet_health/pet_health_mock_service.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// 펫의 건강 데이터 수집 서비스
class HealthDataCollectionService {
  /// 펫의 1개월 건강 데이터 수집
  Future<Map<String, dynamic>> collectMonthlyHealthData(
    PetProfileEntity pet,
  ) async {
    // 백신 데이터 수집
    final vaccineRecords = PetHealthMockService.getMockVaccineRecordsByPetId(
      pet.id,
    );

    // 체중 데이터 수집 (최근 30일)
    final weightRecords = await _getRecentWeightHistory(pet.id, days: 30);

    // 건강 요약 데이터
    final healthSummary = HomeMockService.getMockHealthSummary(petId: pet.id);

    // 알레르기 정보 (추후 실제 데이터로 대체)
    final allergyInfo = await _getAllergyInfo(pet.id);

    return {
      'petInfo': {
        'id': pet.id,
        'name': pet.name,
        'type': pet.type,
        'age': pet.age,
        'weight': pet.weight,
        'breed': pet.breed,
        'gender': pet.gender,
      },
      'healthData': {
        'temperature': 37.5, // 실제 체온 데이터 (추후 실제 기록으로 대체)
        'symptoms': [], // 실제 증상 데이터로 대체 필요
        'lastCheckup': healthSummary['lastCheckup'],
        'nextCheckup': healthSummary['nextCheckup'],
      },
      'vaccineData': vaccineRecords,
      'weightHistory': weightRecords,
      'allergyInfo': allergyInfo,
      'healthSummary': healthSummary,
    };
  }

  /// 최근 체중 기록 조회
  Future<List<Map<String, dynamic>>> _getRecentWeightHistory(
    String petId, {
    int days = 30,
  }) async {
    final records = HomeMockService.getMockWeightRecords(
      petId: petId,
      days: days,
    );
    return records;
  }

  /// 알레르기 정보 조회
  Future<Map<String, dynamic>> _getAllergyInfo(String petId) async {
    // TODO: 실제 알레르기 데이터 API 연동
    // 현재는 Mock 데이터 반환
    final mockAllergies = {
      '1': {
        'items': ['チョコレート', '玉ねぎ', 'ぶどう'],
        'source': 'ai', // 'ai' 또는 'test'
      },
      '2': {
        'items': ['チョコレート', 'アボカド', 'マカダミアナッツ'],
        'source': 'test', // 검사 완료
      },
      '3': {
        'items': ['牛乳', 'ネギ類', 'チョコレート'],
        'source': 'ai',
      },
      '4': {
        'items': ['キャベツ', 'ブロッコリー'],
        'source': 'test',
      },
    };

    return mockAllergies[petId] ?? {'items': [], 'source': 'ai'};
  }

  /// 데이터가 충분한지 확인
  bool hasSufficientData(Map<String, dynamic> collectedData) {
    // 최소한 펫 정보와 기본 건강 데이터가 있어야 함
    return collectedData['petInfo'] != null &&
        collectedData['healthData'] != null;
  }

  /// 리포트 생성 가능 여부 확인
  Future<bool> canGenerateReport(PetProfileEntity pet) async {
    try {
      final data = await collectMonthlyHealthData(pet);
      return hasSufficientData(data);
    } catch (e) {
      return false;
    }
  }

  /// 건강 데이터를 JSON 문자열로 변환
  String convertToJson(Map<String, dynamic> healthData) {
    // DateTime을 ISO8601 문자열로 변환
    final jsonData = _sanitizeForJson(healthData);
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// JSON 직렬화를 위한 데이터 정리
  dynamic _sanitizeForJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, _sanitizeForJson(value)));
    } else if (data is List) {
      return data.map((item) => _sanitizeForJson(item)).toList();
    } else if (data is DateTime) {
      return data.toIso8601String();
    } else {
      return data;
    }
  }

  /// JSON 파일로 저장
  Future<File> saveHealthDataAsJson(
    PetProfileEntity pet,
    Map<String, dynamic> healthData,
  ) async {
    final jsonString = convertToJson(healthData);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyy/MM/dd_HH:mm:ss').format(DateTime.now());
    final file = File('${dir.path}/health_data_${pet.name}_$timestamp.json');
    await file.writeAsString(jsonString);
    return file;
  }
}
