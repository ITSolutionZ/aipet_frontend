import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration/pet_registration.dart';
import 'package:aipet_frontend/features/pet_profile/data/data.dart';
import 'package:aipet_frontend/shared/core/services/firebase_token_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_registration_controller.g.dart';

/// Pet Registration Controller
///
/// **역할**: 펫 등록 폼의 상태 관리 및 비즈니스 로직 처리
/// - 펫 등록 폼 데이터 상태 관리
/// - 이미지 업로드 및 OCR 처리
/// - 로컬 저장소에 펫 데이터 저장
/// - 폼 유효성 검증
///
/// **사용 위치**: DailyPetRegistrationScreen에서 사용
/// **관련 파일**: PetRegistrationLogic (UI 로직 및 폼 제출)
@riverpod
class PetRegistrationController extends _$PetRegistrationController {
  late final PetRegistrationValidator _validator;
  late final PetOcrService _ocrService;
  late final PetRegistrationStorageService _storageService;

  @override
  PetRegistrationFormData build() {
    _validator = PetRegistrationValidator();
    _ocrService = PetOcrService();
    _storageService = PetRegistrationStorageService();

    LoggerService.debug(
      '🏗️ PetRegistrationController: Build called, starting initialization',
    );
    _loadSavedFormData();
    LoggerService.debug('🏗️ PetRegistrationController: Build completed');

    return PetRegistrationFormData.initialFormData;
  }

  // Controllers
  final _petNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _adoptionDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // Getters for controllers
  TextEditingController get petNameController => _petNameController;
  TextEditingController get birthDateController => _birthDateController;
  TextEditingController get adoptionDateController => _adoptionDateController;
  TextEditingController get weightController => _weightController;
  TextEditingController get appearanceController => _appearanceController;
  TextEditingController get guardianNameController => _guardianNameController;
  TextEditingController get institutionNameController =>
      _institutionNameController;
  TextEditingController get registrationNumberController =>
      _registrationNumberController;

  // Public getter for form data (외부에서 state 접근용)
  PetRegistrationFormData get formData => state;

  /// 선택된 펫 타입에 따른 품종 리스트 반환
  List<Map<String, dynamic>> get availableBreeds {
    final petTypeData = PetRegistrationConstants.petTypes[state.petType];
    return (petTypeData?['breeds'] as List<Map<String, dynamic>>?) ?? [];
  }

  // ================================
  // State management methods
  // ================================

  void updatePetName(String name) {
    LoggerService.debug('📝 updatePetName called with: $name');
    state = state.copyWith(petName: name);
    _autoSaveFormData();
  }

  void updateBirthDate(DateTime? date) {
    state = state.copyWith(birthDate: date);
    if (date != null) {
      _birthDateController.text =
          DateTimeUtils.formatDateKey(date);
    } else {
      _birthDateController.clear();
    }
    _autoSaveFormData();
  }

  void updateAdoptionDate(DateTime? date) {
    state = state.copyWith(adoptionDate: date);
    if (date != null) {
      _adoptionDateController.text =
          DateTimeUtils.formatDateKey(date);
    } else {
      _adoptionDateController.clear();
    }
    _autoSaveFormData();
  }

  void updateWeight(String weightText) {
    final weight = double.tryParse(weightText);
    state = state.copyWith(weight: weight);
    _autoSaveFormData();
  }

  void updateAppearance(String appearance) {
    state = state.copyWith(appearance: appearance);
    _autoSaveFormData();
  }

  void updatePetType(String petType) {
    state = state.copyWith(petType: petType, breed: '');
    _autoSaveFormData();
  }

  void updateBreed(String breed) {
    state = state.copyWith(breed: breed);
    _autoSaveFormData();
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
    _autoSaveFormData();
  }

  void updateNeuteringStatus(bool isNeutered) {
    state = state.copyWith(isNeutered: isNeutered);
    _autoSaveFormData();
  }

  void updateGuardianName(String name) {
    state = state.copyWith(guardianName: name);
    _autoSaveFormData();
  }

  void updateInstitutionName(String name) {
    state = state.copyWith(institutionName: name);
    _institutionNameController.text = name;
    _autoSaveFormData();
  }

  void updateRegistrationNumber(String number) {
    state = state.copyWith(registrationNumber: number);
    _registrationNumberController.text = number;
    _autoSaveFormData();
  }

  void updateFood(String food) {
    state = state.copyWith(food: food);
    _autoSaveFormData();
  }

  void updateSupplement(String supplement) {
    state = state.copyWith(supplement: supplement);
    _autoSaveFormData();
  }

  void updateTreat(String treat) {
    state = state.copyWith(treat: treat);
    _autoSaveFormData();
  }

  void updatePetImagePath(String? imagePath) {
    LoggerService.debug(
      '🖼️ PetRegistrationController: updatePetImagePath called with: $imagePath',
    );
    if (imagePath == null) {
      state = state.copyWith(clearPetImage: true);
      LoggerService.debug('🖼️ PetRegistrationController: Image cleared');
    } else {
      state = state.copyWith(petImagePath: imagePath);
      LoggerService.debug(
        '🖼️ PetRegistrationController: Image path set to: $imagePath',
      );
    }
    LoggerService.debug(
      '🖼️ PetRegistrationController: Updated state.petImagePath: ${state.petImagePath}',
    );
    _autoSaveFormData();
  }

  void setImageLoading(bool isLoading) {
    state = state.copyWith(isImageLoading: isLoading);
  }

  void updateRegistrationImagePath(String? imagePath) {
    state = state.copyWith(registrationImagePath: imagePath);
  }

  void setProcessingOCR(bool isProcessing) {
    state = state.copyWith(isProcessingOCR: isProcessing);
  }

  void addForbiddenIngredient(String ingredient) {
    if (state.forbiddenIngredients.length >= 8) {
      return; // 최대 8개 제한
    }
    if (ingredient.trim().isNotEmpty &&
        !state.forbiddenIngredients.contains(ingredient.trim())) {
      state = state.copyWith(
        forbiddenIngredients: [
          ...state.forbiddenIngredients,
          ingredient.trim(),
        ],
      );
      _autoSaveFormData();
    }
  }

  /// 원료 추가 (알림 포함)
  void addForbiddenIngredientWithNotification(
    String ingredient,
    BuildContext context,
  ) {
    if (state.forbiddenIngredients.length >= 8) {
      // ✅ Shared SnackBarService 사용
      SnackBarService.showWarning(context, '最大8個まで登録できます');
      return;
    }

    if (ingredient.trim().isNotEmpty &&
        !state.forbiddenIngredients.contains(ingredient.trim())) {
      addForbiddenIngredient(ingredient);

      // 6개 이상일 때 알림 표시
      if (state.forbiddenIngredients.length >= 6) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showInfo(
          context,
          '${state.forbiddenIngredients.length}/8個登録済み - 最大8個まで登録可能です',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void removeForbiddenIngredient(String ingredient) {
    state = state.copyWith(
      forbiddenIngredients: state.forbiddenIngredients
          .where((item) => item != ingredient)
          .toList(),
    );
    _autoSaveFormData();
  }

  void clearForbiddenIngredients() {
    state = state.copyWith(forbiddenIngredients: []);
  }

  void updateBodyPartsToManage(String bodyParts) {
    state = state.copyWith(bodyPartsToManage: bodyParts);
    _autoSaveFormData();
  }

  void clearBodyPartsToManage() {
    state = state.copyWith(bodyPartsToManage: '');
  }

  // ================================
  // 로컬 저장소 관련 메서드
  // ================================

  /// 폼 데이터를 로컬 저장소에 저장
  Future<void> saveFormDataToLocal() async {
    await _storageService.saveFormData(state);
  }

  /// 로컬 저장소에서 폼 데이터 로드
  Future<void> _loadSavedFormData() async {
    final savedData = await _storageService.loadFormData();
    if (savedData != null) {
      state = savedData;
      _updateControllersFromState(savedData);
      LoggerService.debug('📥 Form data loaded and controllers updated successfully');
    }
  }

  /// 수동으로 컨트롤러 초기화 (화면에서 호출용)
  Future<void> manualInit() async {
    LoggerService.debug('🔧 Manual initialization called');
    await _loadSavedFormData();
  }

  /// 로컬 저장소에서 폼 데이터 삭제
  Future<void> clearSavedFormData() async {
    await _storageService.clearFormData();
  }

  /// 자동 저장 (디바운스 적용)
  void _autoSaveFormData() {
    LoggerService.debug('🔄 Auto-save triggered');
    // 즉시 저장 (디바운스 제거하여 확실히 저장되도록)
    saveFormDataToLocal();
  }

  /// 상태로부터 텍스트 컨트롤러 업데이트
  void _updateControllersFromState(PetRegistrationFormData formData) {
    PetControllerSyncHelper.updateControllersFromState(
      formData,
      petNameController: _petNameController,
      birthDateController: _birthDateController,
      adoptionDateController: _adoptionDateController,
      weightController: _weightController,
      appearanceController: _appearanceController,
      guardianNameController: _guardianNameController,
      institutionNameController: _institutionNameController,
      registrationNumberController: _registrationNumberController,
    );
  }

  // ================================
  // 이미지 및 OCR 처리
  // ================================

  /// 이미지 선택 및 OCR 처리
  /// ✅ ImageService 사용을 위해 context 파라미터 추가
  Future<void> selectAndProcessRegistrationImage(BuildContext context) async {
    try {
      setProcessingOCR(true);

      // OCR 서비스를 사용하여 이미지 선택 및 처리
      final result = await _ocrService.selectAndProcessImage(context);

      if (result.isCancelled) {
        return;
      }

      if (result.isSuccess && result.imagePath != null) {
        // 이미지 경로 저장
        updateRegistrationImagePath(result.imagePath);

        // OCR 결과를 텍스트 필드에 자동 입력
        if (result.institutionName != null) {
          updateInstitutionName(result.institutionName!);
        }
        if (result.registrationNumber != null) {
          updateRegistrationNumber(result.registrationNumber!);
        }
      }

      if (result.error != null) {
        throw Exception(result.error);
      }
    } catch (e) {
      setProcessingOCR(false);
      rethrow;
    } finally {
      setProcessingOCR(false);
    }
  }

  // ================================
  // Validation methods
  // ================================

  String? validatePetName(String? value) => _validator.validatePetName(value);
  String? validateBirthDate(String? value) =>
      _validator.validateBirthDate(value);
  String? validateAdoptionDate(String? value) =>
      _validator.validateAdoptionDate(value);
  String? validateWeight(String? value) => _validator.validateWeight(value);
  String? validateAppearance(String? value) =>
      _validator.validateAppearance(value);
  String? validateBreed() => _validator.validateBreed(state.breed);
  String? validateGender() => _validator.validateGender(state.gender);

  /// 폼 전체 유효성 검사
  bool isFormValid() {
    return _validator.isFormValid(
      petName: state.petName,
      birthDate: state.birthDate,
      weight: state.weight,
      breed: state.breed,
      gender: state.gender,
    );
  }

  // ================================
  // Image provider helper
  // ================================

  ImageProvider<Object>? getPetImageProvider() {
    return PetImageProviderHelper.getImageProvider(state.petImagePath);
  }

  // ================================
  // Submit form
  // ================================

  Future<String> submitForm() async {
    // ref.read는 메서드 시작 시 동기적으로 호출
    if (!ref.mounted) {
      throw Exception('컨트롤러가 이미 제거되었습니다');
    }

    // ✅ Firebase Auth 로그인 확인
    final currentUserId = FirebaseTokenService.getCurrentUserId();
    if (currentUserId == null) {
      LoggerService.debug('❌ submitForm - Firebase Auth 로그인 필요');
      throw Exception('ペット登録にはログインが必要です。ログインしてから再度お試しください。');
    }
    LoggerService.debug('✅ Firebase Auth 로그인 확인 완료: $currentUserId');

    final petProfilesNotifier = ref.read(petProfilesProvider.notifier);
    final relationService = PetUserRelationService.instance;

    // 텍스트 컨트롤러와 state 동기화 확인
    LoggerService.debug('🔍 submitForm - Checking form validity:');
    LoggerService.debug(
      '  - petName from state: "${state.petName}" (empty: ${state.petName.isEmpty})',
    );
    LoggerService.debug('  - petName from controller: "${_petNameController.text}"');
    LoggerService.debug('  - weight from state: ${state.weight}');
    LoggerService.debug('  - weight from controller: "${_weightController.text}"');

    if (!isFormValid()) {
      LoggerService.debug('❌ submitForm - Form validation failed in submitForm()');
      throw Exception('すべての必須項目を入力してください');
    }

    LoggerService.debug(
      '✅ submitForm - Form validation passed, proceeding with registration',
    );

    // 실제 펫 프로필 생성 및 저장
    try {
      LoggerService.debug('🐾 Creating PetProfileEntity from form data...');

      // PetProfileEntity 생성
      final petEntity = PetProfileEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: state.petName,
        type: state.petType,
        breed: state.breed,
        birthDate: state.birthDate!,
        gender: state.gender,
        weight: state.weight!,
        imagePath: state.petImagePath,
        ownerId: currentUserId, // ✅ Firebase Auth 사용자 ID 사용
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        additionalInfo: {
          'isNeutered': state.isNeutered,
          'guardianName': state.guardianName,
          'institutionName': state.institutionName,
          'registrationNumber': state.registrationNumber,
          'adoptionDate': state.adoptionDate?.toIso8601String(),
          'forbiddenIngredients': state.forbiddenIngredients,
          'bodyPartsToManage': state.bodyPartsToManage,
          'appearance': state.appearance,
          'food': state.food,
          'supplement': state.supplement,
          'treat': state.treat,
        },
      );

      LoggerService.debug(
        '🐾 PetProfileEntity created: ${petEntity.name}, ${petEntity.type}, ${petEntity.breed}',
      );
      LoggerService.debug('🖼️ PetProfileEntity imagePath: ${petEntity.imagePath}');
      LoggerService.debug('🖼️ State petImagePath: ${state.petImagePath}');

      // 펫 등록 시 저장되는 모든 데이터 로그
      LoggerService.debug('📋 === 펫 등록 데이터 저장 로그 ===');
      LoggerService.debug('📋 펫 이름: ${petEntity.name}');
      LoggerService.debug('📋 펫 타입: ${petEntity.type}');
      LoggerService.debug('📋 펫 품종: ${petEntity.breed}');
      LoggerService.debug('📋 펫 성별: ${petEntity.gender}');
      LoggerService.debug('📋 펫 체중: ${petEntity.weight}');
      LoggerService.debug('📋 펫 이미지: ${petEntity.imagePath}');
      LoggerService.debug('📋 보호자 이름: ${state.guardianName}');
      LoggerService.debug('📋 기관 이름: ${state.institutionName}');
      LoggerService.debug('📋 등록번호: ${state.registrationNumber}');
      LoggerService.debug('📋 중성화 여부: ${state.isNeutered}');
      LoggerService.debug('📋 금지 원료: ${state.forbiddenIngredients}');
      LoggerService.debug('📋 관리 부위: ${state.bodyPartsToManage}');
      LoggerService.debug('📋 사료: ${state.food}');
      LoggerService.debug('📋 보조제: ${state.supplement}');
      LoggerService.debug('📋 간식: ${state.treat}');
      LoggerService.debug('📋 추가 정보: ${petEntity.additionalInfo}');
      LoggerService.debug('📋 ================================');

      // 펫 프로필 저장
      print('💾 ===== PET REGISTRATION START =====');
      print('💾 펫 이름: ${petEntity.name}');
      print('💾 펫 타입: ${petEntity.type}');
      LoggerService.debug('💾 PetProfilesNotifier.createPet() 호출 시작...');

      try {
        print('💾 createPet() 호출 중...');
        final createdPet = await petProfilesNotifier.createPet(petEntity);
        print('✅ createPet() 성공! ID: ${createdPet.id}');

        LoggerService.debug('✅ PetProfilesNotifier.createPet() 완료!');
        LoggerService.debug('   생성된 펫 ID: ${createdPet.id}');
        LoggerService.debug('   생성된 펫 이름: ${createdPet.name}');

        // 비동기 작업 후 ref 상태 확인
        if (!ref.mounted) {
          LoggerService.debug('⚠️ Controller disposed, 펫 ID 반환');
          return createdPet.id;
        }

        // 펫-사용자 관계 생성 (소유자로 등록)
        LoggerService.debug('🔗 펫-사용자 관계 생성 시도...');
        final relationSuccess = await relationService.addUserToPet(
          petId: createdPet.id,
          userId: 'local_user', // 현재 로컬 사용자 ID
          role: 'owner',
          permissions: 'full_access',
        );

        if (relationSuccess) {
          LoggerService.debug('✅ Pet-user relation created successfully');
        } else {
          LoggerService.debug('⚠️ Pet-user relation creation failed');
        }

        // Mock 데이터 처리 로그
        LoggerService.debug(
          'ペット登録完了: ${state.petName}, ${state.petType}, ${state.breed}, ${state.gender}, ${state.isNeutered}',
        );

        // 성공적으로 등록된 후 로컬 저장 데이터 삭제
        await clearSavedFormData();

        LoggerService.debug('✅ ===== Pet registration completed successfully =====');

        // 등록된 펫 ID 반환 (실제 생성된 ID 사용)
        return createdPet.id;
      } catch (creationError) {
        print('❌ ===== PetProfilesNotifier.createPet() 실패 =====');
        print('   에러 타입: ${creationError.runtimeType}');
        print('   에러 내용: $creationError');
        LoggerService.debug('❌ ===== PetProfilesNotifier.createPet() 실패 =====');
        LoggerService.debug('   에러 타입: ${creationError.runtimeType}');
        LoggerService.debug('   에러 내용: $creationError');
        rethrow;
      }
    } catch (e) {
      print('❌ ===== Pet registration FAILED =====');
      print('   최종 에러: $e');
      print('   에러 타입: ${e.runtimeType}');
      LoggerService.debug('❌ ===== Pet registration failed =====');
      LoggerService.debug('   최종 에러: $e');
      LoggerService.debug('   에러 타입: ${e.runtimeType}');
      rethrow;
    }
  }

  /// 펫 정보 업데이트 (편집 모드)
  Future<String> updatePetForm(String petId) async {
    // ref.read는 메서드 시작 시 동기적으로 호출
    if (!ref.mounted) {
      throw Exception('컨트롤러가 이미 제거되었습니다');
    }

    // ✅ Firebase Auth 로그인 확인
    final currentUserId = FirebaseTokenService.getCurrentUserId();
    if (currentUserId == null) {
      LoggerService.debug('❌ updatePetForm - Firebase Auth 로그인 필요');
      throw Exception('ペット情報の更新にはログインが必要です。');
    }
    LoggerService.debug('✅ Firebase Auth 로그인 확인 완료: $currentUserId');

    final petProfilesNotifier = ref.read(petProfilesProvider.notifier);

    try {
      LoggerService.debug('🔄 Updating pet profile for ID: $petId');

      // 펫 프로필 업데이트를 위한 PetProfileEntity 생성
      final petEntity = PetProfileEntity(
        id: petId, // 기존 ID 유지
        name: state.petName,
        type: state.petType,
        breed: state.breed,
        birthDate: state.birthDate!,
        gender: state.gender,
        weight: state.weight!,
        imagePath: state.petImagePath,
        ownerId: currentUserId, // ✅ Firebase Auth 사용자 ID 사용
        createdAt: DateTime.now(), // 기존 생성일 유지할 수 있지만 편의상 현재 시간 사용
        updatedAt: DateTime.now(),
        isActive: true,
        additionalInfo: {
          'isNeutered': state.isNeutered,
          'guardianName': state.guardianName,
          'institutionName': state.institutionName,
          'registrationNumber': state.registrationNumber,
          'adoptionDate': state.adoptionDate?.toIso8601String(),
          'forbiddenIngredients': state.forbiddenIngredients,
          'bodyPartsToManage': state.bodyPartsToManage,
          'appearance': state.appearance,
          'food': state.food,
          'supplement': state.supplement,
          'treat': state.treat,
        },
      );

      LoggerService.debug(
        '🔄 PetProfileEntity for update: ${petEntity.name}, ${petEntity.type}, ${petEntity.breed}',
      );

      // 펫 프로필 업데이트
      await petProfilesNotifier.updatePet(petEntity);

      // 비동기 작업 후 ref 상태 확인
      if (!ref.mounted) {
        return petId;
      }

      LoggerService.debug('✅ Pet profile updated successfully');
      LoggerService.debug('✅ Updated pet ID: $petId');

      // 성공적으로 업데이트된 후 로컬 저장 데이터 삭제
      await clearSavedFormData();

      LoggerService.debug('✅ Pet update completed successfully');

      // 업데이트된 펫 ID 반환 (기존 petId 사용)
      return petId;
    } catch (error) {
      LoggerService.debug('❌ Pet profile creation failed: $error');
      throw Exception('ペットプロフィール保存に失敗しました: $error');
    }
  }
}
