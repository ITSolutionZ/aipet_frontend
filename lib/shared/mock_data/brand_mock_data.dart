import 'package:aipet_frontend/features/allergy/domain/entities/brand_entity.dart';

/// 펫푸드 브랜드 Mock 데이터
/// API 샘플 구조 기반
class BrandMockData {
  /// 모든 브랜드 목록 (주요 브랜드 6개)
  static final List<BrandEntity> brands = [
    const BrandEntity(
      id: 'royal-canin',
      name: 'Royal Canin',
      japaneseName: 'ロイヤルカナン',
      category: ['dog', 'cat'],
      logoUrl: 'assets/images/brands/royal_canin.png',
      officialUrl: 'https://www.royalcanin.com/jp',
    ),
    const BrandEntity(
      id: 'hills',
      name: "Hill's",
      japaneseName: 'ヒルズ',
      category: ['dog', 'cat'],
      logoUrl: 'assets/images/brands/hills.png',
      officialUrl: 'https://www.hillspet.com',
    ),
    const BrandEntity(
      id: 'purina',
      name: 'Purina',
      japaneseName: 'ピュリナ',
      category: ['dog', 'cat'],
      logoUrl: 'assets/images/brands/purina.png',
      officialUrl: 'https://www.purina.jp',
    ),
    const BrandEntity(
      id: 'orijen',
      name: 'Orijen',
      japaneseName: 'オリジン',
      category: ['dog', 'cat'],
      logoUrl: 'assets/images/brands/orijen.png',
      officialUrl: 'https://www.orijenpetfoods.com',
    ),
    const BrandEntity(
      id: 'acana',
      name: 'Acana',
      japaneseName: 'アカナ',
      category: ['dog', 'cat'],
      logoUrl: 'assets/images/brands/acana.png',
      officialUrl: 'https://www.acana.com',
    ),
    const BrandEntity(
      id: 'ciao',
      name: 'CIAO',
      japaneseName: 'チャオ',
      category: ['cat'],
      logoUrl: 'assets/images/brands/ciao.png',
      officialUrl: 'https://www.inaba-petfood.jp',
    ),
  ];

  /// 회사명 매핑
  static const Map<String, String> companyNames = {
    'royal-canin': 'Royal Canin Japan',
    'hills': 'Hill\'s Pet Nutrition',
    'purina': 'Nestlé Purina PetCare',
    'orijen': 'Champion Petfoods',
    'acana': 'Champion Petfoods',
    'ciao': 'いなば食品',
  };

  /// 카테고리별 브랜드 필터링
  static List<BrandEntity> getBrandsByCategory(String category) {
    return brands.where((brand) => brand.category.contains(category)).toList();
  }

  /// 인기 브랜드
  static List<BrandEntity> getPopularBrands({int limit = 6}) {
    return brands.take(limit).toList();
  }

  /// 브랜드 검색
  static List<BrandEntity> searchBrands(String query) {
    final lowerQuery = query.toLowerCase();
    return brands.where((brand) {
      return brand.name.toLowerCase().contains(lowerQuery) ||
          brand.japaneseName.contains(query);
    }).toList();
  }
}
