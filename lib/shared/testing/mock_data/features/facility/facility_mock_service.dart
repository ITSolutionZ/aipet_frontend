import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// Facility Feature 전용 Mock 데이터 서비스
class FacilityMockService extends BaseMockService {
  // ==================== 시설 데이터 ====================

  /// Mock 시설 목록
  static List<Map<String, dynamic>> getMockFacilities() {
    return [
      // ========== 動物病院 (Animal Hospitals) ==========
      {
        'id': '1',
        'name': 'アニマルクリニック銀座',
        'type': 'hospital',
        'description': '東京都心にある総合動物病院。最新設備と経験豊富な獣医師が在籍。',
        'address': '東京都中央区銀座3-10-5',
        'phone': '03-1234-5678',
        'email': 'contact@ginza-animal.com',
        'rating': 4.8,
        'reviewCount': 248,
        'distance': 1.2,
        'isOpen': true,
        'openHours': '09:00-19:00',
        'services': ['健康診断', '予防接種', '手術', '歯科', '内科', '外科'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6762, 'lng': 139.7640},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '2',
        'name': '渋谷ペット総合病院',
        'type': 'hospital',
        'description': '救急対応可能な総合動物病院。夜間診療も実施。',
        'address': '東京都渋谷区渋谷2-16-8',
        'phone': '03-2345-6789',
        'email': 'info@shibuya-vet.jp',
        'rating': 4.6,
        'reviewCount': 156,
        'distance': 0.8,
        'isOpen': true,
        'openHours': '10:00-20:00',
        'services': ['救急診療', 'ICU', '手術', '入院', 'リハビリ'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6595, 'lng': 139.7004},
        'isFavorite': true,
        'hasHistory': true,
      },
      {
        'id': '3',
        'name': '品川動物メディカルセンター',
        'type': 'hospital',
        'description': '24時間対応の救急動物病院。高度医療にも対応。',
        'address': '東京都品川区北品川5-9-15',
        'phone': '03-3456-7890',
        'email': 'emergency@shinagawa-amc.jp',
        'rating': 4.8,
        'reviewCount': 487,
        'distance': 2.1,
        'isOpen': true,
        'openHours': '24時間',
        'services': ['24時間救急', 'CT/MRI', '専門外科', 'がん治療', '透析'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6284, 'lng': 139.7406},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== トリミングサロン (Grooming Salons) ==========
      {
        'id': '10',
        'name': 'ペットサロン ルナ',
        'type': 'grooming',
        'description': 'プレミアムペット美容サービス。経験豊富なトリマーが対応。',
        'address': '東京都港区六本木7-14-23',
        'phone': '03-5678-9012',
        'email': 'luna@pet-salon.jp',
        'rating': 4.7,
        'reviewCount': 195,
        'distance': 1.0,
        'isOpen': true,
        'openHours': '10:00-19:00',
        'services': ['トリミング', 'シャンプー', 'ネイルケア', 'エステ'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6627, 'lng': 139.7290},
        'isFavorite': true,
        'hasHistory': false,
      },
      {
        'id': '11',
        'name': 'プレミアムドッグサロン新宿',
        'type': 'grooming',
        'description': '小型犬専門の高級トリミングサロン。完全予約制。',
        'address': '東京都新宿区新宿3-25-12',
        'phone': '03-6789-0123',
        'email': 'shinjuku@premium-dog.jp',
        'rating': 4.9,
        'reviewCount': 324,
        'distance': 1.5,
        'isOpen': true,
        'openHours': '09:00-18:00',
        'services': ['プレミアムカット', 'スパ', 'アロマセラピー', 'マッサージ'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6897, 'lng': 139.7005},
        'isFavorite': false,
        'hasHistory': true,
      },
      {
        'id': '12',
        'name': 'キャットビューティー原宿',
        'type': 'grooming',
        'description': '猫専門のトリミングサロン。猫の扱いに慣れたスタッフ。',
        'address': '東京都渋谷区神宮前6-5-8',
        'phone': '03-7890-1234',
        'email': 'harajuku@cat-beauty.jp',
        'rating': 4.6,
        'reviewCount': 142,
        'distance': 0.9,
        'isOpen': true,
        'openHours': '10:00-18:00',
        'services': ['猫専用トリミング', '爪切り', 'グルーミング', 'ブラッシング'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6694, 'lng': 139.7106},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ペットショップ (Pet Shops) ==========
      {
        'id': '20',
        'name': 'ペットワールド東京',
        'type': 'petShop',
        'description': '大型ペットショップ。犬猫から小動物まで幅広く取り扱い。',
        'address': '東京都台東区上野3-27-1',
        'phone': '03-8901-2345',
        'email': 'tokyo@petworld.jp',
        'rating': 4.4,
        'reviewCount': 567,
        'distance': 2.3,
        'isOpen': true,
        'openHours': '10:00-20:00',
        'services': ['ペット販売', 'ペット用品', 'フード', 'トリミング', '相談窓口'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.7074, 'lng': 139.7745},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '21',
        'name': 'ハッピーペット青山',
        'type': 'petShop',
        'description': '高品質なペット用品とオーガニックフードの専門店。',
        'address': '東京都港区南青山5-6-24',
        'phone': '03-9012-3456',
        'email': 'aoyama@happy-pet.jp',
        'rating': 4.7,
        'reviewCount': 234,
        'distance': 1.4,
        'isOpen': true,
        'openHours': '11:00-20:00',
        'services': ['オーガニックフード', 'ペット用品', 'おもちゃ', 'アクセサリー'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6647, 'lng': 139.7184},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ドッグラン (Dog Runs) ==========
      {
        'id': '30',
        'name': '代々木公園ドッグラン',
        'type': 'dogRun',
        'description': '広々とした芝生のドッグラン。大型犬・小型犬エリア分離。',
        'address': '東京都渋谷区代々木神園町2-1',
        'phone': '03-0123-4567',
        'email': 'yoyogi@dogrun.tokyo',
        'rating': 4.5,
        'reviewCount': 412,
        'distance': 1.8,
        'isOpen': true,
        'openHours': '06:00-19:00',
        'services': ['大型犬エリア', '小型犬エリア', '水飲み場', '休憩所', '無料Wi-Fi'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6719, 'lng': 139.6961},
        'isFavorite': true,
        'hasHistory': true,
      },
      {
        'id': '31',
        'name': 'お台場ドッグパーク',
        'type': 'dogRun',
        'description': '海辺の景色を楽しめるドッグラン。アジリティ設備完備。',
        'address': '東京都港区台場1-7-1',
        'phone': '03-1234-5678',
        'email': 'odaiba@dogpark.jp',
        'rating': 4.6,
        'reviewCount': 298,
        'distance': 5.2,
        'isOpen': true,
        'openHours': '07:00-20:00',
        'services': ['アジリティ施設', 'シャワー', 'カフェ', 'ドッグプール'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6267, 'lng': 139.7759},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ペットカフェ (Pet Cafes) ==========
      {
        'id': '40',
        'name': 'わんにゃんカフェ表参道',
        'type': 'cafe',
        'description': 'ペット同伴可能なカフェ。犬猫用メニューも充実。',
        'address': '東京都渋谷区神宮前4-12-10',
        'phone': '03-2345-6789',
        'email': 'omotesando@wannyan-cafe.jp',
        'rating': 4.5,
        'reviewCount': 387,
        'distance': 1.1,
        'isOpen': true,
        'openHours': '10:00-21:00',
        'services': ['ペット同伴', '犬用メニュー', '猫用メニュー', 'テラス席', 'Wi-Fi'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6650, 'lng': 139.7106},
        'isFavorite': false,
        'hasHistory': true,
      },
      {
        'id': '41',
        'name': 'ドッグカフェ ワンダフル',
        'type': 'cafe',
        'description': '犬専用カフェ。室内ドッグランも併設。',
        'address': '東京都目黒区中目黒1-1-71',
        'phone': '03-3456-7890',
        'email': 'nakameguro@wonderful-dog.jp',
        'rating': 4.4,
        'reviewCount': 267,
        'distance': 2.4,
        'isOpen': true,
        'openHours': '11:00-20:00',
        'services': ['室内ドッグラン', 'ドッグメニュー', 'おやつ販売', 'イベント'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6447, 'lng': 139.6982},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ペットホテル (Pet Hotels) ==========
      {
        'id': '50',
        'name': 'ペットホテル パラダイス',
        'type': 'hotel',
        'description': '24時間スタッフ常駐のペットホテル。Webカメラで様子確認可能。',
        'address': '東京都世田谷区三軒茶屋2-13-7',
        'phone': '03-4567-8901',
        'email': 'sangenjaya@pet-paradise.jp',
        'rating': 4.7,
        'reviewCount': 456,
        'distance': 3.2,
        'isOpen': true,
        'openHours': '24時間',
        'services': ['個室完備', 'Webカメラ', '散歩サービス', '送迎', 'グルーミング'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6433, 'lng': 139.6686},
        'isFavorite': true,
        'hasHistory': false,
      },
      {
        'id': '51',
        'name': 'リゾートペットホテル東京',
        'type': 'hotel',
        'description': '高級リゾート型ペットホテル。スパやプールも完備。',
        'address': '東京都港区白金台5-19-1',
        'phone': '03-5678-9012',
        'email': 'shirokane@resort-pet.jp',
        'rating': 4.9,
        'reviewCount': 678,
        'distance': 2.7,
        'isOpen': true,
        'openHours': '09:00-21:00',
        'services': ['個室スイート', 'ペットスパ', 'プール', 'ドッグラン', 'トリミング'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6389, 'lng': 139.7197},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== 訓練所 (Training Centers) ==========
      {
        'id': '60',
        'name': 'ドッグトレーニングセンター東京',
        'type': 'training',
        'description': 'プロのトレーナーによる犬のしつけ教室。',
        'address': '東京都練馬区光が丘5-1-1',
        'phone': '03-6789-0123',
        'email': 'hikarigaoka@dog-training.jp',
        'rating': 4.8,
        'reviewCount': 289,
        'distance': 8.5,
        'isOpen': true,
        'openHours': '09:00-18:00',
        'services': ['パピークラス', '基本訓練', 'アジリティ', '問題行動改善', '個別レッスン'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.7607, 'lng': 139.6329},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '61',
        'name': 'ハッピードッグスクール',
        'type': 'training',
        'description': '楽しく学べるドッグスクール。社会化トレーニングに強み。',
        'address': '東京都杉並区高円寺南4-28-10',
        'phone': '03-7890-1234',
        'email': 'koenji@happy-dog.jp',
        'rating': 4.6,
        'reviewCount': 176,
        'distance': 6.3,
        'isOpen': true,
        'openHours': '10:00-19:00',
        'services': ['グループレッスン', '社会化訓練', '幼稚園', '預かり訓練'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.7040, 'lng': 139.6499},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ペット用品店 (Pet Stores) ==========
      {
        'id': '70',
        'name': 'ペット用品専門店 モフモフ',
        'type': 'petStore',
        'description': '厳選されたペット用品とオーガニックフードの専門店。',
        'address': '東京都中野区中野5-52-15',
        'phone': '03-8901-2345',
        'email': 'nakano@mofu-mofu.jp',
        'rating': 4.5,
        'reviewCount': 423,
        'distance': 4.7,
        'isOpen': true,
        'openHours': '10:00-20:00',
        'services': ['オーガニックフード', 'おもちゃ', 'ベッド', '服', 'サプリメント'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.7065, 'lng': 139.6655},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '71',
        'name': 'ペット グッズ パラダイス',
        'type': 'petStore',
        'description': '輸入ペット用品専門店。ヨーロッパブランド多数。',
        'address': '東京都豊島区東池袋1-11-1',
        'phone': '03-9012-3456',
        'email': 'ikebukuro@pet-paradise.jp',
        'rating': 4.6,
        'reviewCount': 345,
        'distance': 5.1,
        'isOpen': true,
        'openHours': '10:00-21:00',
        'services': ['輸入用品', 'デザイナーブランド', 'カスタムオーダー', 'ギフト'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.7295, 'lng': 139.7109},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ペット公園 (Pet Parks) ==========
      {
        'id': '80',
        'name': '駒沢オリンピック公園ドッグラン',
        'type': 'petPark',
        'description': '広大な敷地のドッグラン。オリンピック公園内。',
        'address': '東京都世田谷区駒沢公園1-1',
        'phone': '03-0123-4567',
        'email': 'komazawa@olympic-park.jp',
        'rating': 4.7,
        'reviewCount': 892,
        'distance': 4.5,
        'isOpen': true,
        'openHours': '06:00-20:00',
        'services': ['大型犬エリア', '小型犬エリア', '障害物コース', '水飲み場', '駐車場'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6309, 'lng': 139.6722},
        'isFavorite': true,
        'hasHistory': true,
      },
      {
        'id': '81',
        'name': '葛西臨海公園ペットエリア',
        'type': 'petPark',
        'description': '海辺のペット同伴可能エリア。散歩コースも充実。',
        'address': '東京都江戸川区臨海町6-2-1',
        'phone': '03-1234-5678',
        'email': 'kasai@rinkai-park.jp',
        'rating': 4.4,
        'reviewCount': 567,
        'distance': 12.3,
        'isOpen': true,
        'openHours': '24時間',
        'services': ['散歩コース', 'ピクニックエリア', 'ドッグラン', 'ビーチエリア'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.6431, 'lng': 139.8587},
        'isFavorite': false,
        'hasHistory': false,
      },

      // ========== ペット可宿泊施設 (Pet-Friendly Accommodations) ==========
      {
        'id': '90',
        'name': 'ペットと泊まれるホテル箱根',
        'type': 'petFriendlyAccommodation',
        'description': 'ペット専用客室完備のリゾートホテル。',
        'address': '神奈川県足柄下郡箱根町湯本707',
        'phone': '0460-85-5555',
        'email': 'hakone@pet-hotel.jp',
        'rating': 4.8,
        'reviewCount': 534,
        'distance': 85.4,
        'isOpen': true,
        'openHours': '24時間',
        'services': ['ペット専用客室', 'ドッグラン', 'ペット温泉', 'ペットメニュー', 'トリミング'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 35.2328, 'lng': 139.1077},
        'isFavorite': false,
        'hasHistory': false,
      },
      {
        'id': '91',
        'name': 'ドッグフレンドリー軽井沢',
        'type': 'petFriendlyAccommodation',
        'description': '自然豊かな軽井沢のペット同伴リゾート。',
        'address': '長野県北佐久郡軽井沢町軽井沢1274',
        'phone': '0267-42-1111',
        'email': 'karuizawa@dog-friendly.jp',
        'rating': 4.9,
        'reviewCount': 712,
        'distance': 145.2,
        'isOpen': true,
        'openHours': '24時間',
        'services': ['コテージ', 'ドッグラン', '森林散歩', 'BBQ', 'ペットシッター'],
        'imagePath': 'assets/images/placeholder.png',
        'imageUrl': 'assets/images/placeholder.png',
        'coordinates': {'lat': 36.3512, 'lng': 138.6273},
        'isFavorite': false,
        'hasHistory': false,
      },
    ];
  }

  /// 병원 시설만 조회
  static List<Map<String, dynamic>> getMockHospitalFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'hospital')
        .toList();
  }

  /// 미용실 시설만 조회
  static List<Map<String, dynamic>> getMockGroomingFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'grooming')
        .toList();
  }

  /// 펫샵 시설만 조회
  static List<Map<String, dynamic>> getMockPetShopFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'petShop')
        .toList();
  }

  /// 펫용품점 시설만 조회
  static List<Map<String, dynamic>> getMockPetStoreFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'petStore')
        .toList();
  }

  /// 도그런 시설만 조회
  static List<Map<String, dynamic>> getMockDogRunFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'dogRun')
        .toList();
  }

  /// 펫카페 시설만 조회
  static List<Map<String, dynamic>> getMockCafeFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'cafe')
        .toList();
  }

  /// 펫호텔 시설만 조회
  static List<Map<String, dynamic>> getMockHotelFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'hotel')
        .toList();
  }

  /// 훈련소 시설만 조회
  static List<Map<String, dynamic>> getMockTrainingFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'training')
        .toList();
  }

  /// 펫공원 시설만 조회
  static List<Map<String, dynamic>> getMockPetParkFacilities() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'petPark')
        .toList();
  }

  /// 펫동반 숙박시설만 조회
  static List<Map<String, dynamic>> getMockPetFriendlyAccommodations() {
    return getMockFacilities()
        .where((facility) => facility['type'] == 'petFriendlyAccommodation')
        .toList();
  }

  /// 즐겨찾기 시설만 조회
  static List<Map<String, dynamic>> getMockFavoriteFacilities() {
    return getMockFacilities()
        .where((facility) => facility['isFavorite'] == true)
        .toList();
  }

  /// 방문 기록이 있는 시설만 조회
  static List<Map<String, dynamic>> getMockHistoryFacilities() {
    return getMockFacilities()
        .where((facility) => facility['hasHistory'] == true)
        .toList();
  }

  /// 현재 운영 중인 시설만 조회
  static List<Map<String, dynamic>> getMockOpenFacilities() {
    return getMockFacilities()
        .where((facility) => facility['isOpen'] == true)
        .toList();
  }

  /// 평점순으로 정렬된 시설 조회 (높은 순)
  static List<Map<String, dynamic>> getMockFacilitiesByRating() {
    final facilities = getMockFacilities();
    facilities.sort(
      (a, b) => (b['rating'] as num).compareTo(a['rating'] as num),
    );
    return facilities;
  }

  /// 거리순으로 정렬된 시설 조회 (가까운 순)
  static List<Map<String, dynamic>> getMockFacilitiesByDistance() {
    final facilities = getMockFacilities();
    facilities.sort(
      (a, b) => (a['distance'] as num).compareTo(b['distance'] as num),
    );
    return facilities;
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
