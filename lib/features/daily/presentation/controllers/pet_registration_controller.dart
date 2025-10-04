import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String registrationNumber;
  final String? petImagePath;

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
    required this.registrationNumber,
    this.petImagePath,
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
    String? registrationNumber,
    String? petImagePath,
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
      registrationNumber: registrationNumber ?? this.registrationNumber,
      petImagePath: petImagePath ?? this.petImagePath,
    );
  }
}

/// 펫 등록 컨트롤러
class PetRegistrationController extends StateNotifier<PetRegistrationFormData> {
  PetRegistrationController() : super(_initialFormData);

  static const PetRegistrationFormData _initialFormData =
      PetRegistrationFormData(
        petName: '',
        petType: 'dog',
        breed: '',
        gender: '',
        isNeutered: false,
        guardianName: '',
        registrationNumber: '',
      );

  // Controllers
  final _petNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _adoptionDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // Getters for controllers
  TextEditingController get petNameController => _petNameController;
  TextEditingController get birthDateController => _birthDateController;
  TextEditingController get adoptionDateController => _adoptionDateController;
  TextEditingController get weightController => _weightController;
  TextEditingController get guardianNameController => _guardianNameController;
  TextEditingController get registrationNumberController =>
      _registrationNumberController;

  // Pet type and breed data with images
  static const List<Map<String, dynamic>> dogBreeds = [
    {'name': '시바견', 'image': 'assets/images/breeds/dogs/shiba.png'},
    {
      'name': '골든 리트리버',
      'image': 'assets/images/breeds/dogs/golden_retriever.png',
    },
    {'name': '래브라도', 'image': 'assets/images/breeds/dogs/labrador.png'},
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
    state = state.copyWith(petName: name);
  }

  void updateBirthDate(DateTime? date) {
    state = state.copyWith(birthDate: date);
    if (date != null) {
      _birthDateController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      _birthDateController.clear();
    }
  }

  void updateAdoptionDate(DateTime? date) {
    state = state.copyWith(adoptionDate: date);
    if (date != null) {
      _adoptionDateController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      _adoptionDateController.clear();
    }
  }

  void updateWeight(String weightText) {
    final weight = double.tryParse(weightText);
    state = state.copyWith(weight: weight);
  }

  void updatePetType(String petType) {
    state = state.copyWith(petType: petType, breed: '');
  }

  void updateBreed(String breed) {
    state = state.copyWith(breed: breed);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateNeuteringStatus(bool isNeutered) {
    state = state.copyWith(isNeutered: isNeutered);
  }

  void updateGuardianName(String name) {
    state = state.copyWith(guardianName: name);
  }

  void updateRegistrationNumber(String number) {
    state = state.copyWith(registrationNumber: number);
  }

  void updatePetImagePath(String? imagePath) {
    state = state.copyWith(petImagePath: imagePath);
  }

  // Validation methods
  String? validatePetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ペットの名前を入力してください';
    }
    if (value.length < 2 || value.length > 10) {
      return '2〜10文字で入力してください';
    }
    return null;
  }

  String? validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '生年月日を入力してください';
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'YYYY-MM-DD 형식으로 입력してください';
    }
    return null;
  }

  String? validateAdoptionDate(String? value) {
    // 집에 온 날은 선택사항이므로 빈 값이어도 됩니다
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'YYYY-MM-DD 형식으로 입력してください';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '体重を入力してください';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0 || weight > 100) {
      return '有効な体重を入力してください';
    }
    return null;
  }

  String? validateBreed() {
    if (state.breed.isEmpty) {
      return '品種を選択してください';
    }
    return null;
  }

  String? validateGender() {
    if (state.gender.isEmpty) {
      return '性別を選択してください';
    }
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
    if (!isFormValid()) {
      throw Exception('모든 필수 항목을 입력해주세요');
    }

    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock 데이터 처리
    debugPrint(
      'ペット登録完了: ${state.petName}, ${state.petType}, ${state.breed}, ${state.gender}, ${state.isNeutered}',
    );
  }

  // Riverpod이 자동으로 dispose를 관리하므로 수동 dispose는 제거
}

/// 펫 등록 컨트롤러 프로바이더
final petRegistrationControllerProvider =
    StateNotifierProvider<PetRegistrationController, PetRegistrationFormData>(
      (ref) => PetRegistrationController(),
    );
