import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';

/// 제품 Mock 데이터
class ProductMockData {
  /// 모든 제품 목록
  static final List<ProductEntity> products = [
    // Royal Canin 제품
    const ProductEntity(
      id: 'rc-001',
      name: 'ロイヤルカナン ドッグフード 小型犬用 8kg',
      price: 9800,
      brandId: 'royal-canin',
      category: '사료',
    ),
    const ProductEntity(
      id: 'rc-002',
      name: 'ロイヤルカナン キャットフード 室内猫用 4kg',
      price: 6200,
      brandId: 'royal-canin',
      category: '사료',
    ),
    const ProductEntity(
      id: 'rc-003',
      name: 'ロイヤルカナン 消化器サポート 犬用 3kg',
      price: 7500,
      brandId: 'royal-canin',
      category: '사료',
    ),

    // Hill's 제품
    const ProductEntity(
      id: 'hills-001',
      name: 'ヒルズ サイエンスダイエット 成犬用 6.5kg',
      price: 8200,
      brandId: 'hills',
      category: '사료',
    ),
    const ProductEntity(
      id: 'hills-002',
      name: 'ヒルズ プリスクリプション 腎臓ケア 猫用 2kg',
      price: 5800,
      brandId: 'hills',
      category: '사료',
    ),

    // Purina 제품
    const ProductEntity(
      id: 'purina-001',
      name: 'ピュリナワン ドッグフード 成犬用 4.2kg',
      price: 4800,
      brandId: 'purina',
      category: '사료',
    ),
    const ProductEntity(
      id: 'purina-002',
      name: 'ピュリナワン キャット 避妊去勢猫用 2.2kg',
      price: 3200,
      brandId: 'purina',
      category: '사료',
    ),

    // Orijen 제품
    const ProductEntity(
      id: 'orijen-001',
      name: 'オリジン オリジナル ドッグフード 6kg',
      price: 12800,
      brandId: 'orijen',
      category: '사료',
    ),
    const ProductEntity(
      id: 'orijen-002',
      name: 'オリジン キャット&キティ 1.8kg',
      price: 6900,
      brandId: 'orijen',
      category: '사료',
    ),

    // Acana 제품
    const ProductEntity(
      id: 'acana-001',
      name: 'アカナ グラスフェッドラム 犬用 6kg',
      price: 10200,
      brandId: 'acana',
      category: '사료',
    ),
    const ProductEntity(
      id: 'acana-002',
      name: 'アカナ ワイルドプレイリー キャット 1.8kg',
      price: 5800,
      brandId: 'acana',
      category: '사료',
    ),

    // CIAO 제품 (간식)
    const ProductEntity(
      id: 'ciao-001',
      name: 'CIAO ちゅ〜る まぐろ味 14g×20本',
      price: 1200,
      brandId: 'ciao',
      category: '간식',
    ),
    const ProductEntity(
      id: 'ciao-002',
      name: 'CIAO 缶詰 ささみ 85g',
      price: 200,
      brandId: 'ciao',
      category: '간식',
    ),
    const ProductEntity(
      id: 'ciao-003',
      name: 'CIAO ちゅ〜る 水分補給 とりささみ 14g×20本',
      price: 1350,
      brandId: 'ciao',
      category: '간식',
    ),

    // 영양제
    const ProductEntity(
      id: 'royal-supp-001',
      name: 'ロイヤルカナン マルチビタミン サプリメント',
      price: 3800,
      brandId: 'royal-canin',
      category: '영양제',
    ),
    const ProductEntity(
      id: 'hills-supp-001',
      name: 'ヒルズ 関節サポート グルコサミン配合',
      price: 4200,
      brandId: 'hills',
      category: '영양제',
    ),
    const ProductEntity(
      id: 'purina-supp-001',
      name: 'ピュリナ オメガ3脂肪酸 サプリメント',
      price: 2900,
      brandId: 'purina',
      category: '영양제',
    ),

    // 생식
    const ProductEntity(
      id: 'orijen-raw-001',
      name: 'オリジン フリーズドライ 生食 チキン 340g',
      price: 5800,
      brandId: 'orijen',
      category: '생식',
    ),
    const ProductEntity(
      id: 'acana-raw-001',
      name: 'アカナ フリーズドライ 生食 ラム 200g',
      price: 4500,
      brandId: 'acana',
      category: '생식',
    ),
  ];

  /// 브랜드별 제품 필터링
  static List<ProductEntity> getProductsByBrand(String brandId) {
    return products.where((product) => product.brandId == brandId).toList();
  }

  /// 카테고리별 제품 필터링
  static List<ProductEntity> getProductsByCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }

  /// 제품 검색
  static List<ProductEntity> searchProducts(String query) {
    return products.where((product) {
      return product.name.contains(query);
    }).toList();
  }

  /// 가격 범위로 필터링
  static List<ProductEntity> getProductsByPriceRange({
    required int minPrice,
    required int maxPrice,
  }) {
    return products.where((product) {
      return product.price >= minPrice && product.price <= maxPrice;
    }).toList();
  }
}
