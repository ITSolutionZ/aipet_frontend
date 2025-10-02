import 'dart:convert';

import 'package:aipet_frontend/features/walk/domain/entities/walk_recommendation_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/services.dart';

/// 산책 추천 계산 UseCase
class ComputeWalkRecommendationUseCase {
  Map<String, dynamic>? _policyData;

  /// 정책 데이터 로드
  Future<void> _loadPolicy() async {
    if (_policyData != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/policies/walk_policy.json',
    );
    _policyData = json.decode(jsonString) as Map<String, dynamic>;
  }

  /// 산책 추천 계산
  Future<WalkRecommendationEntity> call({
    required PetProfileEntity pet,
    required double wbgt,
    double? temperature,
  }) async {
    await _loadPolicy();

    // 1단계: 기본 값 가져오기
    final baseRecommendation = _getBaseRecommendation(pet);
    int minMinutes = baseRecommendation['minMinutes'] as int;
    int maxMinutes = baseRecommendation['maxMinutes'] as int;

    final warnings = <String>[];
    int riskLevel = 0;
    final calculationDetails = <String, dynamic>{'base': baseRecommendation};

    // 2단계: 나이 보정
    final ageModifier = _getAgeModifier(pet);
    if (ageModifier != null) {
      final factor = ageModifier['factor'] as double;
      minMinutes = (minMinutes * factor).round();
      maxMinutes = (maxMinutes * factor).round();
      calculationDetails['age'] = ageModifier;

      if (factor < 1.0) {
        warnings.add(ageModifier['description'] as String);
      }
    }

    // 3단계: 품종 보정
    final breedModifier = _getBreedModifier(pet);
    if (breedModifier != null) {
      final factor = breedModifier['factor'] as double;
      minMinutes = (minMinutes * factor).round();
      maxMinutes = (maxMinutes * factor).round();
      calculationDetails['breed'] = breedModifier;
    }

    // 4단계: 건강 상태 보정
    final healthModifiers = _getHealthModifiers(pet);
    for (final modifier in healthModifiers) {
      final factor = modifier['factor'] as double;
      final riskIncrease = modifier['riskIncrease'] as int;

      minMinutes = (minMinutes * factor).round();
      maxMinutes = (maxMinutes * factor).round();
      riskLevel += riskIncrease;

      warnings.add(modifier['description'] as String);
    }
    calculationDetails['health'] = healthModifiers;

    // 5단계: 날씨 보정 (WBGT)
    final weatherModifier = _getWeatherModifier(wbgt, temperature);
    if (weatherModifier != null) {
      final factor = weatherModifier['factor'] as double;
      minMinutes = (minMinutes * factor).round();
      maxMinutes = (maxMinutes * factor).round();

      final weatherLevel = weatherModifier['level'] as String;
      if (weatherLevel == 'warning') {
        riskLevel += 1;
      } else if (weatherLevel == 'danger') {
        riskLevel += 2;
      } else if (weatherLevel == 'extreme') {
        riskLevel += 3;
      }

      warnings.add(weatherModifier['message'] as String);
      calculationDetails['weather'] = weatherModifier;
    }

    // 6단계: 최종 클램프
    minMinutes = minMinutes.clamp(5, 120);
    maxMinutes = maxMinutes.clamp(minMinutes, 120);
    riskLevel = riskLevel.clamp(0, 4);

    // 위험 레벨에 따른 메시지
    final riskInfo = _getRiskInfo(riskLevel);

    return WalkRecommendationEntity(
      minMinutes: minMinutes,
      maxMinutes: maxMinutes,
      riskLevel: riskLevel,
      riskLevelText: riskInfo['description'] as String,
      message: riskInfo['message'] as String,
      warnings: warnings,
      calculationDetails: calculationDetails,
    );
  }

  /// 기본 권장값 가져오기
  Map<String, dynamic> _getBaseRecommendation(PetProfileEntity pet) {
    final baseRecs =
        _policyData!['baseRecommendations'] as Map<String, dynamic>;
    final petType = pet.type.toLowerCase();

    if (petType == 'dog') {
      final dogRecs = baseRecs['dog'] as Map<String, dynamic>;
      final sizeCategory = _getSizeCategory(pet.weight);
      return dogRecs[sizeCategory] as Map<String, dynamic>;
    } else if (petType == 'cat') {
      final catRecs = baseRecs['cat'] as Map<String, dynamic>;
      return catRecs['all'] as Map<String, dynamic>;
    }

    // 기본값
    return {'minMinutes': 20, 'maxMinutes': 30, 'description': '기본'};
  }

  /// 체중 기준 사이즈 카테고리 판단
  String _getSizeCategory(double weight) {
    if (weight < 10) return 'small';
    if (weight < 25) return 'medium';
    return 'large';
  }

  /// 나이 보정 가져오기
  Map<String, dynamic>? _getAgeModifier(PetProfileEntity pet) {
    final ageModifiers = _policyData!['ageModifiers'] as Map<String, dynamic>;
    final age = _calculateAge(pet.birthDate);

    for (final entry in ageModifiers.entries) {
      final modifier = entry.value as Map<String, dynamic>;
      final range = modifier['range'] as List<dynamic>;
      final min = range[0] as int;
      final max = range[1] as int;

      if (age >= min && age < max) {
        return modifier;
      }
    }

    return null;
  }

  /// 품종 보정 가져오기
  Map<String, dynamic>? _getBreedModifier(PetProfileEntity pet) {
    final breedModifiers =
        _policyData!['breedModifiers'] as Map<String, dynamic>;
    final breedKey = pet.breed?.toLowerCase().replaceAll(' ', '_');

    if (breedKey != null && breedModifiers.containsKey(breedKey)) {
      return breedModifiers[breedKey] as Map<String, dynamic>;
    }

    return null;
  }

  /// 건강 상태 보정 가져오기
  List<Map<String, dynamic>> _getHealthModifiers(PetProfileEntity pet) {
    final healthModifiers =
        _policyData!['healthModifiers'] as Map<String, dynamic>;
    final result = <Map<String, dynamic>>[];

    // pet.additionalInfo에서 건강 상태 확인
    if (pet.additionalInfo != null) {
      final healthConditions =
          pet.additionalInfo!['healthConditions'] as List<dynamic>? ?? [];

      for (final condition in healthConditions) {
        final conditionKey = condition.toString().toLowerCase();
        if (healthModifiers.containsKey(conditionKey)) {
          result.add(healthModifiers[conditionKey] as Map<String, dynamic>);
        }
      }
    }

    return result;
  }

  /// 날씨 보정 가져오기
  Map<String, dynamic>? _getWeatherModifier(double wbgt, double? temperature) {
    final weatherModifiers =
        _policyData!['weatherModifiers'] as Map<String, dynamic>;
    final wbgtList = weatherModifiers['wbgt'] as List<dynamic>;

    // WBGT 우선 확인
    for (final item in wbgtList) {
      final modifier = item as Map<String, dynamic>;
      final range = modifier['range'] as List<dynamic>;
      final min = range[0] as num;
      final max = range[1] as num;

      if (wbgt >= min && wbgt < max) {
        return modifier;
      }
    }

    return null;
  }

  /// 위험 레벨 정보 가져오기
  Map<String, dynamic> _getRiskInfo(int riskLevel) {
    final riskLevels = _policyData!['riskLevels'] as Map<String, dynamic>;

    switch (riskLevel) {
      case 0:
        return riskLevels['safe'] as Map<String, dynamic>;
      case 1:
        return riskLevels['low'] as Map<String, dynamic>;
      case 2:
        return riskLevels['medium'] as Map<String, dynamic>;
      case 3:
        return riskLevels['high'] as Map<String, dynamic>;
      case 4:
        return riskLevels['extreme'] as Map<String, dynamic>;
      default:
        return riskLevels['safe'] as Map<String, dynamic>;
    }
  }

  /// 나이 계산
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
