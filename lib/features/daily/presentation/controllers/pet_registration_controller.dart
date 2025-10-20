import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration/pet_registration.dart';
import 'package:aipet_frontend/features/pet_profile/data/data.dart';
import 'package:aipet_frontend/features/pet_profile/data/services/pet_user_relation_service.dart';
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

    debugPrint(
      '🏗️ PetRegistrationController: Build called, starting initialization',
    );
    _loadSavedFormData();
    debugPrint('🏗️ PetRegistrationController: Build completed');

    return PetRegistrationFormData.initialFormData;
  }

  // Controllers
  final _petNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _adoptionDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // Getters for controllers
  TextEditingController get petNameController => _petNameController;
  TextEditingController get birthDateController => _birthDateController;
  TextEditingController get adoptionDateController => _adoptionDateController;
  TextEditingController get weightController => _weightController;
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
    debugPrint('📝 updatePetName called with: $name');
    state = state.copyWith(petName: name);
    _autoSaveFormData();
  }

  void updateBirthDate(DateTime? date) {
    state = state.copyWith(birthDate: date);
    if (date != null) {
      _birthDateController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      _birthDateController.clear();
    }
    _autoSaveFormData();
  }

  void updateAdoptionDate(DateTime? date) {
    state = state.copyWith(adoptionDate: date);
    if (date != null) {
      _adoptionDateController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    debugPrint(
      '🖼️ PetRegistrationController: updatePetImagePath called with: $imagePath',
    );
    if (imagePath == null) {
      state = state.copyWith(clearPetImage: true);
      debugPrint('🖼️ PetRegistrationController: Image cleared');
    } else {
      state = state.copyWith(petImagePath: imagePath);
      debugPrint(
        '🖼️ PetRegistrationController: Image path set to: $imagePath',
      );
    }
    debugPrint(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('最大8個まで登録できます'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (ingredient.trim().isNotEmpty &&
        !state.forbiddenIngredients.contains(ingredient.trim())) {
      addForbiddenIngredient(ingredient);

      // 6개 이상일 때 알림 표시
      if (state.forbiddenIngredients.length >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${state.forbiddenIngredients.length}/8個登録済み - 最大8個まで登録可能です',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
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
      debugPrint('📥 Form data loaded and controllers updated successfully');
    }
  }

  /// 수동으로 컨트롤러 초기화 (화면에서 호출용)
  Future<void> manualInit() async {
    debugPrint('🔧 Manual initialization called');
    await _loadSavedFormData();
  }

  /// 로컬 저장소에서 폼 데이터 삭제
  Future<void> clearSavedFormData() async {
    await _storageService.clearFormData();
  }

  /// 자동 저장 (디바운스 적용)
  void _autoSaveFormData() {
    debugPrint('🔄 Auto-save triggered');
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
      guardianNameController: _guardianNameController,
      institutionNameController: _institutionNameController,
      registrationNumberController: _registrationNumberController,
    );
  }

  // ================================
  // 이미지 및 OCR 처리
  // ================================

  /// 이미지 선택 및 OCR 처리
  Future<void> selectAndProcessRegistrationImage() async {
    try {
      setProcessingOCR(true);

      // OCR 서비스를 사용하여 이미지 선택 및 처리
      final result = await _ocrService.selectAndProcessImage();

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
    // 텍스트 컨트롤러와 state 동기화 확인
    debugPrint('🔍 submitForm - Checking form validity:');
    debugPrint(
      '  - petName from state: "${state.petName}" (empty: ${state.petName.isEmpty})',
    );
    debugPrint('  - petName from controller: "${_petNameController.text}"');
    debugPrint('  - weight from state: ${state.weight}');
    debugPrint('  - weight from controller: "${_weightController.text}"');

    if (!isFormValid()) {
      debugPrint('❌ submitForm - Form validation failed in submitForm()');
      throw Exception('すべての必須項目を入力してください');
    }

    debugPrint(
      '✅ submitForm - Form validation passed, proceeding with registration',
    );

    // 실제 펫 프로필 생성 및 저장
    try {
      debugPrint('🐾 Creating PetProfileEntity from form data...');

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
        ownerId: 'local_user', // 로컬 사용자 ID (로컬 전용)
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
          'food': state.food,
          'supplement': state.supplement,
          'treat': state.treat,
        },
      );

      debugPrint(
        '🐾 PetProfileEntity created: ${petEntity.name}, ${petEntity.type}, ${petEntity.breed}',
      );
      debugPrint('🖼️ PetProfileEntity imagePath: ${petEntity.imagePath}');
      debugPrint('🖼️ State petImagePath: ${state.petImagePath}');

      // 펫 등록 시 저장되는 모든 데이터 로그
      debugPrint('📋 === 펫 등록 데이터 저장 로그 ===');
      debugPrint('📋 펫 이름: ${petEntity.name}');
      debugPrint('📋 펫 타입: ${petEntity.type}');
      debugPrint('📋 펫 품종: ${petEntity.breed}');
      debugPrint('📋 펫 성별: ${petEntity.gender}');
      debugPrint('📋 펫 체중: ${petEntity.weight}');
      debugPrint('📋 펫 이미지: ${petEntity.imagePath}');
      debugPrint('📋 보호자 이름: ${state.guardianName}');
      debugPrint('📋 기관 이름: ${state.institutionName}');
      debugPrint('📋 등록번호: ${state.registrationNumber}');
      debugPrint('📋 중성화 여부: ${state.isNeutered}');
      debugPrint('📋 금지 원료: ${state.forbiddenIngredients}');
      debugPrint('📋 관리 부위: ${state.bodyPartsToManage}');
      debugPrint('📋 사료: ${state.food}');
      debugPrint('📋 보조제: ${state.supplement}');
      debugPrint('📋 간식: ${state.treat}');
      debugPrint('📋 추가 정보: ${petEntity.additionalInfo}');
      debugPrint('📋 ================================');

      // 펫 프로필 저장
      // 프로바이더 ref는 비동기 작업 전에 미리 획득해야 함
      late final PetProfilesNotifier petProfilesNotifier;
      if (!ref.mounted) {
        throw Exception('컨트롤러가 이미 제거되었습니다');
      }
      petProfilesNotifier = ref.read(petProfilesProvider.notifier);

      // ref.mounted를 다시 확인 (비동기 작업 후)
      if (!ref.mounted) {
        throw Exception('컨트롤러가 이미 제거되었습니다');
      }

      final createdPet = await petProfilesNotifier.createPet(petEntity);

      // 비동기 작업 후 ref 상태 확인
      if (!ref.mounted) {
        return createdPet.id;
      }

      debugPrint('✅ Pet profile saved successfully to repository');
      debugPrint('✅ Created pet ID: ${createdPet.id}');

      // 펫-사용자 관계 생성 (소유자로 등록)
      final relationService = PetUserRelationService.instance;
      final relationSuccess = await relationService.addUserToPet(
        petId: createdPet.id,
        userId: 'local_user', // 현재 로컬 사용자 ID
        role: 'owner',
        permissions: 'full_access',
      );

      if (relationSuccess) {
        debugPrint('✅ Pet-user relation created successfully');
      } else {
        debugPrint('⚠️ Pet-user relation creation failed');
      }

      // Mock 데이터 처리 로그
      debugPrint(
        'ペット登録完了: ${state.petName}, ${state.petType}, ${state.breed}, ${state.gender}, ${state.isNeutered}',
      );

      // 성공적으로 등록된 후 로컬 저장 데이터 삭제
      await clearSavedFormData();

      debugPrint('✅ Pet registration completed successfully');

      // 등록된 펫 ID 반환 (실제 생성된 ID 사용)
      return createdPet.id;
    } catch (e) {
      debugPrint('❌ Pet registration failed: $e');
      rethrow;
    }
  }

  /// 펫 정보 업데이트 (편집 모드)
  Future<String> updatePetForm(String petId) async {
    try {
      debugPrint('🔄 Updating pet profile for ID: $petId');

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
        ownerId: 'local_user', // 로컬 사용자 ID
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
          'food': state.food,
          'supplement': state.supplement,
          'treat': state.treat,
        },
      );

      debugPrint(
        '🔄 PetProfileEntity for update: ${petEntity.name}, ${petEntity.type}, ${petEntity.breed}',
      );

      // 펫 프로필 업데이트
      // 프로바이더 ref는 비동기 작업 전에 미리 획득해야 함
      late final PetProfilesNotifier petProfilesNotifier;
      if (!ref.mounted) {
        throw Exception('컨트롤러가 이미 제거되었습니다');
      }
      petProfilesNotifier = ref.read(petProfilesProvider.notifier);

      // ref.mounted를 다시 확인 (비동기 작업 후)
      if (!ref.mounted) {
        throw Exception('컨트롤러가 이미 제거되었습니다');
      }

      await petProfilesNotifier.updatePet(petEntity);

      // 비동기 작업 후 ref 상태 확인
      if (!ref.mounted) {
        return petId;
      }

      debugPrint('✅ Pet profile updated successfully');
      debugPrint('✅ Updated pet ID: $petId');

      // 성공적으로 업데이트된 후 로컬 저장 데이터 삭제
      await clearSavedFormData();

      debugPrint('✅ Pet update completed successfully');

      // 업데이트된 펫 ID 반환 (기존 petId 사용)
      return petId;
    } catch (error) {
      debugPrint('❌ Pet profile creation failed: $error');
      throw Exception('ペットプロフィール保存に失敗しました: $error');
    }
  }
}
