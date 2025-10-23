import 'dart:convert';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'dart:io';

import 'package:aipet_frontend/features/allergy/data/repositories/saved_analysis_repository.dart';
import 'package:aipet_frontend/features/pet_health/data/services/pet_health_local_storage_service.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// 펫의 건강 데이터 수집 서비스
class HealthDataCollectionService {
  /// 펫의 1개월 건강 데이터 수집
  Future<Map<String, dynamic>> collectMonthlyHealthData(
    PetProfileEntity pet,
  ) async {
    // 백신 데이터 수집 (로컬 저장소)
    final allVaccineRecords =
        await PetHealthLocalStorageService.getVaccineRecords();
    final vaccineRecords = allVaccineRecords
        .where((vaccine) => vaccine['petId'] == pet.id)
        .toList();

    // 체중 데이터 수집 (최근 30일)
    final weightRecords = await _getRecentWeightHistory(pet.id, days: 30);

    // 건강 요약 데이터 (기본값 사용)
    final healthSummary = _getDefaultHealthSummary();

    // 알레르기 정보
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
        'temperature': 37.5, // 기본 체온 데이터
        'symptoms': [], // 증상 데이터
        'lastCheckup': healthSummary['lastCheckup'],
        'nextCheckup': healthSummary['nextCheckup'],
      },
      'vaccineData': vaccineRecords,
      'weightHistory': weightRecords,
      'allergyInfo': allergyInfo,
      'healthSummary': healthSummary,
    };
  }

  /// 최근 체중 기록 조회 (로컬 저장소)
  Future<List<Map<String, dynamic>>> _getRecentWeightHistory(
    String petId, {
    int days = 30,
  }) async {
    // 로컬 저장소에서 체중 기록 조회
    final allWeightRecords =
        await PetHealthLocalStorageService.getWeightRecords();

    // 해당 펫의 최근 N일 체중 기록 필터링
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentRecords = allWeightRecords.where((record) {
      final petIdMatch = record['petId'] == petId;
      final date = record['date'] as DateTime?;
      return petIdMatch && date != null && date.isAfter(cutoffDate);
    }).toList();

    // 날짜 역순 정렬 (최신순)
    recentRecords.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return recentRecords;
  }

  /// 기본 건강 요약 데이터 반환
  Map<String, dynamic> _getDefaultHealthSummary() {
    final now = DateTime.now();
    return {
      'lastCheckup': now.subtract(const Duration(days: 30)),
      'nextCheckup': now.add(const Duration(days: 60)),
    };
  }

  /// 알레르기 정보 조회 (로컬 저장소에서)
  Future<Map<String, dynamic>> _getAllergyInfo(String petId) async {
    try {
      // 로컬에 저장된 알레르기 분석 결과 조회
      final repository = SavedAnalysisRepository();
      final allAnalysesResult = await repository.loadAll();

      // Result 패턴 처리
      final allAnalyses = allAnalysesResult.dataOr([]);

      // 해당 펫의 가장 최근 분석 결과 찾기
      final petAnalyses = allAnalyses
          .where((analysis) => analysis.petId == petId)
          .toList();

      if (petAnalyses.isEmpty) {
        return {'items': [], 'source': 'none'};
      }

      // 가장 최근 분석 결과 (첫 번째 항목)
      final latestAnalysis = petAnalyses.first;
      final analysisResult = latestAnalysis.analysisResult;

      // suspectedIngredients 추출
      final suspectedIngredients =
          analysisResult['suspectedIngredients'] as List<dynamic>? ?? [];

      return {
        'items': suspectedIngredients.map((e) => e.toString()).toList(),
        'source': 'ai', // AI 분석 결과
        'analysisDate': latestAnalysis.savedAt.toIso8601String(),
        'confidence': analysisResult['confidence'] ?? 0.0,
      };
    } catch (e) {
      LoggerService.debug('Error loading allergy info: $e');
      return {'items': [], 'source': 'none'};
    }
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
