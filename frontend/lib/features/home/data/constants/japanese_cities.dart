/// 日本全国の主要都市データ
///
/// GPS座標から最も近い都市を推定するためのデータベース
class JapaneseCities {
  /// 日本全国の89都市データ
  static const List<Map<String, dynamic>> all = [
    // 北海道
    {'name': '札幌', 'lat': 43.06, 'lon': 141.35, 'range': 0.6},
    {'name': '函館', 'lat': 41.77, 'lon': 140.73, 'range': 0.4},
    {'name': '旭川', 'lat': 43.77, 'lon': 142.37, 'range': 0.4},
    {'name': '釧路', 'lat': 42.98, 'lon': 144.38, 'range': 0.4},
    {'name': '帯広', 'lat': 42.92, 'lon': 143.20, 'range': 0.3},
    {'name': '小樽', 'lat': 43.19, 'lon': 141.00, 'range': 0.3},

    // 東北
    {'name': '青森', 'lat': 40.82, 'lon': 140.75, 'range': 0.4},
    {'name': '八戸', 'lat': 40.51, 'lon': 141.49, 'range': 0.3},
    {'name': '弘前', 'lat': 40.60, 'lon': 140.46, 'range': 0.3},
    {'name': '秋田', 'lat': 39.72, 'lon': 140.10, 'range': 0.4},
    {'name': '盛岡', 'lat': 39.70, 'lon': 141.15, 'range': 0.3},
    {'name': '山形', 'lat': 38.24, 'lon': 140.36, 'range': 0.3},
    {'name': '仙台', 'lat': 38.26, 'lon': 140.87, 'range': 0.5},
    {'name': '福島', 'lat': 37.75, 'lon': 140.47, 'range': 0.4},
    {'name': 'いわき', 'lat': 37.05, 'lon': 140.89, 'range': 0.3},
    {'name': '郡山', 'lat': 37.40, 'lon': 140.36, 'range': 0.3},

    // 関東
    {'name': '東京', 'lat': 35.68, 'lon': 139.76, 'range': 0.8},
    {'name': '横浜', 'lat': 35.44, 'lon': 139.64, 'range': 0.4},
    {'name': '川崎', 'lat': 35.53, 'lon': 139.70, 'range': 0.3},
    {'name': 'さいたま', 'lat': 35.86, 'lon': 139.65, 'range': 0.4},
    {'name': '千葉', 'lat': 35.61, 'lon': 140.12, 'range': 0.4},
    {'name': '水戸', 'lat': 36.34, 'lon': 140.47, 'range': 0.3},
    {'name': '宇都宮', 'lat': 36.56, 'lon': 139.88, 'range': 0.4},
    {'name': '前橋', 'lat': 36.39, 'lon': 139.06, 'range': 0.3},
    {'name': '高崎', 'lat': 36.32, 'lon': 139.00, 'range': 0.3},
    {'name': '日光', 'lat': 36.72, 'lon': 139.60, 'range': 0.2},
    {'name': '箱根', 'lat': 35.23, 'lon': 139.11, 'range': 0.2},
    {'name': '鎌倉', 'lat': 35.32, 'lon': 139.55, 'range': 0.2},

    // 中部
    {'name': '新潟', 'lat': 37.90, 'lon': 139.02, 'range': 0.4},
    {'name': '長岡', 'lat': 37.45, 'lon': 138.85, 'range': 0.3},
    {'name': '富山', 'lat': 36.70, 'lon': 137.21, 'range': 0.3},
    {'name': '金沢', 'lat': 36.56, 'lon': 136.66, 'range': 0.3},
    {'name': '福井', 'lat': 36.06, 'lon': 136.22, 'range': 0.3},
    {'name': '甲府', 'lat': 35.66, 'lon': 138.57, 'range': 0.3},
    {'name': '長野', 'lat': 36.65, 'lon': 138.18, 'range': 0.4},
    {'name': '軽井沢', 'lat': 36.35, 'lon': 138.60, 'range': 0.2},
    {'name': '松本', 'lat': 36.24, 'lon': 137.97, 'range': 0.3},
    {'name': '岐阜', 'lat': 35.42, 'lon': 136.76, 'range': 0.3},
    {'name': '静岡', 'lat': 34.98, 'lon': 138.38, 'range': 0.4},
    {'name': '浜松', 'lat': 34.71, 'lon': 137.73, 'range': 0.3},
    {'name': '沼津', 'lat': 35.10, 'lon': 138.86, 'range': 0.2},
    {'name': '熱海', 'lat': 35.10, 'lon': 139.07, 'range': 0.2},
    {'name': '名古屋', 'lat': 35.18, 'lon': 136.91, 'range': 0.5},
    {'name': '豊田', 'lat': 35.08, 'lon': 137.16, 'range': 0.3},
    {'name': '岡崎', 'lat': 34.95, 'lon': 137.17, 'range': 0.2},
    {'name': '津', 'lat': 34.73, 'lon': 136.51, 'range': 0.3},
    {'name': '四日市', 'lat': 34.97, 'lon': 136.62, 'range': 0.3},

    // 近畿
    {'name': '大津', 'lat': 35.00, 'lon': 135.87, 'range': 0.3},
    {'name': '京都', 'lat': 35.01, 'lon': 135.77, 'range': 0.4},
    {'name': '大阪', 'lat': 34.69, 'lon': 135.50, 'range': 0.6},
    {'name': '堺', 'lat': 34.57, 'lon': 135.48, 'range': 0.3},
    {'name': '神戸', 'lat': 34.69, 'lon': 135.20, 'range': 0.4},
    {'name': '姫路', 'lat': 34.82, 'lon': 134.69, 'range': 0.3},
    {'name': '明石', 'lat': 34.64, 'lon': 135.00, 'range': 0.2},
    {'name': '宝塚', 'lat': 34.80, 'lon': 135.36, 'range': 0.2},
    {'name': '奈良', 'lat': 34.68, 'lon': 135.83, 'range': 0.3},
    {'name': '和歌山', 'lat': 34.23, 'lon': 135.17, 'range': 0.3},
    {'name': '白浜', 'lat': 33.68, 'lon': 135.34, 'range': 0.2},

    // 中国
    {'name': '鳥取', 'lat': 35.50, 'lon': 134.23, 'range': 0.3},
    {'name': '米子', 'lat': 35.43, 'lon': 133.33, 'range': 0.2},
    {'name': '松江', 'lat': 35.47, 'lon': 133.05, 'range': 0.3},
    {'name': '出雲', 'lat': 35.37, 'lon': 132.76, 'range': 0.2},
    {'name': '岡山', 'lat': 34.66, 'lon': 133.92, 'range': 0.4},
    {'name': '倉敷', 'lat': 34.58, 'lon': 133.77, 'range': 0.3},
    {'name': '広島', 'lat': 34.40, 'lon': 132.45, 'range': 0.5},
    {'name': '呉', 'lat': 34.25, 'lon': 132.57, 'range': 0.2},
    {'name': '福山', 'lat': 34.49, 'lon': 133.36, 'range': 0.3},
    {'name': '山口', 'lat': 34.18, 'lon': 131.47, 'range': 0.3},
    {'name': '下関', 'lat': 33.96, 'lon': 130.94, 'range': 0.3},
    {'name': '宇部', 'lat': 33.95, 'lon': 131.25, 'range': 0.2},

    // 四国
    {'name': '徳島', 'lat': 34.07, 'lon': 134.56, 'range': 0.3},
    {'name': '高松', 'lat': 34.34, 'lon': 134.04, 'range': 0.3},
    {'name': '丸亀', 'lat': 34.29, 'lon': 133.80, 'range': 0.2},
    {'name': '松山', 'lat': 33.84, 'lon': 132.77, 'range': 0.4},
    {'name': '今治', 'lat': 34.07, 'lon': 133.00, 'range': 0.2},
    {'name': '高知', 'lat': 33.56, 'lon': 133.53, 'range': 0.4},

    // 九州・沖縄
    {'name': '福岡', 'lat': 33.59, 'lon': 130.40, 'range': 0.5},
    {'name': '北九州', 'lat': 33.88, 'lon': 130.88, 'range': 0.4},
    {'name': '久留米', 'lat': 33.32, 'lon': 130.51, 'range': 0.2},
    {'name': '佐賀', 'lat': 33.25, 'lon': 130.30, 'range': 0.3},
    {'name': '長崎', 'lat': 32.75, 'lon': 129.88, 'range': 0.3},
    {'name': '佐世保', 'lat': 33.18, 'lon': 129.72, 'range': 0.3},
    {'name': '熊本', 'lat': 32.80, 'lon': 130.71, 'range': 0.4},
    {'name': '大分', 'lat': 33.24, 'lon': 131.61, 'range': 0.3},
    {'name': '別府', 'lat': 33.28, 'lon': 131.49, 'range': 0.2},
    {'name': '宮崎', 'lat': 31.91, 'lon': 131.42, 'range': 0.3},
    {'name': '鹿児島', 'lat': 31.60, 'lon': 130.56, 'range': 0.4},
    {'name': '那覇', 'lat': 26.21, 'lon': 127.68, 'range': 0.4},
    {'name': '石垣', 'lat': 24.34, 'lon': 124.16, 'range': 0.3},
    {'name': '宮古島', 'lat': 24.80, 'lon': 125.28, 'range': 0.3},
  ];

  /// 座標から最も近い都市を推定
  ///
  /// [lat] 緯度
  /// [lon] 経度
  /// 戻り値: 都市名 + "付近" (例: "東京付近")、見つからない場合はnull
  static String? findCityByCoordinates(double lat, double lon) {
    for (final city in all) {
      final cityLat = city['lat'] as double;
      final cityLon = city['lon'] as double;
      final range = city['range'] as double;

      // 距離計算（簡単なユークリッド距離）
      final distance = ((lat - cityLat).abs() + (lon - cityLon).abs()) / 2;

      if (distance < range) {
        return '${city['name']}付近';
      }
    }

    return null; // 既知の都市ではない
  }

  /// 座標を読みやすい位置名にフォーマット
  ///
  /// [lat] 緯度
  /// [lon] 経度
  /// 戻り値: 位置名 (例: "35.68°N 139.76°E")
  static String formatCoordinatesAsLocation(double lat, double lon) {
    // まず都市推定を試みる
    final estimatedCity = findCityByCoordinates(lat, lon);
    if (estimatedCity != null) {
      return estimatedCity;
    }

    // 座標ベースの表示 (fallback)
    final latStr = lat.abs().toStringAsFixed(2);
    final lonStr = lon.abs().toStringAsFixed(2);
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';

    return '$latStr°$latDir $lonStr°$lonDir';
  }

  /// 地域別の都市数
  static Map<String, int> get cityCounts => {
        '北海道': 6,
        '東北': 10,
        '関東': 13,
        '中部': 20,
        '近畿': 11,
        '中国': 12,
        '四国': 6,
        '九州・沖縄': 11,
      };

  /// 全都市数
  static int get totalCities => all.length;
}

