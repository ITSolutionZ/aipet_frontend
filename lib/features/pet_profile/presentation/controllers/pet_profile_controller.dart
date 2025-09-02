import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_controller.g.dart';

/// 펫 프로필 상태
class PetProfileState {
  final TabController? tabController;
  final String selectedPetName;

  const PetProfileState({this.tabController, this.selectedPetName = 'ポチ'});

  PetProfileState copyWith({
    TabController? tabController,
    String? selectedPetName,
  }) {
    return PetProfileState(
      tabController: tabController ?? this.tabController,
      selectedPetName: selectedPetName ?? this.selectedPetName,
    );
  }
}

/// 펫 프로필 컨트롤러 (최신 @riverpod 패턴)
@riverpod
class PetProfileNotifier extends _$PetProfileNotifier {
  @override
  PetProfileState build() => const PetProfileState();

  /// 탭 컨트롤러 초기화
  void initializeTabController(TickerProvider vsync) {
    final tabController = TabController(length: 4, vsync: vsync);
    state = state.copyWith(tabController: tabController);
  }

  /// 탭 컨트롤러 정리
  void disposeTabController() {
    state.tabController?.dispose();
  }

  /// 펫 선택
  void selectPet(String petName) {
    state = state.copyWith(selectedPetName: petName);
  }

  /// 탭 변경
  void changeTab(int index) {
    state.tabController?.animateTo(index);
  }
}
