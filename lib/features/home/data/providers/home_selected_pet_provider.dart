import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_selected_pet_provider.g.dart';

/// 홈에서 선택된 펫 상태 관리
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() {
    return null; // 초기값은 null
  }

  /// 펫 선택
  void selectPet(PetProfileEntity pet) {
    state = pet;
  }

  /// 펫 선택 해제
  void clearSelection() {
    state = null;
  }

  /// 선택된 펫이 있는지 확인
  bool get hasSelectedPet => state != null;

  /// 선택된 펫 ID 반환
  String? get selectedPetId => state?.id;
}
