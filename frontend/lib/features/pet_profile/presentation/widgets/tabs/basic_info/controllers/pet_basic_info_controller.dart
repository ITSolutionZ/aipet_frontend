import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pet_basic_info_state.dart';

part 'pet_basic_info_controller.g.dart';

/// Pet Basic Info Tab 컨트롤러
///
/// TextEditingController를 직접 관리하고 State는 순수 데이터만 보관
@riverpod
class PetBasicInfoController extends _$PetBasicInfoController {
  // TextEditingController들을 Controller 필드로 관리
  late final TextEditingController nameController;
  late final TextEditingController appearanceController;
  late final TextEditingController weightController;
  late final TextEditingController microchipController;

  @override
  PetBasicInfoState build(String tabId) {
    // TextEditingController 초기화
    nameController = TextEditingController();
    appearanceController = TextEditingController();
    weightController = TextEditingController();
    microchipController = TextEditingController();

    // Dispose 시 컨트롤러 정리
    ref.onDispose(_disposeControllers);

    return const PetBasicInfoState();
  }

  /// 펫 정보로 초기화
  void initialize(PetProfileEntity pet) {
    // TextEditingController 설정
    nameController.text = pet.name;
    appearanceController.text = pet.additionalInfo?['appearance'] ?? '';
    weightController.text = pet.weight.toString();
    microchipController.text = pet.additionalInfo?['microchipId'] ?? '';

    // State 초기화
    final healthConditions =
        (pet.additionalInfo?['healthConditions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    state = state.copyWith(
      editingName: pet.name,
      editingAppearance: pet.additionalInfo?['appearance'] ?? '',
      editingWeightText: pet.weight.toString(),
      editingMicrochip: pet.additionalInfo?['microchipId'] ?? '',
      editingGender: pet.gender,
      editingWeight: pet.weight,
      editingHealthConditions: healthConditions,
    );
  }

  /// 이름 업데이트
  void updateName(String name) {
    state = state.copyWith(editingName: name);
  }

  /// 외견 업데이트
  void updateAppearance(String appearance) {
    state = state.copyWith(editingAppearance: appearance);
  }

  /// 체중 텍스트 업데이트
  void updateWeightText(String weightText) {
    state = state.copyWith(editingWeightText: weightText);
    // 숫자로 변환 가능하면 editingWeight도 업데이트
    final weight = double.tryParse(weightText);
    if (weight != null) {
      state = state.copyWith(editingWeight: weight);
    }
  }

  /// 체중 업데이트 (숫자)
  void updateWeight(double? weight) {
    state = state.copyWith(
      editingWeight: weight,
      editingWeightText: weight?.toString() ?? '',
    );
  }

  /// 마이크로칩 번호 업데이트
  void updateMicrochip(String microchip) {
    state = state.copyWith(editingMicrochip: microchip);
  }

  /// 성별 업데이트
  void updateGender(String? gender) {
    state = state.copyWith(editingGender: gender);
  }

  /// 선택된 이미지 경로 업데이트
  void updateSelectedImage(String? imagePath) {
    state = state.copyWith(
      selectedImagePath: imagePath,
      imageUpdateTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 건강 상태 토글
  void toggleHealthCondition(String condition) {
    final current = state.editingHealthConditions;
    final updated = List<String>.from(current);

    if (updated.contains(condition)) {
      updated.remove(condition);
    } else {
      updated.add(condition);
    }

    state = state.copyWith(editingHealthConditions: updated);
  }

  /// 건강 상태 목록 설정
  void setHealthConditions(List<String> conditions) {
    state = state.copyWith(editingHealthConditions: conditions);
  }

  /// 상태 초기화
  void reset() {
    nameController.clear();
    appearanceController.clear();
    weightController.clear();
    microchipController.clear();
    state = const PetBasicInfoState();
  }

  /// TextEditingController 정리
  void _disposeControllers() {
    nameController.dispose();
    appearanceController.dispose();
    weightController.dispose();
    microchipController.dispose();
  }

  /// 변경사항 가져오기 (Helper에서 사용)
  Map<String, dynamic> getChanges() {
    return {
      'name': state.editingName,
      'appearance': state.editingAppearance,
      'weight': state.editingWeight,
      'microchip': state.editingMicrochip,
      'gender': state.editingGender,
      'healthConditions': state.editingHealthConditions,
      'imagePath': state.selectedImagePath,
    };
  }
}
