import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../features/pet_registor/domain/entities/pet_profile_entity.dart';
import '../../../utils/mock_helper.dart';
import '../../base/mock_data_constants.dart';

/// 펫 관련 Mock 데이터 서비스
///
/// 펫 프로필, 등록, 기본 정보와 관련된 Mock 데이터를 제공합니다.
class PetMockData {
  /// 펫 목록 저장소 (메모리 내) - PetMockService와 통합된 데이터
  static final List<PetProfileEntity> _pets = [
    PetProfileEntity(
      id: '1',
      name: 'MAX',
      type: 'dog',
      breed: 'Golden Retriever',
      birthDate: DateTime(2021, 5, 15),
      imagePath: MockDataConstants.defaultPetImages['dog']!,
      ownerId: 'mock-owner-1',
      createdAt: DateTime(2023, 1, 10),
      updatedAt: DateTime.now(),
      isActive: true,
      additionalInfo: {
        'gender': 'male',
        'weight': 15.8,
        'personality': ['friendly', 'energetic'],
        'specialNotes': 'Loves playing fetch',
        'size': 'large',
        'isNeutered': false,
        'petAnniversary': DateTime(2021, 5, 15),
        'petBirthday': DateTime(2021, 5, 15),
        'petArrivalDate': DateTime(2021, 5, 15),
        'petGender': 'male',
        'petImage': File('assets/images/pets/max.png'),
      },
    ),
    PetProfileEntity(
      id: '2',
      name: 'LUNA',
      type: 'dog',
      breed: 'Pomeranian',
      birthDate: DateTime(2022, 8, 20),
      imagePath: MockDataConstants.defaultPetImages['dog']!,
      ownerId: 'mock-owner-2',
      createdAt: DateTime(2023, 3, 5),
      updatedAt: DateTime.now(),
      isActive: true,
      additionalInfo: {
        'gender': 'female',
        'weight': 3.5,
        'personality': ['gentle', 'quiet'],
        'specialNotes': 'Prefers indoor activities',
        'size': 'small',
        'isNeutered': false,
        'petAnniversary': DateTime(2022, 8, 20),
        'petBirthday': DateTime(2022, 8, 20),
        'petArrivalDate': DateTime(2022, 8, 20),
        'petGender': 'female',
        'petImage': File('assets/images/pets/luna.png'),
      },
    ),
    PetProfileEntity(
      id: '3',
      name: 'MOMO',
      type: 'cat',
      breed: 'Scottish Fold',
      birthDate: DateTime(2020, 11, 3),
      imagePath: MockDataConstants.defaultPetImages['cat']!,
      ownerId: 'mock-owner-3',
      createdAt: DateTime(2023, 2, 20),
      updatedAt: DateTime.now(),
      isActive: true,
      additionalInfo: {
        'gender': 'female',
        'weight': 4.2,
        'personality': ['independent', 'calm'],
        'specialNotes': 'Loves sunny spots',
        'size': 'medium',
        'isNeutered': false,
        'petAnniversary': DateTime(2020, 11, 3),
        'petBirthday': DateTime(2020, 11, 3),
        'petArrivalDate': DateTime(2020, 11, 3),
        'petGender': 'female',
        'petImage': File('assets/images/pets/momo.png'),
      },
    ),
  ];

  /// 펫 목록 Mock 데이터
  static List<PetProfileEntity> getMockPets() {
    return List.from(_pets);
  }

  /// 새 펫 추가
  static PetProfileEntity addPet(PetProfileEntity pet) {
    _pets.add(pet);
    return pet;
  }

  /// 펫 업데이트
  static PetProfileEntity? updatePet(PetProfileEntity updatedPet) {
    final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
      return updatedPet;
    }
    return null;
  }

  /// 펫 삭제
  static bool deletePet(String id) {
    final index = _pets.indexWhere((pet) => pet.id == id);
    if (index != -1) {
      _pets.removeAt(index);
      return true;
    }
    return false;
  }

  /// 특정 펫 Mock 데이터
  static PetProfileEntity? getMockPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 강아지 품종 Mock 데이터
  static List<Map<String, dynamic>> getMockDogBreeds() {
    return [
      {
        'breed': 'poodle',
        'name': 'プードル',
        'image': 'assets/images/breeds/poodle.png',
      },
      {
        'breed': 'golden_retriever',
        'name': 'ゴールデンレトリーバー',
        'image': 'assets/images/breeds/golden_retriever.png',
      },
      {
        'breed': 'labrador',
        'name': 'ラブラドール',
        'image': 'assets/images/breeds/labrador.png',
      },
      {
        'breed': 'shiba_inu',
        'name': '柴犬',
        'image': 'assets/images/breeds/shiba_inu.png',
      },
      {
        'breed': 'bulldog',
        'name': 'ブルドッグ',
        'image': 'assets/images/breeds/bulldog.png',
      },
      {
        'breed': 'chihuahua',
        'name': 'チワワ',
        'image': 'assets/images/breeds/chihuahua.png',
      },
      {
        'breed': 'beagle',
        'name': 'ビーグル',
        'image': 'assets/images/breeds/beagle.png',
      },
      {
        'breed': 'german_shepherd',
        'name': 'ジャーマンシェパード',
        'image': 'assets/images/breeds/german_shepherd.png',
      },
      {
        'breed': 'yorkshire_terrier',
        'name': 'ヨークシャーテリア',
        'image': 'assets/images/breeds/yorkshire_terrier.png',
      },
      {
        'breed': 'dachshund',
        'name': 'ダックスフンド',
        'image': 'assets/images/breeds/dachshund.png',
      },
    ];
  }

  /// 고양이 품종 Mock 데이터
  static List<Map<String, dynamic>> getMockCatBreeds() {
    return [
      {
        'breed': 'persian',
        'name': 'ペルシャ',
        'image': 'assets/images/breeds/persian.png',
      },
      {
        'breed': 'maine_coon',
        'name': 'メインクーン',
        'image': 'assets/images/breeds/maine_coon.png',
      },
      {
        'breed': 'siamese',
        'name': 'シャム',
        'image': 'assets/images/breeds/siamese.png',
      },
      {
        'breed': 'ragdoll',
        'name': 'ラグドール',
        'image': 'assets/images/breeds/ragdoll.png',
      },
      {
        'breed': 'british_shorthair',
        'name': 'ブリティッシュショートヘア',
        'image': 'assets/images/breeds/british_shorthair.png',
      },
      {
        'breed': 'scottish_fold',
        'name': 'スコティッシュフォールド',
        'image': 'assets/images/breeds/scottish_fold.png',
      },
    ];
  }

  /// 펫 타입 선택 Mock 데이터
  static List<Map<String, dynamic>> getMockPetTypes() {
    return [
      {
        'type': 'dog',
        'name': 'いぬ',
        'icon': 'pets',
        'description': '活発で元気なペット',
        'color': MockDataConstants.primaryColor,
        'image': 'assets/images/pets/dog.png',
      },
      {
        'type': 'cat',
        'name': 'ねこ',
        'icon': 'pets',
        'description': '優雅で独立したペット',
        'color': MockDataConstants.secondaryColor,
        'image': 'assets/images/pets/cat.png',
      },
      {
        'type': 'rabbit',
        'name': 'うさぎ',
        'icon': 'cruelty_free',
        'description': '可愛くて優しいペット',
        'color': MockDataConstants.accentColor,
        'image': 'assets/images/pets/rabbit.png',
      },
      {
        'type': 'hamster',
        'name': 'ハムスター',
        'icon': 'circle',
        'description': '小さくて可愛いペット',
        'color': const Color(0xFFD4A574),
        'image': 'assets/images/pets/hamster.png',
      },
    ];
  }

  /// 펫 성별 판단 (이름 기반)
  static String getPetGenderByName(String petName) {
    final maleNames = [
      'max',
      'buddy',
      'charlie',
      'rocky',
      'jack',
      'oscar',
      'leo',
      'milo',
    ];
    final femaleNames = [
      'luna',
      'bella',
      'molly',
      'lucy',
      'sophie',
      'chloe',
      'zoe',
      'ruby',
    ];

    final lowerName = petName.toLowerCase();

    if (maleNames.any((name) => lowerName.contains(name))) {
      return 'male';
    } else if (femaleNames.any((name) => lowerName.contains(name))) {
      return 'female';
    }

    return 'unknown';
  }

  /// 펫 사이즈별 적정 급여량 Mock 데이터
  static Map<String, Map<String, dynamic>> getMockPetSizesAndFeedingAmounts() {
    return {
      '1': {
        'name': 'マックス',
        'size': '中型',
        'recommendedAmount': 150,
        'imagePath': MockDataConstants.defaultPetImages['dog']!,
      },
      '2': {
        'name': 'ルナ',
        'size': '小型',
        'recommendedAmount': 80,
        'imagePath': MockDataConstants.defaultPetImages['cat']!,
      },
      '3': {
        'name': 'バディ',
        'size': '大型',
        'recommendedAmount': 250,
        'imagePath': MockDataConstants.defaultPetImages['golden']!,
      },
    };
  }

  /// 펫 사이즈별 급여 가이드 Mock 데이터
  static Map<String, Map<String, dynamic>> getPetSizeFeedingGuide() {
    return {
      '小型': {
        'description': '小型犬・猫 (体重5kg以下)',
        'recommendedRange': '60-100g',
        'tips': '少量でわけてあげるのがいいです',
      },
      '中型': {
        'description': '中型犬・猫 (体重5-20kg)',
        'recommendedRange': '100-200g',
        'tips': '1日2-3回に分けてあげましょう',
      },
      '大型': {
        'description': '大型犬 (体重20kg以上)',
        'recommendedRange': '200-400g',
        'tips': '運動量に応じて調整が必要です',
      },
    };
  }

  // ==================== 일정 관리 데이터 ====================

  /// Mock 예약 목록 - PetMockService와 통합
  static List<Map<String, dynamic>> getMockAppointments() {
    return [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'petName': 'MAX',
        'title': '건강검진',
        'type': '병원',
        'scheduledTime': DateTime.now().add(const Duration(days: 2, hours: 14)),
        'location': '우리동물병원',
        'notes': '연간 건강검진 예약',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'petName': 'LUNA',
        'title': '미용 예약',
        'type': '미용',
        'scheduledTime': DateTime.now().add(const Duration(days: 5, hours: 10)),
        'location': '펫샵 루나',
        'notes': '털 정리 및 목욕',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '3',
        'petName': 'MOMO',
        'title': '예방접종',
        'type': '병원',
        'scheduledTime': DateTime.now().add(const Duration(days: 7, hours: 16)),
        'location': '우리동물병원',
        'notes': '연간 종합백신 접종',
      },
    ];
  }

  /// 펫별 오늘 예약 조회
  static List<Map<String, dynamic>> getMockTodayAppointmentsByPet({String? petId}) {
    final allAppointments = getMockAppointments();
    final today = DateTime.now();

    return allAppointments.where((appointment) {
      final appointmentDate = appointment['scheduledTime'] as DateTime;
      final isToday = appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;

      if (petId != null) {
        return isToday && appointment['petId'] == petId;
      }
      return isToday;
    }).toList();
  }

  /// 펫 상태 옵션 목록
  static List<Map<String, dynamic>> getPetStatusOptions() {
    return [
      {
        'id': 'health',
        'title': '건강 상태',
        'description': '펫의 전반적인 건강 상태를 선택하세요',
        'icon': Icons.favorite,
        'options': ['매우 좋음', '좋음', '보통', '주의 필요', '병원 진료 필요'],
      },
      {
        'id': 'mood',
        'title': '기분 상태',
        'description': '펫의 현재 기분과 행동 상태를 선택하세요',
        'icon': Icons.mood,
        'options': ['매우 활발', '활발', '보통', '조용함', '우울함'],
      },
      {
        'id': 'appetite',
        'title': '식욕 상태',
        'description': '펫의 식사량과 식욕 상태를 선택하세요',
        'icon': Icons.restaurant,
        'options': ['매우 좋음', '좋음', '보통', '식욕 부진', '거부'],
      },
      {
        'id': 'activity',
        'title': '활동 상태',
        'description': '펫의 운동량과 활동 수준을 선택하세요',
        'icon': Icons.directions_walk,
        'options': ['매우 활발', '활발', '보통', '차분함', '비활성'],
      },
      {
        'id': 'sleep',
        'title': '수면 상태',
        'description': '펫의 수면 패턴과 질을 선택하세요',
        'icon': Icons.bedtime,
        'options': ['매우 좋음', '좋음', '보통', '불규칙', '수면 장애'],
      },
      {
        'id': 'social',
        'title': '사회성 상태',
        'description': '다른 동물이나 사람과의 교감 상태를 선택하세요',
        'icon': Icons.pets,
        'options': ['매우 친화적', '친화적', '보통', '소극적', '회피'],
      },
    ];
  }

  /// 펫의 현재 상태 조회
  static Map<String, dynamic> getPetCurrentStatus(String petId) {
    return {
      'petId': petId,
      'selectedStatuses': ['health', 'mood'],
      'statusValues': {
        'health': '좋음',
        'mood': '활발',
      },
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
    };
  }

  /// 펫 상태 업데이트
  static void updatePetStatus(String petId, List<String> selectedStatuses, Map<String, String> statusValues) {
    // Mock implementation - 실제로는 데이터베이스나 로컬 스토리지에 저장
    // 로그는 실제 구현에서 적절한 로깅 프레임워크를 사용하세요
  }

  // ==================== 링크 등록 관련 ====================

  /// 링크 등록 결과 Mock
  static Map<String, dynamic> getMockLinkRegistrationResult(String link) {
    return {
      'success': true,
      'petData': {
        'id': MockHelper.generateId(),
        'name': 'BUDDY',
        'type': 'dog',
        'breed': 'Golden Retriever',
        'age': 3,
        'weight': 25.5,
        'imageUrl': 'assets/images/dogs/golden.png',
        'owner': 'John Doe',
        'registrationDate': DateTime.now().toIso8601String(),
      },
      'message': '펫 정보가 성공적으로 등록되었습니다.',
    };
  }

  /// 링크 유효성 검사
  static bool isValidLink(String link) {
    // 간단한 유효성 검사 로직
    return link.isNotEmpty && link.contains('pet-link') && link.length > 10;
  }

  /// 예시 링크 목록
  static List<String> getMockExampleLinks() {
    return [
      'https://aipet.app/pet-link/abc123def456',
      'https://aipet.app/pet-link/xyz789ghi012',
      'https://aipet.app/pet-link/mno345pqr678',
    ];
  }

  /// 펫 ID로 검색
  static Map<String, dynamic>? findPetById(String petId) {
    final pet = getMockPetById(petId);
    if (pet == null) return null;

    // Convert PetProfileEntity to Map for compatibility
    return {
      'id': pet.id,
      'name': pet.name,
      'type': pet.type,
      'breed': pet.breed,
      'birthDate': pet.birthDate.toIso8601String(),
      'imagePath': pet.imagePath,
      'ownerId': pet.ownerId,
      'createdAt': pet.createdAt.toIso8601String(),
      'updatedAt': pet.updatedAt.toIso8601String(),
      'isActive': pet.isActive,
      'additionalInfo': pet.additionalInfo,
    };
  }
}
