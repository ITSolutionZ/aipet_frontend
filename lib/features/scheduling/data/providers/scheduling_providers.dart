import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scheduling_providers.g.dart';

/// 홈에서 선택된 펫을 관리하는 Notifier
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  String? build() {
    return null;
  }

  /// 펫 선택
  void selectPet(String petId) {
    state = petId;
  }

  /// 펫 선택 해제
  void clearSelection() {
    state = null;
  }
}
