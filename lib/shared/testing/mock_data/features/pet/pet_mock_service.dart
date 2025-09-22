import 'package:flutter/material.dart';

import '../../core/base_mock_service.dart';

/// Pet Feature 전용 Mock 데이터 서비스  
class PetMockService extends BaseMockService {
  
  // ==================== 기본 펫 데이터 ====================
  
  /// Mock 펫 프로필 목록
  static List<Map<String, dynamic>> getMockPets() {
    return [
      {
        'id': '1',
        'name': 'MAX',
        'typeName': 'dog',
        'breed': 'Golden Retriever',
        'age': 3,
        'birthDate': DateTime(2021, 5, 15).toIso8601String(),
        'createdAt': DateTime(2023, 1, 10).toIso8601String(),
        'gender': 'male',
        'weight': 15.8,
        'additionalInfo': {
          'personality': ['friendly', 'energetic'],
          'specialNotes': 'Loves playing fetch',
        }
      },
      {
        'id': '2', 
        'name': 'LUNA',
        'typeName': 'dog',
        'breed': 'Pomeranian',
        'age': 2,
        'birthDate': DateTime(2022, 8, 20).toIso8601String(),
        'createdAt': DateTime(2023, 3, 5).toIso8601String(),
        'gender': 'female',
        'weight': 3.5,
        'additionalInfo': {
          'personality': ['gentle', 'quiet'],
          'specialNotes': 'Prefers indoor activities',
        }
      },
      {
        'id': '3',
        'name': 'MOMO',
        'typeName': 'cat', 
        'breed': 'Scottish Fold',
        'age': 4,
        'birthDate': DateTime(2020, 11, 3).toIso8601String(),
        'createdAt': DateTime(2023, 2, 20).toIso8601String(),
        'gender': 'female',
        'weight': 4.2,
        'additionalInfo': {
          'personality': ['independent', 'calm'],
          'specialNotes': 'Loves sunny spots',
        }
      },
    ];
  }
  
  /// 펫 이름으로 성별 조회
  static String getPetGenderByName(String petName) {
    final pets = getMockPets();
    final pet = pets.firstWhere(
      (p) => p['name'].toString().toLowerCase() == petName.toLowerCase(),
      orElse: () => {'gender': 'unknown'},
    );
    return pet['gender'] ?? 'unknown';
  }
  
  /// 펫 ID로 상세 정보 조회
  static Map<String, dynamic>? getPetById(String petId) {
    final pets = getMockPets();
    try {
      return pets.firstWhere((pet) => pet['id'] == petId);
    } catch (e) {
      return null;
    }
  }
  
  // ==================== 건강 관리 데이터 ====================
  
  /// 펫 건강 요약 정보
  static Map<String, dynamic> getMockHealthSummary() {
    return {
      'totalPets': 3,
      'healthyPets': 2,
      'petsNeedingAttention': 1,
      'alerts': [
        {
          'petName': 'MAX',
          'message': '예방접종 일정이 다가왔습니다',
          'severity': 'medium',
          'dueDate': DateTime.now().add(const Duration(days: 7)),
        }
      ],
      'lastUpdated': DateTime.now(),
    };
  }
  
  // ==================== 일정 관리 데이터 ====================
  
  /// Mock 예약 목록
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
      final appointmentDate = DateTime.parse(appointment['scheduledTime'].toIso8601String());
      final isToday = appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;
      
      if (petId != null) {
        return isToday && appointment['petId'] == petId;
      }
      
      return isToday;
    }).toList();
  }
  
  // ==================== 품종 및 타입 데이터 ====================
  
  /// 지원되는 펫 타입 목록
  static List<String> getSupportedPetTypes() {
    return ['dog', 'cat', 'rabbit', 'hamster', 'bird'];
  }
  
  /// 강아지 품종 목록
  static List<String> getDogBreeds() {
    return [
      'Golden Retriever',
      'Pomeranian', 
      'Shiba Inu',
      'Border Collie',
      'French Bulldog',
      'Chihuahua',
      'German Shepherd',
      'Labrador Retriever',
    ];
  }
  
  /// 고양이 품종 목록
  static List<String> getCatBreeds() {
    return [
      'Scottish Fold',
      'Persian',
      'Maine Coon',
      'British Shorthair',
      'Russian Blue',
      'Siamese',
      'Ragdoll',
      'American Shorthair',
    ];
  }
  
  // ==================== 펫 상태 데이터 ====================
  
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
  
  // ==================== 펫 등록 데이터 ====================
  
  /// 펫 타입 목록
  static List<Map<String, dynamic>> getMockPetTypes() {
    return [
      {
        'id': 'dog',
        'name': '강아지',
        'icon': '🐕',
        'description': '충실하고 활발한 반려동물',
      },
      {
        'id': 'cat', 
        'name': '고양이',
        'icon': '🐱',
        'description': '독립적이고 우아한 반려동물',
      },
      {
        'id': 'rabbit',
        'name': '토끼',
        'icon': '🐰',
        'description': '온순하고 깨끗한 반려동물',
      },
      {
        'id': 'hamster',
        'name': '햄스터', 
        'icon': '🐹',
        'description': '작고 귀여운 반려동물',
      },
      {
        'id': 'bird',
        'name': '새',
        'icon': '🐦',
        'description': '지능적이고 사교적인 반려동물',
      },
    ];
  }
  
  /// 강아지 품종 목록 (상세)
  static List<Map<String, dynamic>> getMockDogBreeds() {
    return [
      {
        'id': 'golden_retriever',
        'name': 'Golden Retriever',
        'koreanName': '골든 리트리버',
        'size': 'large',
        'temperament': ['친화적', '지능적', '충실'],
        'lifespan': '10-12년',
      },
      {
        'id': 'pomeranian',
        'name': 'Pomeranian', 
        'koreanName': '포메라니안',
        'size': 'small',
        'temperament': ['활발', '호기심', '용감'],
        'lifespan': '12-16년',
      },
      {
        'id': 'shiba_inu',
        'name': 'Shiba Inu',
        'koreanName': '시바견',
        'size': 'medium', 
        'temperament': ['독립적', '영리', '충실'],
        'lifespan': '13-16년',
      },
      {
        'id': 'french_bulldog',
        'name': 'French Bulldog',
        'koreanName': '프렌치 불독',
        'size': 'small',
        'temperament': ['적응력', '장난기', '사교적'],
        'lifespan': '10-12년',
      },
    ];
  }
  
  /// 펫 프로필 목록 (상세)
  static List<Map<String, dynamic>> getMockPetProfiles() {
    return getMockPets().map((pet) => {
      ...pet,
      'profileImageUrl': pet['imagePath'],
      'description': '사랑스러운 반려동물',
      'characteristics': ['친화적', '활발', '건강함'],
    }).toList();
  }
  
  // ==================== 펫 상태 관리 ====================
  
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
    // REMOVED_SECURITY_RISK: print('Pet $petId status updated: $selectedStatuses, $statusValues');
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
      },
      'registeredAt': DateTime.now(),
      'linkExpiry': DateTime.now().add(const Duration(days: 30)),
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
    return getPetById(petId);
  }
}