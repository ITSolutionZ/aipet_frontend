import 'package:aipet_frontend/features/pet_profile/data/providers/usecase_providers.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/get_pet_profile_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  void selectPet(PetProfileEntity pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// 펫 프로필 로드
  Future<Result<void>> loadPetProfile({required String petId, required String requesterId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getPetProfileUseCase.call(petId);

      if (result.isSuccess) {
        state = state.copyWith(selectedPet: result.dataOrNull, isLoading: false);
        return Result.success('Pet profile loaded successfully');
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
        return Result.failure(result.message);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load pet profile: $error');
      return Result.failure('Failed to load pet profile: $error');
    }
  }

  /// 펫 프로필 직접 설정 (기존 호환성용)
  void setPetProfile(PetProfileEntity pet) {
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
        return '基本情報';
      case 1:
        return '健康';
      case 2:
        return '栄養';
      case 3:
        return '共有';
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
    return _getPetTypeIcon(petType);
  }

  /// 프로필 타입 이름
  String get profileTypeName {
    final petType = state.selectedPet?.type ?? '';
    return _getPetTypeName(petType);
  }

  /// 공개 수준 표시명
  String get visibilityLevelName {
    return 'Private';
  }

  /// 공개 수준 아이콘
  IconData get visibilityLevelIcon {
    return Icons.lock;
  }

  /// 펫 타입 아이콘 반환
  String _getPetTypeIcon(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'fish':
        return '🐠';
      default:
        return '🐾';
    }
  }

  /// 펫 타입 이름 반환
  String _getPetTypeName(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'fish':
        return '魚';
      default:
        return 'ペット';
    }
  }
}
