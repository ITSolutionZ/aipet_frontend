import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../pet_profile/data/providers/pet_profile_providers.dart';

/// 펫 선택 관련 헬퍼
class WalkListPetHelper {
  /// 펫 선택 토글 처리
  static void handlePetToggle({
    required dynamic pet,
    required WalkController controller,
    required WidgetRef ref,
  }) {
    LoggerService.debug('🐾 펫 탭: ${pet.name} (ID: ${pet.id})');

    // 펫 선택 토글
    controller.togglePet(WalkPetInfo.fromPetProfile(pet));

    // 선택된 펫 확인 (디버깅용)
    _logSelectedPets(ref);
  }

  /// 선택된 펫 로깅
  static void _logSelectedPets(WidgetRef ref) {
    final currentSelected = ref.read(selectedPetsProvider);
    LoggerService.debug('✅ 선택된 펫들: ${currentSelected.map((p) => p.name).join(', ')}');
  }

  /// 추천 산책 시간 가져오기
  static int getRecommendedWalkTime({
    required WidgetRef ref,
    required List<WalkPetInfo> selectedPets,
  }) {
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.maybeWhen(
      data: (pets) {
        if (pets.isEmpty) return 30;
        final selectedPet = selectedPets.isNotEmpty
            ? pets.firstWhere(
                (p) => p.id == selectedPets.first.id,
                orElse: () => pets.first,
              )
            : pets.first;
        return _getRecommendedWalkTime(selectedPet);
      },
      orElse: () => 30,
    );
  }

  /// 권장 산책 시간 계산 (분 단위) - 펫의 상태를 고려하여 동적 조정
  static int _getRecommendedWalkTime(PetProfileEntity pet) {
    // 기본 산책 시간 계산
    final baseWalkTime = _calculateBaseWalkTime(pet);

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
    final currentHealthStatus = additionalInfo['currentHealthStatus'] as String?;
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
