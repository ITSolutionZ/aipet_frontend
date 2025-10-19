import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../pet_profile/data/providers/pet_profile_providers.dart';

/// 달력 통계 계산 헬퍼
class WalkCalendarStatsHelper {
  /// 총 거리 계산
  static double calculateTotalDistance(List<WalkRecordEntity> records) {
    return records.fold<double>(
      0,
      (sum, record) => sum + (record.distance ?? 0),
    );
  }

  /// 총 시간 계산
  static Duration calculateTotalDuration(List<WalkRecordEntity> records) {
    return records.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + record.calculatedDuration,
    );
  }

  /// 달성률 계산
  static int calculateAchievementRate({
    required List<WalkRecordEntity> recordsForDay,
    required Duration totalDuration,
    required WidgetRef ref,
  }) {
    if (recordsForDay.isEmpty) return 0;

    // 로컬 저장소에서 펫의 1일 권장 시간 가져오기
    final petsAsync = ref.read(petProfilesProvider);
    final recommendedMinutes = petsAsync.maybeWhen(
      data: (pets) {
        if (pets.isEmpty) return 30;
        final petId = recordsForDay.first.petId;
        final pet = pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => pets.first,
        );
        return _getRecommendedWalkTime(pet);
      },
      orElse: () => 30,
    );

    if (recommendedMinutes <= 0) return 0;

    final actualMinutes = totalDuration.inMinutes;
    final rate = (actualMinutes / recommendedMinutes * 100).round();

    // 최대 200%까지만 표시
    return rate > 200 ? 200 : rate;
  }

  /// 권장 산책 시간 계산 (분 단위) - 펫의 상태를 고려하여 동적 조정
  static int _getRecommendedWalkTime(PetProfileEntity pet) {
    // 기본 산책 시간 계산
    final int baseWalkTime = _calculateBaseWalkTime(pet);

    // 펫의 상태에 따라 조정
    return _adjustWalkTimeByHealth(pet, baseWalkTime);
  }

  /// 기본 권장 산책 시간 계산 (체형과 종류 기반)
  static int _calculateBaseWalkTime(PetProfileEntity pet) {
    // 개 타입일 경우
    if (pet.type.toLowerCase() == 'dog') {
      // 크기와 몸무게에 따라 산책 시간 결정
      if (pet.size != null) {
        switch (pet.size!.toLowerCase()) {
          case 'small': // 소형견 (< 10kg)
            return 30;
          case 'medium': // 중형견 (10-25kg)
            return 45;
          case 'large': // 대형견 (> 25kg)
            return 60;
        }
      }

      // size가 없으면 몸무게로 판단
      if (pet.weight < 10) {
        return 30; // 소형견
      } else if (pet.weight < 25) {
        return 45; // 중형견
      } else {
        return 60; // 대형견
      }
    }

    // 고양이
    if (pet.type.toLowerCase() == 'cat') {
      return 20;
    }

    // 기타 동물
    return 15;
  }

  /// 펫의 건강 상태에 따라 산책 시간 조정
  static int _adjustWalkTimeByHealth(PetProfileEntity pet, int baseTime) {
    final additionalInfo = pet.additionalInfo ?? {};

    // 현재 건강 상태 확인
    final currentHealthStatus =
        additionalInfo['currentHealthStatus'] as String?;
    final isRecovering = additionalInfo['isRecovering'] as bool? ?? false;

    // 나이 계산
    final now = DateTime.now();
    int age = now.year - pet.birthDate.year;
    if (now.month < pet.birthDate.month ||
        (now.month == pet.birthDate.month && now.day < pet.birthDate.day)) {
      age--;
    }

    // 나이 기반 조정 (노령견)
    int adjustedTime = baseTime;
    if (age >= 10 && pet.type.toLowerCase() == 'dog') {
      // 노령견: 30% 감소
      adjustedTime = (baseTime * 0.7).round();
    }

    // 건강 상태 기반 조정
    if (currentHealthStatus != null) {
      switch (currentHealthStatus.toLowerCase()) {
        case 'sick':
        case '아픔':
        case '병중':
          // 아픈 경우: 50% 감소
          adjustedTime = (adjustedTime * 0.5).round();
          break;
        case 'recovering':
        case '회복중':
        case '회복 중':
          // 회복 중: 30% 감소
          adjustedTime = (adjustedTime * 0.7).round();
          break;
        case 'healthy':
        case '건강':
        default:
          // 건강: 그대로 유지
          break;
      }
    }

    // 회복 중 플래그 확인
    if (isRecovering && currentHealthStatus != 'sick') {
      adjustedTime = (adjustedTime * 0.7).round();
    }

    // 최소값 5분 이상 보장
    return adjustedTime < 5 ? 5 : adjustedTime;
  }
}
