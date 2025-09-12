import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';

part 'pet_profile_controller.g.dart';

/// 펫 프로필 상태
class PetProfileState {
  final TabController? tabController;
  final PetProfileEntity? selectedPet;

  const PetProfileState({this.tabController, this.selectedPet});

  PetProfileState copyWith({
    TabController? tabController,
    PetProfileEntity? selectedPet,
  }) {
    return PetProfileState(
      tabController: tabController ?? this.tabController,
      selectedPet: selectedPet ?? this.selectedPet,
    );
  }
  
  String get selectedPetName => selectedPet?.name ?? 'Unknown Pet';
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
  void selectPet(PetProfileEntity pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// 탭 변경
  void changeTab(int index) {
    state.tabController?.animateTo(index);
  }
}
