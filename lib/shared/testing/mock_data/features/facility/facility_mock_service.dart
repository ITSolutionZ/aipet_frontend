import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// Facility Feature 전용 Mock 데이터 서비스
class FacilityMockService extends BaseMockService {
  // ==================== 시설 데이터 ====================

  /// Mock 시설 목록
  static List<Map<String, dynamic>> getMockFacilities() {
    return [
      {
        'id': '1',
        'name': '우리동물병원',
        'type': 'hospital',
        'description': '반려동물을 위한 전문 동물병원입니다',
        'address': '서울시 강남구 테헤란로 123',
        'phone': '02-1234-5678',
        'email': 'contact@ourvet.com',
        'rating': 4.8,
        'reviewCount': 150,
        'distance': 1.2, // km
        'isOpen': true,
        'openHours': '09:00-18:00',
        'services': ['건강검진', '예방접종', '수술', '응급진료'],
        'imagePath': 'assets/images/facilities/hospital1.png',
        'imageUrl': 'assets/images/facilities/hospital1.png',
        'coordinates': {'lat': 37.5665, 'lng': 127.0780},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '2',
        'name': '펫샵 루나',
        'type': 'grooming',
        'description': '프리미엄 펫 미용 서비스를 제공합니다',
        'address': '서울시 강남구 논현로 456',
        'phone': '02-2345-6789',
        'email': 'luna@petshop.com',
        'rating': 4.5,
        'reviewCount': 95,
        'distance': 0.8,
        'isOpen': true,
        'openHours': '10:00-20:00',
        'services': ['털정리', '목욕', '네일케어', '스타일링'],
        'imagePath': 'assets/images/facilities/grooming1.png',
        'imageUrl': 'assets/images/facilities/grooming1.png',
        'coordinates': {'lat': 37.5633, 'lng': 127.0369},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '3',
        'name': '24시 응급동물병원',
        'type': 'hospital',
        'description': '24시간 응급 진료 가능한 동물병원',
        'address': '서울시 서초구 강남대로 789',
        'phone': '02-3456-7890',
        'email': 'emergency@24vet.com',
        'rating': 4.7,
        'reviewCount': 220,
        'distance': 2.1,
        'isOpen': true,
        'openHours': '24시간',
        'services': ['응급진료', '중환자실', '수술', '입원'],
        'imagePath': 'assets/images/facilities/hospital2.png',
        'imageUrl': 'assets/images/facilities/hospital2.png',
        'coordinates': {'lat': 37.4979, 'lng': 127.0276},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '4',
        'name': '프리미엄 펫살롱',
        'type': 'grooming',
        'description': '최고급 펫 미용 서비스',
        'address': '서울시 강남구 선릉로 321',
        'phone': '02-4567-8901',
        'email': 'premium@petsalon.com',
        'rating': 4.9,
        'reviewCount': 180,
        'distance': 1.5,
        'isOpen': false,
        'openHours': '09:00-19:00',
        'services': ['프리미엄 스파', '아로마테라피', '풀서비스'],
        'imagePath': 'assets/images/facilities/grooming2.png',
        'imageUrl': 'assets/images/facilities/grooming2.png',
        'coordinates': {'lat': 37.5045, 'lng': 127.0487},
        'isFavorite': false,
        'hasHistory': false,
      },
    ];
  }

  /// 병원 시설만 조회
  static List<Map<String, dynamic>> getMockHospitalFacilities() {
    return getMockFacilities().where((facility) => facility['type'] == 'hospital').toList();
  }

  /// 미용실 시설만 조회
  static List<Map<String, dynamic>> getMockGroomingFacilities() {
    return getMockFacilities().where((facility) => facility['type'] == 'grooming').toList();
  }

  /// ID로 시설 조회
  static Map<String, dynamic>? getMockFacilityById(String facilityId) {
    final facilities = getMockFacilities();
    try {
      return facilities.firstWhere((facility) => facility['id'] == facilityId);
    } catch (e) {
      return null;
    }
  }

  /// 시설 상세 정보 조회
  static Map<String, dynamic>? getMockFacilityDetailById(String facilityId) {
    final facility = getMockFacilityById(facilityId);
    if (facility == null) return null;

    // 상세 정보 추가
    return {
      ...facility,
      'description': '${facility['name']}는 반려동물을 위한 전문 서비스를 제공합니다.',
      'facilities': _getFacilityFeatures(facility['type']),
      'staff': _getStaffInfo(facility['type']),
      'reviews': _getReviewSummary(facility['id']),
      'pricing': _getPricingInfo(facility['type']),
      'gallery': _getGalleryImages(facility['id']),
    };
  }

  // ==================== 시설 상세 정보 헬퍼 메소드들 ====================

  static List<String> _getFacilityFeatures(String type) {
    switch (type) {
      case 'hospital':
        return ['최신 의료장비', '무균 수술실', '입원실', '주차 가능'];
      case 'grooming':
        return ['개별 케어룸', '고급 장비', '안전한 환경', '픽업 서비스'];
      default:
        return ['친절한 서비스', '깨끗한 환경'];
    }
  }

  static List<Map<String, dynamic>> _getStaffInfo(String type) {
    switch (type) {
      case 'hospital':
        return [
          {'name': '김수의사', 'position': '원장', 'experience': '15년'},
          {'name': '박간호사', 'position': '수의간호사', 'experience': '8년'},
        ];
      case 'grooming':
        return [
          {'name': '이미용사', 'position': '헤드 그루머', 'experience': '10년'},
          {'name': '최스타일리스트', 'position': '펫 스타일리스트', 'experience': '5년'},
        ];
      default:
        return [];
    }
  }

  static Map<String, dynamic> _getReviewSummary(String facilityId) {
    return {
      'totalReviews': 127,
      'averageRating': 4.6,
      'ratingDistribution': {'5': 89, '4': 25, '3': 10, '2': 2, '1': 1},
      'recentReviews': [
        {
          'author': '김**',
          'rating': 5,
          'comment': '정말 친절하고 전문적이에요!',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'author': '박**',
          'rating': 4,
          'comment': '시설이 깨끗하고 좋습니다.',
          'date': DateTime.now().subtract(const Duration(days: 5)),
        },
      ],
    };
  }

  static Map<String, dynamic> _getPricingInfo(String type) {
    switch (type) {
      case 'hospital':
        return {
          'consultation': '30,000원',
          'vaccination': '45,000원',
          'checkup': '80,000원',
          'emergency': '150,000원',
        };
      case 'grooming':
        return {
          'basic': '40,000원',
          'premium': '70,000원',
          'full_service': '120,000원',
          'nail_care': '15,000원',
        };
      default:
        return {};
    }
  }

  static List<String> _getGalleryImages(String facilityId) {
    return [
      'assets/images/facilities/gallery1.png',
      'assets/images/facilities/gallery2.png',
      'assets/images/facilities/gallery3.png',
    ];
  }
}
