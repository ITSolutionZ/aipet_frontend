import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈에서 선택된 펫을 관리하는 Provider
final homeSelectedPetNotifierProvider =
    StateNotifierProvider<HomeSelectedPetNotifier, String?>((ref) {
      return HomeSelectedPetNotifier();
    });

/// 홈에서 선택된 펫을 관리하는 StateNotifier
class HomeSelectedPetNotifier extends StateNotifier<String?> {
  HomeSelectedPetNotifier() : super(null);

  /// 펫 선택
  void selectPet(String petId) {
    state = petId;
  }

  /// 펫 선택 해제
  void clearSelection() {
    state = null;
  }
}
