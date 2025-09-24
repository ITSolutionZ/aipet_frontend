import 'package:aipet_frontend/features/onboarding/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/onboarding/domain/usecases/get_pet_profile_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart'
    as pet_registor_entity;
import 'package:aipet_frontend/shared/constants/pet_profile_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_controller.g.dart';

/// 펫 프로필 상태
class PetProfileState {
  final TabController? tabController;
  final pet_registor_entity.PetProfileEntity? selectedPet;
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
    pet_registor_entity.PetProfileEntity? selectedPet,
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
  GetPetProfileUseCase get _getPetProfileUseCase =>
      ref.read(getPetProfileUseCaseProvider);

  @override
  PetProfileState build() => const PetProfileState();

  /// 탭 컨트롤러 초기화
  void initializeTabController(TabController tabController) {
    state = state.copyWith(tabController: tabController);
  }

  /// 탭 컨트롤러 설정 (기존 호환성)
  void setTabController(TabController tabController) {
    state = state.copyWith(tabController: tabController);
  }

  /// 탭 컨트롤러 해제
  void disposeTabController() {
    state = state.copyWith(tabController: null);
  }

  /// 펫 선택
  void selectPet(pet_registor_entity.PetProfileEntity pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// 펫 프로필 로드
  Future<Result<void>> loadPetProfile({
    required String petId,
    required String requesterId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getPetProfileUseCase.execute(
        petId: petId,
        requesterId: requesterId,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          selectedPet: result.data as pet_registor_entity.PetProfileEntity,
          isLoading: false,
        );
        return Result.success('Pet profile loaded successfully');
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
        return Result.failure(result.message);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${PetProfileConstants.loadError}: $error',
      );
      return Result.failure('Failed to load pet profile: $error');
    }
  }

  /// 펫 프로필 직접 설정 (기존 호환성용)
  void setPetProfile(pet_registor_entity.PetProfileEntity pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// 프로필 새로고침
  Future<Result<void>> refreshProfile(String requesterId) async {
    final currentPet = state.selectedPet;
    if (currentPet != null) {
      return loadPetProfile(petId: currentPet.id, requesterId: requesterId);
    }
    return Result.failure('No pet selected for refresh');
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
    // 펫의 오너와 같은 경우 편집 가능
    return pet?.ownerId == userId;
  }

  /// 공유 가능 여부 확인
  bool get canShareProfile {
    // 펫이 활성화된 경우 공유 가능
    return state.selectedPet?.isActive ?? false;
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
    // pet_registor 엔티티에는 visibilityLevel이 없으므로 기본값 사용
    return 'Private';
  }

  /// 공개 수준 아이콘
  IconData get visibilityLevelIcon {
    // pet_registor 엔티티에는 visibilityLevel이 없으므로 기본 아이콘 사용
    return Icons.lock;
  }
}
