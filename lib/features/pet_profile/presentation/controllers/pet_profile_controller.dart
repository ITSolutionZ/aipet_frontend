import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';

/// 펫 프로필 컨트롤러
class PetProfileController extends StateNotifier<PetProfileState> {
  PetProfileController() : super(const PetProfileState());

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

/// 컨트롤러 프로바이더
final petProfileControllerProvider =
    StateNotifierProvider<PetProfileController, PetProfileState>((ref) {
      return PetProfileController();
    });
