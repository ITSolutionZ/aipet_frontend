import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 선택 관련 헬퍼
class WalkListPetHelper {
  /// 펫 선택 토글 처리
  static void handlePetToggle({
    required dynamic pet,
    required WalkController controller,
    required WidgetRef ref,
  }) {
    debugPrint('🐾 펫 탭: ${pet.name} (ID: ${pet.id})');

    // 펫 선택 토글
    controller.togglePet(WalkPetInfo.fromPetProfile(pet));

    // 선택된 펫 확인 (디버깅용)
    _logSelectedPets(ref);
  }

  /// 선택된 펫 로깅
  static void _logSelectedPets(WidgetRef ref) {
    final currentSelected = ref.read(selectedPetsNotifierProvider);
    debugPrint('✅ 선택된 펫들: ${currentSelected.map((p) => p.name).join(', ')}');
  }

  /// 추천 산책 시간 가져오기
  static int getRecommendedWalkTime({
    required WidgetRef ref,
    required List<WalkPetInfo> selectedPets,
  }) {
    final petsAsync = ref.watch(petListProvider);

    return petsAsync.maybeWhen(
      data: (pets) {
        if (pets.isEmpty) return 30;
        final selectedPet = selectedPets.isNotEmpty
            ? pets.firstWhere(
                (p) => p.id == selectedPets.first.id,
                orElse: () => pets.first,
              )
            : pets.first;
        return selectedPet.recommendedWalkTime;
      },
      orElse: () => 30,
    );
  }
}
