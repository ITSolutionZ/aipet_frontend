import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// 펫 등록 폼 데이터 모델
class PetRegistrationFormData {
  final String petName;
  final DateTime? birthDate;
  final DateTime? adoptionDate;
  final double? weight;
  final String petType;
  final String breed;
  final String gender;
  final bool isNeutered;
  final String guardianName;
  final String institutionName;
  final String registrationNumber;
  final String? petImagePath;
  final String? registrationImagePath;
  final bool isProcessingOCR;
  final bool isImageLoading;
  final List<String> forbiddenIngredients;
  final String bodyPartsToManage;
  final String food;
  final String supplement;
  final String treat;

  const PetRegistrationFormData({
    required this.petName,
    this.birthDate,
    this.adoptionDate,
    this.weight,
    required this.petType,
    required this.breed,
    required this.gender,
    required this.isNeutered,
    required this.guardianName,
    required this.institutionName,
    required this.registrationNumber,
    this.petImagePath,
    this.registrationImagePath,
    this.isProcessingOCR = false,
    this.isImageLoading = false,
    this.forbiddenIngredients = const [],
    this.bodyPartsToManage = '',
    this.food = '',
    this.supplement = '',
    this.treat = '',
  });

  PetRegistrationFormData copyWith({
    String? petName,
    DateTime? birthDate,
    DateTime? adoptionDate,
    double? weight,
    String? petType,
    String? breed,
    String? gender,
    bool? isNeutered,
    String? guardianName,
    String? institutionName,
    String? registrationNumber,
    String? petImagePath,
    String? registrationImagePath,
    bool? isProcessingOCR,
    bool? isImageLoading,
    List<String>? forbiddenIngredients,
    String? bodyPartsToManage,
    String? food,
    String? supplement,
    String? treat,
    bool clearPetImage = false,
    bool clearRegistrationImage = false,
  }) {
    return PetRegistrationFormData(
      petName: petName ?? this.petName,
      birthDate: birthDate ?? this.birthDate,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      weight: weight ?? this.weight,
      petType: petType ?? this.petType,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      isNeutered: isNeutered ?? this.isNeutered,
      guardianName: guardianName ?? this.guardianName,
      institutionName: institutionName ?? this.institutionName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      petImagePath: clearPetImage ? null : (petImagePath ?? this.petImagePath),
      registrationImagePath: clearRegistrationImage
          ? null
          : (registrationImagePath ?? this.registrationImagePath),
      isProcessingOCR: isProcessingOCR ?? this.isProcessingOCR,
      isImageLoading: isImageLoading ?? this.isImageLoading,
      forbiddenIngredients: forbiddenIngredients ?? this.forbiddenIngredients,
      bodyPartsToManage: bodyPartsToManage ?? this.bodyPartsToManage,
      food: food ?? this.food,
      supplement: supplement ?? this.supplement,
      treat: treat ?? this.treat,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'petName': petName,
      'birthDate': birthDate?.toIso8601String(),
      'adoptionDate': adoptionDate?.toIso8601String(),
      'weight': weight,
      'petType': petType,
      'breed': breed,
      'gender': gender,
      'isNeutered': isNeutered,
      'guardianName': guardianName,
      'institutionName': institutionName,
      'registrationNumber': registrationNumber,
      'petImagePath': petImagePath,
      'registrationImagePath': registrationImagePath,
      'forbiddenIngredients': forbiddenIngredients,
      'bodyPartsToManage': bodyPartsToManage,
      'food': food,
      'supplement': supplement,
      'treat': treat,
    };
  }

  /// JSON 역직렬화
  factory PetRegistrationFormData.fromJson(Map<String, dynamic> json) {
    return PetRegistrationFormData(
      petName: json['petName'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      adoptionDate: json['adoptionDate'] != null
          ? DateTime.parse(json['adoptionDate'])
          : null,
      weight: json['weight']?.toDouble(),
      petType: json['petType'] ?? 'dog',
      breed: json['breed'] ?? '',
      gender: json['gender'] ?? '',
      isNeutered: json['isNeutered'] ?? false,
      guardianName: json['guardianName'] ?? '',
      institutionName: json['institutionName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      petImagePath: json['petImagePath'],
      registrationImagePath: json['registrationImagePath'],
      forbiddenIngredients: List<String>.from(
        json['forbiddenIngredients'] ?? [],
      ),
      bodyPartsToManage: json['bodyPartsToManage'] ?? '',
      food: json['food'] ?? '',
      supplement: json['supplement'] ?? '',
      treat: json['treat'] ?? '',
    );
  }
}

/// 펫 등록 컨트롤러
class PetRegistrationController extends StateNotifier<PetRegistrationFormData> {
  final Ref _ref;

  PetRegistrationController(this._ref) : super(_initialFormData) {
    debugPrint(
      '🏗️ PetRegistrationController: Constructor called, starting initialization',
    );
    _loadSavedFormData();
    debugPrint('🏗️ PetRegistrationController: Constructor completed');
  }

  static const PetRegistrationFormData _initialFormData =
      PetRegistrationFormData(
        petName: '',
        petType: 'dog',
        breed: 'ゴールデンレトリバー', // 기본 품종 설정
        gender: 'オス', // 기본 성별 설정
        isNeutered: false,
        guardianName: '',
        institutionName: '',
        registrationNumber: '',
        registrationImagePath: null,
        isProcessingOCR: false,
      );

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

  // Pet type and breed data with images
  static const List<Map<String, dynamic>> dogBreeds = [
    {'name': '柴犬', 'image': 'assets/images/breeds/dogs/shiba.png'},
    {
      'name': 'ゴールデンレトリバー',
      'image': 'assets/images/breeds/dogs/golden_retriever.png',
    },
    {'name': 'ラブラドール', 'image': 'assets/images/breeds/dogs/labrador.png'},
    {'name': '푸들', 'image': 'assets/images/breeds/dogs/poodle.png'},
    {'name': '치와와', 'image': 'assets/images/breeds/dogs/chihuahua.png'},
    {'name': '닥스훈트', 'image': 'assets/images/breeds/dogs/dachshund.png'},
    {'name': '허스키', 'image': 'assets/images/breeds/dogs/husky.png'},
    {'name': '기타', 'image': 'assets/images/breeds/dogs/other.png'},
  ];

  static const List<Map<String, dynamic>> catBreeds = [
    {
      'name': '아메리칸 숏헤어',
      'image': 'assets/images/breeds/cats/american_shorthair.png',
    },
    {'name': '페르시안', 'image': 'assets/images/breeds/cats/persian.png'},
    {'name': '메인쿤', 'image': 'assets/images/breeds/cats/maine_coon.png'},
    {'name': '래그돌', 'image': 'assets/images/breeds/cats/ragdoll.png'},
    {'name': '스코티시 폴드', 'image': 'assets/images/breeds/cats/scottish_fold.png'},
    {
      'name': '브리티시 숏헤어',
      'image': 'assets/images/breeds/cats/british_shorthair.png',
    },
    {'name': '기타', 'image': 'assets/images/breeds/cats/other.png'},
  ];

  static const List<String> genders = ['남아', '여아'];

  // 펫 타입 데이터 (아이콘과 함께)
  static const Map<String, Map<String, dynamic>> petTypes = {
    'dog': {
      'name': '강아지',
      'icon': Icons.pets,
      'breeds': dogBreeds,
      'image': 'assets/images/pet_types/dog.png',
    },
    'cat': {
      'name': '고양이',
      'icon': Icons.cruelty_free,
      'breeds': catBreeds,
      'image': 'assets/images/pet_types/cat.png',
    },
    'bird': {
      'name': '새',
      'icon': Icons.flight,
      'breeds': [
        {'name': '카나리아', 'image': 'assets/images/breeds/birds/canary.png'},
        {'name': '잉꼬', 'image': 'assets/images/breeds/birds/budgie.png'},
        {'name': '앵무새', 'image': 'assets/images/breeds/birds/parrot.png'},
        {'name': '비둘기', 'image': 'assets/images/breeds/birds/pigeon.png'},
        {'name': '참새', 'image': 'assets/images/breeds/birds/sparrow.png'},
        {'name': '기타', 'image': 'assets/images/breeds/birds/other.png'},
      ],
      'image': 'assets/images/pet_types/bird.png',
    },
    'rabbit': {
      'name': '토끼',
      'icon': Icons.adjust,
      'breeds': [
        {
          'name': '네덜란드 드워프',
          'image': 'assets/images/breeds/rabbits/netherland_dwarf.png',
        },
        {'name': '미니 랍', 'image': 'assets/images/breeds/rabbits/mini_lop.png'},
        {'name': '라이온헤드', 'image': 'assets/images/breeds/rabbits/lionhead.png'},
        {'name': '앵고라', 'image': 'assets/images/breeds/rabbits/angora.png'},
        {'name': '기타', 'image': 'assets/images/breeds/rabbits/other.png'},
      ],
      'image': 'assets/images/pet_types/rabbit.png',
    },
    'hamster': {
      'name': '햄스터',
      'icon': Icons.circle,
      'breeds': [
        {'name': '골든 햄스터', 'image': 'assets/images/breeds/hamsters/golden.png'},
        {
          'name': '윈터 화이트',
          'image': 'assets/images/breeds/hamsters/winter_white.png',
        },
        {
          'name': '로보로브스키',
          'image': 'assets/images/breeds/hamsters/roborovski.png',
        },
        {'name': '기타', 'image': 'assets/images/breeds/hamsters/other.png'},
      ],
      'image': 'assets/images/pet_types/hamster.png',
    },
    'fish': {
      'name': '물고기',
      'icon': Icons.water_drop,
      'breeds': [
        {'name': '금붕어', 'image': 'assets/images/breeds/fish/goldfish.png'},
        {'name': '구피', 'image': 'assets/images/breeds/fish/guppy.png'},
        {'name': '네온 테트라', 'image': 'assets/images/breeds/fish/neon_tetra.png'},
        {'name': '베타', 'image': 'assets/images/breeds/fish/betta.png'},
        {'name': '기타', 'image': 'assets/images/breeds/fish/other.png'},
      ],
      'image': 'assets/images/pet_types/fish.png',
    },
    'turtle': {
      'name': '거북이',
      'icon': Icons.circle_outlined,
      'breeds': [
        {
          'name': '붉은귀거북',
          'image': 'assets/images/breeds/turtles/red_eared_slider.png',
        },
        {
          'name': '녹색거북',
          'image': 'assets/images/breeds/turtles/green_turtle.png',
        },
        {
          'name': '육지거북',
          'image': 'assets/images/breeds/turtles/land_turtle.png',
        },
        {
          'name': '바다거북',
          'image': 'assets/images/breeds/turtles/sea_turtle.png',
        },
        {'name': '기타', 'image': 'assets/images/breeds/turtles/other.png'},
      ],
      'image': 'assets/images/pet_types/turtle.png',
    },
    'other': {
      'name': '기타',
      'icon': Icons.pets_outlined,
      'breeds': [
        {'name': '기타', 'image': 'assets/images/breeds/others/other.png'},
      ],
      'image': 'assets/images/pet_types/other.png',
    },
  };

  List<Map<String, dynamic>> get availableBreeds {
    final petTypeData = petTypes[state.petType];
    return (petTypeData?['breeds'] as List<Map<String, dynamic>>?) ?? [];
  }

  // State management methods
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
    print(
      '🖼️ PetRegistrationController: updatePetImagePath called with: $imagePath',
    );
    if (imagePath == null) {
      state = state.copyWith(clearPetImage: true);
    } else {
      state = state.copyWith(petImagePath: imagePath);
    }
    print(
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
    try {
      debugPrint('💾 Starting to save form data to local storage');
      final localDataManager = LocalDataManager.instance;
      if (!localDataManager.isInitialized) {
        debugPrint('💾 Initializing LocalDataManager');
        await localDataManager.initialize();
      }
      final jsonData = state.toJson();
      debugPrint('💾 Form data to save: ${jsonData.toString()}');
      await localDataManager.savePetRegistrationFormData(jsonData);
      debugPrint('💾 Form data saved successfully');
    } catch (e) {
      debugPrint('❌ 펫 등록 폼 데이터 저장 실패: $e');
    }
  }

  /// 로컬 저장소에서 폼 데이터 로드
  Future<void> _loadSavedFormData() async {
    try {
      debugPrint('📥 Starting to load saved form data');
      final localDataManager = LocalDataManager.instance;
      if (!localDataManager.isInitialized) {
        debugPrint('📥 Initializing LocalDataManager for loading');
        await localDataManager.initialize();
      }
      final savedData = await localDataManager.loadPetRegistrationFormData();
      if (savedData != null) {
        debugPrint('📥 Found saved data: ${savedData.toString()}');
        final formData = PetRegistrationFormData.fromJson(savedData);
        state = formData;

        // 텍스트 컨트롤러 업데이트
        _petNameController.text = formData.petName;
        if (formData.birthDate != null) {
          _birthDateController.text =
              '${formData.birthDate!.year}-${formData.birthDate!.month.toString().padLeft(2, '0')}-${formData.birthDate!.day.toString().padLeft(2, '0')}';
        }
        if (formData.adoptionDate != null) {
          _adoptionDateController.text =
              '${formData.adoptionDate!.year}-${formData.adoptionDate!.month.toString().padLeft(2, '0')}-${formData.adoptionDate!.day.toString().padLeft(2, '0')}';
        }
        if (formData.weight != null) {
          _weightController.text = formData.weight.toString();
        }
        _guardianNameController.text = formData.guardianName;
        _institutionNameController.text = formData.institutionName;
        _registrationNumberController.text = formData.registrationNumber;
        debugPrint('📥 Form data loaded and controllers updated successfully');
      } else {
        debugPrint('📥 No saved data found');
      }
    } catch (e) {
      debugPrint('❌ 펫 등록 폼 데이터 로드 실패: $e');
    }
  }

  /// 수동으로 컨트롤러 초기화 (화면에서 호출용)
  Future<void> manualInit() async {
    debugPrint('🔧 Manual initialization called');
    await _loadSavedFormData();
  }

  /// 로컬 저장소에서 폼 데이터 삭제
  Future<void> clearSavedFormData() async {
    try {
      final localDataManager = LocalDataManager.instance;
      if (!localDataManager.isInitialized) {
        await localDataManager.initialize();
      }
      await localDataManager.clearPetRegistrationFormData();
    } catch (e) {
      debugPrint('펫 등록 폼 데이터 삭제 실패: $e');
    }
  }

  /// 자동 저장 (디바운스 적용)
  void _autoSaveFormData() {
    debugPrint('🔄 Auto-save triggered');
    // 즉시 저장 (디바운스 제거하여 확실히 저장되도록)
    saveFormDataToLocal();
  }

  /// 이미지 선택 및 OCR 처리
  Future<void> selectAndProcessRegistrationImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      // 이미지 경로 저장 및 OCR 처리 시작
      updateRegistrationImagePath(image.path);
      setProcessingOCR(true);

      // OCR 처리
      await _processImageWithOCR(image.path);
    } catch (e) {
      setProcessingOCR(false);
      rethrow;
    } finally {
      setProcessingOCR(false);
    }
  }

  /// Google ML Kit을 사용한 OCR 처리
  Future<void> _processImageWithOCR(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      // OCR 결과에서 기관명과 등록번호 추출
      String? institutionName;
      String? registrationNumber;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final String lineText = line.text.toLowerCase();

          // 기관명 패턴 찾기 (예: "시청", "구청", "동물보호센터" 등)
          if (lineText.contains('시청') ||
              lineText.contains('구청') ||
              lineText.contains('동물보호') ||
              lineText.contains('센터') ||
              lineText.contains('관리사업소')) {
            institutionName = line.text.trim();
          }

          // 등록번호 패턴 찾기 (숫자로만 구성된 10-15자리)
          if (RegExp(r'^\d{10,15}$').hasMatch(line.text.trim())) {
            registrationNumber = line.text.trim();
          }
        }
      }

      // 결과를 텍스트 필드에 자동 입력
      if (institutionName != null) {
        updateInstitutionName(institutionName);
      }
      if (registrationNumber != null) {
        updateRegistrationNumber(registrationNumber);
      }

      await textRecognizer.close();
    } catch (e) {
      rethrow;
    }
  }

  // Validation methods
  String? validatePetName(String? value) {
    print('🔍 Validating pet name: "$value"');
    if (value == null || value.trim().isEmpty) {
      print('❌ Pet name validation failed: empty');
      return 'ペットの名前を入力してください';
    }
    if (value.length < 2 || value.length > 10) {
      print('❌ Pet name validation failed: length ${value.length}');
      return '2〜10文字で入力してください';
    }
    print('✅ Pet name validation passed');
    return null;
  }

  String? validateBirthDate(String? value) {
    print('🔍 Validating birth date: "$value"');
    if (value == null || value.trim().isEmpty) {
      print('❌ Birth date validation failed: empty');
      return '生年月日を入力してください';
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      print('❌ Birth date validation failed: invalid format');
      return 'YYYY-MM-DD形式で入力してください';
    }
    print('✅ Birth date validation passed');
    return null;
  }

  String? validateAdoptionDate(String? value) {
    // 집에 온 날은 선택사항이므로 빈 값이어도 됩니다
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'YYYY-MM-DD形式で入力してください';
    }
    return null;
  }

  String? validateWeight(String? value) {
    print('🔍 Validating weight: "$value"');
    if (value == null || value.trim().isEmpty) {
      print('❌ Weight validation failed: empty');
      return '体重を入力してください';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0 || weight > 100) {
      print('❌ Weight validation failed: invalid value $weight');
      return '有効な体重を入力してください';
    }
    print('✅ Weight validation passed');
    return null;
  }

  String? validateBreed() {
    print(
      '🔍 Validating breed: "${state.breed}" (empty: ${state.breed.isEmpty})',
    );
    if (state.breed.isEmpty) {
      print('❌ Breed validation failed: breed is empty');
      return '品種を選択してください';
    }
    print('✅ Breed validation passed');
    return null;
  }

  String? validateGender() {
    print(
      '🔍 Validating gender: "${state.gender}" (empty: ${state.gender.isEmpty})',
    );
    if (state.gender.isEmpty) {
      print('❌ Gender validation failed: gender is empty');
      return '性別を選択してください';
    }
    print('✅ Gender validation passed');
    return null;
  }

  // Form validation
  bool isFormValid() {
    return state.petName.isNotEmpty &&
        state.birthDate != null &&
        state.weight != null &&
        state.breed.isNotEmpty &&
        state.gender.isNotEmpty;
  }

  // Image provider helper
  ImageProvider<Object>? getPetImageProvider() {
    final path = state.petImagePath;
    if (path == null || path.isEmpty) {
      return null;
    }

    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    if (kIsWeb) {
      return NetworkImage(path);
    }

    try {
      return FileImage(File(path));
    } catch (_) {
      return null;
    }
  }

  // Submit form
  Future<void> submitForm() async {
    // 텍스트 컨트롤러와 state 동기화 확인
    print('🔍 submitForm - Checking form validity:');
    print(
      '  - petName from state: "${state.petName}" (empty: ${state.petName.isEmpty})',
    );
    print('  - petName from controller: "${_petNameController.text}"');
    print('  - weight from state: ${state.weight}');
    print('  - weight from controller: "${_weightController.text}"');

    if (!isFormValid()) {
      print('❌ submitForm - Form validation failed in submitForm()');
      throw Exception('모든 필수 항목을 입력해주세요');
    }

    print(
      '✅ submitForm - Form validation passed, proceeding with registration',
    );

    // 실제 펫 프로필 생성 및 저장
    try {
      print('🐾 Creating PetProfileEntity from form data...');

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
        ownerId: 'current_user', // TODO: 실제 사용자 ID로 교체
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

      print(
        '🐾 PetProfileEntity created: ${petEntity.name}, ${petEntity.type}, ${petEntity.breed}',
      );

      // 펫 프로필 저장
      final petProfilesNotifier = _ref.read(
        petProfilesNotifierProvider.notifier,
      );
      await petProfilesNotifier.createPet(petEntity);

      print('✅ Pet profile saved successfully to repository');

      // Mock 데이터 처리 로그
      debugPrint(
        'ペット登録完了: ${state.petName}, ${state.petType}, ${state.breed}, ${state.gender}, ${state.isNeutered}',
      );

      // 성공적으로 등록된 후 로컬 저장 데이터 삭제
      await clearSavedFormData();

      print('✅ Pet registration completed successfully');
    } catch (error) {
      print('❌ Pet profile creation failed: $error');
      throw Exception('펫 프로필 저장에 실패했습니다: $error');
    }
  }

  // Riverpod이 자동으로 dispose를 관리하므로 수동 dispose는 제거
}

/// 펫 등록 컨트롤러 프로바이더
final petRegistrationControllerProvider =
    StateNotifierProvider<PetRegistrationController, PetRegistrationFormData>(
      (ref) => PetRegistrationController(ref),
    );
