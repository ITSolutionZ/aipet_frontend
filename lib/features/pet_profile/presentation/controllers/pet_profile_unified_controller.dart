import 'package:aipet_frontend/features/pet_profile/presentation/logic/pet_profile_logic.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_unified_controller.freezed.dart';
part 'pet_profile_unified_controller.g.dart';

/// Pet Profile 통합 상태
@freezed
class PetProfileUnifiedState with _$PetProfileUnifiedState {
  const factory PetProfileUnifiedState({
    @Default(null) PetProfileEntity? selectedPet,
    @Default(null) TabController? tabController,
    @Default(false) bool isLoading,
    @Default(false) bool isEditMode,
    @Default(null) String? errorMessage,
    @Default(0) int currentTabIndex,
    @Default({}) Map<String, dynamic> editFormData,
  }) = _PetProfileUnifiedState;
}

/// Pet Profile 통합 컨트롤러
///
/// 모든 Pet Profile 관련 상태를 통합 관리합니다.
/// Clean Architecture를 적용하여 UI와 비즈니스 로직을 분리합니다.
@riverpod
class PetProfileUnifiedController extends _$PetProfileUnifiedController {
  late final PetProfileLogic _logic = PetProfileLogic(ref);

  @override
  PetProfileUnifiedState build() => const PetProfileUnifiedState();

  /// 펫 선택
  void selectPet(PetProfileEntity pet) {
    state = state.copyWith(
      selectedPet: pet,
      editFormData: _initializeEditFormData(pet),
      errorMessage: null,
    );
  }

  /// 탭 컨트롤러 초기화
  void initializeTabController(TabController tabController) {
    state = state.copyWith(tabController: tabController);
  }

  /// 탭 컨트롤러 해제
  void disposeTabController() {
    state = state.copyWith(tabController: null);
  }

  /// 탭 변경
  void changeTab(int index) {
    state = state.copyWith(currentTabIndex: index);
    state.tabController?.animateTo(index);
  }

  /// 편집 모드 토글
  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode, errorMessage: null);

    // 편집 모드 진입 시 폼 데이터 초기화
    if (state.isEditMode && state.selectedPet != null) {
      state = state.copyWith(
        editFormData: _initializeEditFormData(state.selectedPet!),
      );
    }
  }

  /// 폼 데이터 업데이트
  void updateFormData(String key, dynamic value) {
    final updatedData = Map<String, dynamic>.from(state.editFormData);
    updatedData[key] = value;
    state = state.copyWith(editFormData: updatedData);
  }

  /// 펫 프로필 로드
  Future<void> loadPetProfile(String petId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    debugPrint('🔍 Loading pet profile with ID: $petId');

    final result = await _logic.loadPetProfile(petId);

    if (result.isSuccess) {
      final pet = result.dataOrNull;
      if (pet != null) {
        debugPrint('✅ Pet profile loaded successfully: ${pet.name}');
        selectPet(pet);
      } else {
        debugPrint('❌ Pet not found with ID: $petId');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ペットが見つかりません (ID: $petId)',
        );
      }
    } else {
      debugPrint('❌ Failed to load pet profile: ${result.message}');
      state = state.copyWith(isLoading: false, errorMessage: result.message);
    }
  }

  /// 펫 프로필 저장
  Future<void> savePetProfile() async {
    if (state.selectedPet == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 폼 데이터로 펫 엔티티 업데이트
      final updatedPet = _buildUpdatedPetFromFormData();

      final result = await _logic.updatePetProfile(updatedPet);

      if (result.isSuccess) {
        state = state.copyWith(
          selectedPet: result.dataOrNull,
          isEditMode: false,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '保存に失敗しました: ${e.toString()}',
      );
    }
  }

  /// 펫 프로필 삭제
  Future<void> deletePetProfile() async {
    if (state.selectedPet == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _logic.deletePetProfile(state.selectedPet!.id);

    if (result.isSuccess) {
      state = state.copyWith(
        selectedPet: null,
        isEditMode: false,
        isLoading: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
    }
  }

  /// 펫 이미지 업로드
  Future<void> uploadPetImage(String imagePath) async {
    if (state.selectedPet == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _logic.uploadPetImage(
      state.selectedPet!.id,
      imagePath,
    );

    if (result.isSuccess) {
      // 이미지 경로 업데이트
      final updatedPet = state.selectedPet!.copyWith(
        imagePath: result.dataOrNull,
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(
        selectedPet: updatedPet,
        isLoading: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 편집 취소
  void cancelEdit() {
    if (state.selectedPet != null) {
      state = state.copyWith(
        isEditMode: false,
        editFormData: _initializeEditFormData(state.selectedPet!),
        errorMessage: null,
      );
    }
  }

  /// 편집 권한 확인
  bool canEdit(String userId) {
    return state.selectedPet != null &&
        _logic.canEditProfile(state.selectedPet!, userId);
  }

  /// 공유 가능 여부 확인
  bool get canShare {
    return state.selectedPet != null &&
        _logic.canShareProfile(state.selectedPet!);
  }

  /// 펫 타입 아이콘
  String get petTypeIcon {
    return state.selectedPet != null
        ? _logic.getPetTypeIcon(state.selectedPet!.type)
        : '🐾';
  }

  /// 펫 타입 이름
  String get petTypeName {
    return state.selectedPet != null
        ? _logic.getPetTypeName(state.selectedPet!.type)
        : 'ペット';
  }

  /// 성별 표시명
  String get genderDisplayName {
    return state.selectedPet != null
        ? _logic.getGenderDisplayName(state.selectedPet!.gender)
        : '不明';
  }

  /// 나이
  int get age {
    return state.selectedPet != null
        ? _logic.calculateAge(state.selectedPet!.birthDate)
        : 0;
  }

  /// 생년월일 포맷팅
  String get formattedBirthDate {
    return state.selectedPet != null
        ? _logic.formatBirthDate(state.selectedPet!.birthDate)
        : '';
  }

  /// 권장 산책 시간
  int get recommendedWalkTime {
    return state.selectedPet != null
        ? _logic.getRecommendedWalkTime(state.selectedPet!)
        : 0;
  }

  /// 편집 폼 데이터 초기화
  Map<String, dynamic> _initializeEditFormData(PetProfileEntity pet) {
    return {
      'name': pet.name,
      'gender': pet.gender,
      'weight': pet.weight,
      'breed': pet.breed ?? '',
      'appearance': pet.additionalInfo?['appearance'] ?? '',
      'microchipId': pet.additionalInfo?['microchipId'] ?? '',
      'neutered': pet.neutered ?? false,
    };
  }

  /// 폼 데이터로 업데이트된 펫 엔티티 생성
  PetProfileEntity _buildUpdatedPetFromFormData() {
    final pet = state.selectedPet!;
    final formData = state.editFormData;

    return pet.copyWith(
      name: formData['name'] as String? ?? pet.name,
      gender: formData['gender'] as String? ?? pet.gender,
      weight: formData['weight'] as double? ?? pet.weight,
      breed: formData['breed'] as String? ?? pet.breed,
      neutered: formData['neutered'] as bool? ?? pet.neutered,
      additionalInfo: {
        ...pet.additionalInfo ?? {},
        'appearance': formData['appearance'] as String? ?? '',
        'microchipId': formData['microchipId'] as String? ?? '',
      },
      updatedAt: DateTime.now(),
    );
  }
}
