import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/pet_profile_providers.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/usecases/get_pet_profile_usecase.dart';
import '../constants/pet_profile_constants.dart';

part 'pet_profile_controller.g.dart';

/// 펫 프로필 상태
class PetProfileState {
  final TabController? tabController;
  final PetProfileEntity? selectedPet;
  final bool isLoading;
  final String? errorMessage;

  const PetProfileState({
    this.tabController,
    this.selectedPet,
    this.isLoading = false,
    this.errorMessage,
  });

  PetProfileState copyWith({
    TabController? tabController,
    PetProfileEntity? selectedPet,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PetProfileState(
      tabController: tabController ?? this.tabController,
      selectedPet: selectedPet ?? this.selectedPet,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  String get selectedPetName => selectedPet?.name ?? 'Unknown Pet';

  bool get hasProfile => selectedPet != null;
}

/// 펫 프로필 컨트롤러 (Clean Architecture 적용)
@riverpod
class PetProfileNotifier extends _$PetProfileNotifier {
  GetPetProfileUseCase get _getPetProfileUseCase => ref.read(getPetProfileUseCaseProvider);

  @override
  PetProfileState build() => const PetProfileState();

  /// 탭 컨트롤러 설정
  void setTabController(TabController tabController) {
    state = state.copyWith(tabController: tabController);
  }

  /// 펫 프로필 로드
  Future<void> loadPetProfile({
    required String petId,
    required String requesterId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _getPetProfileUseCase.execute(
        petId: petId,
        requesterId: requesterId,
      );

      switch (result) {
        case GetPetProfileSuccess():
          state = state.copyWith(
            selectedPet: result.profile,
            isLoading: false,
          );

        case GetPetProfileNotFound():
          state = state.copyWith(
            isLoading: false,
            errorMessage: '${PetProfileConstants.loadError}: Profile not found',
          );

        case GetPetProfileAccessDenied():
          state = state.copyWith(
            isLoading: false,
            errorMessage: PetProfileConstants.accessDeniedMessage,
          );

        case GetPetProfileError():
          state = state.copyWith(
            isLoading: false,
            errorMessage: '${PetProfileConstants.loadError}: ${result.message}',
          );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${PetProfileConstants.loadError}: $error',
      );
    }
  }

  /// 펫 프로필 직접 설정 (기존 호환성용)
  void setPetProfile(PetProfileEntity pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// 프로필 새로고침
  Future<void> refreshProfile(String requesterId) async {
    final currentPet = state.selectedPet;
    if (currentPet != null) {
      await loadPetProfile(
        petId: currentPet.id,
        requesterId: requesterId,
      );
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 탭 인덱스 변경
  void changeTab(int index) {
    state.tabController?.animateTo(index);
  }

  /// 현재 탭 인덱스
  int get currentTabIndex => state.tabController?.index ?? 0;

  /// 탭별 제목 반환
  String getTabTitle(int index) {
    switch (index) {
      case 0:
        return PetProfileConstants.basicInfoTab;
      case 1:
        return PetProfileConstants.healthTab;
      case 2:
        return PetProfileConstants.nutritionTab;
      case 3:
        return PetProfileConstants.shareTab;
      default:
        return '';
    }
  }

  /// 편집 권한 확인
  bool canEditProfile(String userId) {
    final pet = state.selectedPet;
    return pet?.canBeEditedBy(userId) ?? false;
  }

  /// 공유 가능 여부 확인
  bool get canShareProfile {
    return state.selectedPet?.isShareable ?? false;
  }

  /// 프로필 타입 아이콘
  String get profileTypeIcon {
    final petType = state.selectedPet?.type ?? '';
    return PetTypeConstants.getIcon(petType);
  }

  /// 프로필 타입 이름
  String get profileTypeName {
    final petType = state.selectedPet?.type ?? '';
    return PetTypeConstants.getName(petType);
  }

  /// 공개 수준 표시명
  String get visibilityLevelName {
    final level = state.selectedPet?.visibilityLevel.name ?? 'private';
    return VisibilityLevelConstants.getName(level);
  }

  /// 공개 수준 아이콘
  IconData get visibilityLevelIcon {
    final level = state.selectedPet?.visibilityLevel.name ?? 'private';
    return VisibilityLevelConstants.getIcon(level);
  }
}