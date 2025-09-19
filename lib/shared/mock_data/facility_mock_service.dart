/// 시설 Mock 서비스
///
/// 시설 관련 Mock 데이터를 제공합니다.
class FacilityMockService {
  /// Mock 병원 데이터 반환
  static List<Map<String, dynamic>> getMockHospitals() {
    return [
      {
        'id': 'hospital-1',
        'name': 'ペットクリニック中央',
        'address': '東京都渋谷区道玄坂1-2-3',
        'phone': '03-1234-5678',
        'rating': 4.5,
        'distance': 1.2,
        'services': ['一般診療', '手術', '健康診断'],
        'hours': '9:00-18:00',
        'isOpen': true,
      },
      {
        'id': 'hospital-2',
        'name': '動物病院南',
        'address': '東京都新宿区歌舞伎町2-3-4',
        'phone': '03-2345-6789',
        'rating': 4.2,
        'distance': 2.1,
        'services': ['一般診療', '歯科', '皮膚科'],
        'hours': '8:00-19:00',
        'isOpen': true,
      },
    ];
  }

  /// Mock 미용실 데이터 반환
  static List<Map<String, dynamic>> getMockGroomingSalons() {
    return [
      {
        'id': 'grooming-1',
        'name': 'ペットサロン美',
        'address': '東京都港区六本木3-4-5',
        'phone': '03-3456-7890',
        'rating': 4.8,
        'distance': 0.8,
        'services': ['シャンプー', 'カット', '爪切り'],
        'hours': '10:00-19:00',
        'isOpen': true,
      },
    ];
  }

  /// Mock 예약 데이터 반환
  static List<Map<String, dynamic>> getMockBookings() {
    return [
      {
        'id': 'booking-1',
        'facilityId': 'hospital-1',
        'petId': 'pet-1',
        'serviceType': '健康診断',
        'appointmentTime': DateTime.now().add(const Duration(days: 7)),
        'status': 'confirmed',
        'notes': '定期健康診断',
      },
    ];
  }

  /// Mock 시설 데이터 반환 (통합)
  static List<Map<String, dynamic>> getMockFacilities() {
    return [
      // 병원 데이터
      {
        'id': 'hospital-1',
        'name': 'ペットクリニック中央',
        'description': '24時間対応の総合動物病院',
        'address': '東京都渋谷区道玄坂1-2-3',
        'phone': '03-1234-5678',
        'email': 'info@petclinic-central.com',
        'type': 'hospital',
        'rating': 4.5,
        'reviewCount': 128,
        'imagePath': 'assets/images/facilities/hospital1.jpg',
        'isFavorite': false,
        'hasHistory': true,
        'lastVisit': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'id': 'hospital-2',
        'name': '動物病院南',
        'description': '専門医による高度な医療サービス',
        'address': '東京都新宿区歌舞伎町2-3-4',
        'phone': '03-2345-6789',
        'email': 'contact@animal-hospital-south.com',
        'type': 'hospital',
        'rating': 4.2,
        'reviewCount': 95,
        'imagePath': 'assets/images/facilities/hospital2.jpg',
        'isFavorite': true,
        'hasHistory': false,
        'lastVisit': null,
      },
      // 트리밍샵 데이터
      {
        'id': 'grooming-1',
        'name': 'ペットサロン美',
        'description': 'プロのトリマーによる高品質なグルーミング',
        'address': '東京都港区六本木3-4-5',
        'phone': '03-3456-7890',
        'email': 'info@petsalon-bi.com',
        'type': 'grooming',
        'rating': 4.8,
        'reviewCount': 203,
        'imagePath': 'assets/images/facilities/grooming1.jpg',
        'isFavorite': true,
        'hasHistory': true,
        'lastVisit': DateTime.now().subtract(const Duration(days: 14)),
      },
      {
        'id': 'grooming-2',
        'name': 'フワフワサロン',
        'description': '小型犬専門のトリミングサロン',
        'address': '東京都世田谷区三軒茶屋4-5-6',
        'phone': '03-4567-8901',
        'email': 'hello@fuwafuwa-salon.com',
        'type': 'grooming',
        'rating': 4.6,
        'reviewCount': 156,
        'imagePath': 'assets/images/facilities/grooming2.jpg',
        'isFavorite': false,
        'hasHistory': false,
        'lastVisit': null,
      },
    ];
  }

  /// Mock 병원 시설 데이터 반환
  static List<Map<String, dynamic>> getMockHospitalFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'hospital')
        .toList();
  }

  /// Mock 트리밍 시설 데이터 반환
  static List<Map<String, dynamic>> getMockGroomingFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'grooming')
        .toList();
  }

  /// ID로 시설 상세 정보 반환
  static Map<String, dynamic>? getMockFacilityDetailById(String facilityId) {
    final facilities = getMockFacilities();
    try {
      return facilities.firstWhere((facility) => facility['id'] == facilityId);
    } catch (e) {
      return null;
    }
  }
}
