import 'package:flutter/material.dart';

import '../../../features/pet_registor/domain/entities/pet_profile_entity.dart';
import '../../base/mock_data_base.dart';
import '../../base/mock_data_constants.dart';

/// 펫 관련 Mock 데이터 서비스
///
/// 펫 프로필, 등록, 기본 정보와 관련된 Mock 데이터를 제공합니다.
class PetMockData {
  /// 펫 목록 Mock 데이터
  static List<PetProfileEntity> getMockPets() {
    return [
      PetProfileEntity(
        id: '1',
        name: 'マックス',
        type: 'dog',
        breed: 'ゴールデンレトリバー',
        birthDate: DateTime(2020, 3, 15),
        imagePath: MockDataConstants.defaultPetImages['dog']!,
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PetProfileEntity(
        id: '2',
        name: 'ルナ',
        type: 'cat',
        breed: 'ペルシャ',
        birthDate: DateTime(2021, 7, 22),
        imagePath: MockDataConstants.defaultPetImages['cat']!,
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// 특정 펫 Mock 데이터
  static PetProfileEntity? getMockPetById(String id) {
    final pets = getMockPets();
    try {
      return pets.firstWhere((pet) => pet.id == id);
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
        'description': '充実스럽고 활발한 반려견',
        'color': MockDataConstants.primaryColor,
        'image': 'assets/images/pets/dog.png',
      },
      {
        'type': 'cat',
        'name': 'ねこ',
        'icon': 'pets',
        'description': '우아하고 독립적인 반려묘',
        'color': MockDataConstants.secondaryColor,
        'image': 'assets/images/pets/cat.png',
      },
      {
        'type': 'rabbit',
        'name': 'うさぎ',
        'icon': 'cruelty_free',
        'description': '귀엽고 온순한 반려토끼',
        'color': MockDataConstants.accentColor,
        'image': 'assets/images/pets/rabbit.png',
      },
      {
        'type': 'hamster',
        'name': 'ハムスター',
        'icon': 'circle',
        'description': '작고 사랑스러운 반려햄스터',
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
        'tips': '소량으로 나누어 주는 것이 좋습니다',
      },
      '中型': {
        'description': '中型犬・猫 (体重5-20kg)',
        'recommendedRange': '100-200g',
        'tips': '하루 2-3회로 나누어 주세요',
      },
      '大型': {
        'description': '大型犬 (体重20kg以上)',
        'recommendedRange': '200-400g',
        'tips': '운동량에 따라 조절이 필요합니다',
      },
    };
  }
}
