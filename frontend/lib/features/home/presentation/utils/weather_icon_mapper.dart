/// OpenWeatherMapの天気アイコンをMeteocons SVGにマッピング
///
/// UI層の責任として、天気データの表示形式を制御
class WeatherIconMapper {
  /// OpenWeatherMapアイコンコードをMeteocons SVGファイル名にマッピング
  ///
  /// [openWeatherIcon] OpenWeatherMapのアイコンコード（例: '01d', '10n'）
  /// 戻り値: Meteoconsファイル名（拡張子なし）
  static String getMeteoconIcon(String openWeatherIcon) {
    const iconMap = {
      // 晴れ (Clear sky)
      '01d': 'clear-day',
      '01n': 'clear-night',

      // 少し曇り (Few clouds: 11-25%)
      '02d': 'partly-cloudy-day',
      '02n': 'partly-cloudy-night',

      // 散らばった雲 (Scattered clouds: 25-50%)
      '03d': 'cloudy',
      '03n': 'cloudy',

      // 曇り (Broken clouds: 51-84%)
      '04d': 'overcast',
      '04n': 'overcast',

      // にわか雨 (Shower rain)
      '09d': 'drizzle',
      '09n': 'drizzle',

      // 雨 (Rain)
      '10d': 'rain',
      '10n': 'rain',

      // 雷雨 (Thunderstorm)
      '11d': 'thunderstorms',
      '11n': 'thunderstorms',

      // 雪 (Snow)
      '13d': 'snow',
      '13n': 'snow',

      // 霧・もや (Mist, Fog, Haze)
      '50d': 'fog',
      '50n': 'fog',
    };

    return iconMap[openWeatherIcon] ?? 'not-available';
  }

  /// 天気IDに基づいた詳細なアイコンマッピング
  ///
  /// [weatherId] OpenWeatherMapの天気ID (200-900)
  /// [iconCode] OpenWeatherMapのアイコンコード（昼夜判定用）
  /// 戻り値: Meteoconsファイル名（拡張子なし）
  static String getDetailedIcon(int weatherId, String iconCode) {
    final isDayTime = iconCode.endsWith('d');

    // 2xx: 雷雨
    if (weatherId >= 200 && weatherId < 300) {
      if (weatherId == 200 || weatherId == 201 || weatherId == 202) {
        return isDayTime
            ? 'thunderstorms-day-rain'
            : 'thunderstorms-night-rain';
      }
      return isDayTime ? 'thunderstorms-day' : 'thunderstorms-night';
    }

    // 3xx: 霧雨
    if (weatherId >= 300 && weatherId < 400) {
      return isDayTime
          ? 'partly-cloudy-day-drizzle'
          : 'partly-cloudy-night-drizzle';
    }

    // 5xx: 雨
    if (weatherId >= 500 && weatherId < 600) {
      if (weatherId == 500 || weatherId == 501) {
        return isDayTime ? 'partly-cloudy-day-rain' : 'partly-cloudy-night-rain';
      }
      return 'rain';
    }

    // 6xx: 雪
    if (weatherId >= 600 && weatherId < 700) {
      if (weatherId == 600 || weatherId == 601) {
        return isDayTime ? 'partly-cloudy-day-snow' : 'partly-cloudy-night-snow';
      }
      if (weatherId == 611 || weatherId == 612 || weatherId == 613) {
        return 'sleet';
      }
      return 'snow';
    }

    // 7xx: 大気現象（霧、煙霧など）
    if (weatherId >= 700 && weatherId < 800) {
      if (weatherId == 701 || weatherId == 741) {
        return 'fog';
      }
      if (weatherId == 721) {
        return isDayTime ? 'haze-day' : 'haze-night';
      }
      if (weatherId == 731 || weatherId == 751 || weatherId == 761) {
        return isDayTime ? 'dust-day' : 'dust-night';
      }
      return 'fog';
    }

    // 800: 晴れ
    if (weatherId == 800) {
      return isDayTime ? 'clear-day' : 'clear-night';
    }

    // 80x: 雲
    if (weatherId > 800 && weatherId < 900) {
      if (weatherId == 801) {
        return isDayTime ? 'partly-cloudy-day' : 'partly-cloudy-night';
      }
      if (weatherId == 802) {
        return 'cloudy';
      }
      return 'overcast';
    }

    // デフォルト（基本マッピングを使用）
    return getMeteoconIcon(iconCode);
  }

  /// 天気IDから日本語の天気説明を取得
  ///
  /// [weatherId] OpenWeatherMapの天気ID
  /// 戻り値: 日本語の天気説明
  static String getWeatherDescription(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) return '雷雨';
    if (weatherId >= 300 && weatherId < 400) return '霧雨';
    if (weatherId >= 500 && weatherId < 600) return '雨';
    if (weatherId >= 600 && weatherId < 700) return '雪';
    if (weatherId >= 700 && weatherId < 800) return '霧';
    if (weatherId == 800) return '晴れ';
    if (weatherId > 800 && weatherId < 900) return '曇り';
    return '不明';
  }

  /// 天気アイコンの色を取得（UI表示用）
  ///
  /// [weatherId] OpenWeatherMapの天気ID
  /// 戻り値: 色のヒント（'sunny', 'cloudy', 'rainy', 'stormy'）
  static String getWeatherColorHint(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) return 'stormy'; // 雷雨
    if (weatherId >= 300 && weatherId < 600) return 'rainy'; // 霧雨・雨
    if (weatherId >= 600 && weatherId < 700) return 'snowy'; // 雪
    if (weatherId >= 700 && weatherId < 800) return 'foggy'; // 霧
    if (weatherId == 800) return 'sunny'; // 晴れ
    if (weatherId > 800 && weatherId < 900) return 'cloudy'; // 曇り
    return 'default';
  }
}
