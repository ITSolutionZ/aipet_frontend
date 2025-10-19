import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pet_basic_info_tab.dart';

/// Pet 정보 검증 및 저장 헬퍼
class PetInfoValidationHelper {
  /// 변경사항 검증 및 저장
  static void saveChanges(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    PetProfileEntity pet,
    VoidCallback onToggleEdit,
  ) {
    final tabState = ref.read(petBasicInfoTabControllerProvider(tabId));

    // バリデーション
    if (tabState.nameController?.text.trim().isEmpty ?? true) {
      SnackBarService.showError(context, '名前を入力してください');
      return;
    }

    if (tabState.editingWeight != null && tabState.editingWeight! <= 0) {
      SnackBarService.showError(context, '体重は0より大きい値を入力してください');
      return;
    }

    // 変更を保存
    final updatedPet = _createUpdatedPet(tabState, pet);

    // TODO: API 호출로 실제 저장
    // await ref.read(petRepositoryProvider).updatePet(updatedPet);
    // updatedPet 변수는 추후 API 호출 시 사용됩니다
    // ignore: unused_local_variable
    final _ = updatedPet; // 사용하지 않는 변수 경고 제거

    SnackBarService.showSaved(context, itemName: 'ペット情報');

    onToggleEdit();
  }

  /// 편집 취소
  static void cancelEdit(
    WidgetRef ref,
    String tabId,
    PetProfileEntity pet,
    VoidCallback onToggleEdit,
  ) {
    // Reset controllers to original values
    ref.read(petBasicInfoTabControllerProvider(tabId).notifier).initialize(pet);
    onToggleEdit();
  }

  /// 업데이트된 펫 엔티티 생성
  static PetProfileEntity _createUpdatedPet(
    PetBasicInfoTabState tabState,
    PetProfileEntity pet,
  ) {
    return pet.copyWith(
      name: tabState.nameController?.text.trim() ?? pet.name,
      gender: tabState.editingGender ?? pet.gender,
      weight: tabState.editingWeight ?? pet.weight,
      additionalInfo: {
        ...pet.additionalInfo ?? {},
        'appearance': tabState.appearanceController?.text.trim() ?? '',
        'microchipId': tabState.microchipController?.text.trim() ?? '',
        'healthConditions': tabState.editingHealthConditions ?? [],
      },
    );
  }
}
