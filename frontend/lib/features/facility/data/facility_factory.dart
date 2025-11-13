import '../domain/domain.dart';

/// 🎯 Facility Factory
///
/// 시설 객체 생성을 중앙화하여 일관성과 유지보수성을 향상시킵니다.
/// 모든 Facility 생성 로직을 통합 관리합니다.
class FacilityFactory {
  /// Map 데이터로부터 Facility 객체 생성
  static Facility fromMap(Map<String, dynamic> data) {
    return Facility(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      address: data['address'] as String,
      latitude: data['latitude'] as double? ?? 35.6762,
      longitude: data['longitude'] as double? ?? 139.6503,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      website: data['website'] as String?,
      imagePath: data['imagePath'] as String?,
      type: _parseFacilityType(data['type'] as String?),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      isFavorite: data['isFavorite'] as bool? ?? false,
      hasHistory: data['hasHistory'] as bool? ?? false,
      lastVisit: data['lastVisit'] as DateTime?,
      isOpen: data['isOpen'] as bool? ?? true,
      createdAt: data['createdAt'] as DateTime?,
      updatedAt: data['updatedAt'] as DateTime?,
    );
  }

  /// 시설 타입 문자열을 enum으로 변환
  static FacilityType _parseFacilityType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'hospital':
        return FacilityType.hospital;
      case 'grooming':
        return FacilityType.grooming;
      case 'petshop':
      case 'pet_shop':
        return FacilityType.petShop;
      case 'dogrun':
      case 'dog_run':
        return FacilityType.dogRun;
      case 'park':
        return FacilityType.park;
      case 'cafe':
        return FacilityType.cafe;
      case 'hotel':
        return FacilityType.hotel;
      case 'training':
        return FacilityType.training;
      default:
        return FacilityType.hospital; // 기본값
    }
  }

  /// 기본 시설 생성 (더미 데이터)
  static Facility createDefault(String id, {String? name, FacilityType? type}) {
    return Facility(
      id: id,
      name: name ?? 'デフォルト施設',
      description: 'デフォルトの施設説明',
      address: 'デフォルト住所',
      latitude: 35.6762,
      longitude: 139.6503,
      type: type ?? FacilityType.hospital,
      rating: 0.0,
      reviewCount: 0,
      isFavorite: false,
      hasHistory: false,
      isOpen: true,
    );
  }

  /// 시설 리스트 일괄 생성
  static List<Facility> fromMapList(List<Map<String, dynamic>> dataList) {
    return dataList.map((data) => fromMap(data)).toList();
  }

  /// 시설 검증
  static bool isValid(Facility facility) {
    return facility.id.isNotEmpty &&
        facility.name.isNotEmpty &&
        facility.address.isNotEmpty;
  }

  /// 시설 복사 (특정 필드만 업데이트)
  static Facility copyWith(
    Facility facility, {
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    bool? isFavorite,
    bool? hasHistory,
    DateTime? lastVisit,
  }) {
    return facility.copyWith(
      name: name,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
      isFavorite: isFavorite,
      hasHistory: hasHistory,
      lastVisit: lastVisit,
    );
  }
}
