/// 🎯 날씨 아이콘 서비스
///
/// OpenWeatherMap API의 날씨 ID를 Meteocons 아이콘 이름으로 변환
class WeatherIconService {
  /// 날씨 ID 기반 아이콘 이름 가져오기
  static String getWeatherIconName(int weatherId, bool isDay) {
    // 날씨 ID 기반 아이콘 매핑 (OpenWeatherMap API 기준)
    if (weatherId >= 200 && weatherId < 300) {
      return _getThunderstormIcon(weatherId);
    } else if (weatherId >= 300 && weatherId < 400) {
      return _getDrizzleIcon(weatherId, isDay);
    } else if (weatherId >= 500 && weatherId < 600) {
      return _getRainIcon(weatherId, isDay);
    } else if (weatherId >= 600 && weatherId < 700) {
      return _getSnowIcon(weatherId, isDay);
    } else if (weatherId >= 700 && weatherId < 800) {
      return _getAtmosphereIcon(weatherId);
    } else if (weatherId == 800) {
      return isDay ? 'clear-day' : 'clear-night';
    } else if (weatherId >= 801 && weatherId < 900) {
      return _getCloudIcon(weatherId, isDay);
    } else {
      return _getExtremeIcon(weatherId);
    }
  }

  /// 뇌우 아이콘
  static String _getThunderstormIcon(int weatherId) {
    if (weatherId >= 200 && weatherId < 210) {
      return 'thunderstorms';
    } else if (weatherId >= 210 && weatherId < 220) {
      return 'thunderstorms-day';
    } else if (weatherId >= 220 && weatherId < 230) {
      return 'thunderstorms-night';
    } else if (weatherId >= 230 && weatherId < 240) {
      return 'thunderstorms-rain';
    } else if (weatherId >= 240 && weatherId < 250) {
      return 'thunderstorms-snow';
    } else {
      return 'thunderstorms';
    }
  }

  /// 가벼운 비 아이콘
  static String _getDrizzleIcon(int weatherId, bool isDay) {
    if (weatherId >= 300 && weatherId < 310) {
      return 'drizzle';
    } else if (weatherId >= 310 && weatherId < 320) {
      return isDay ? 'partly-cloudy-day-drizzle' : 'partly-cloudy-night-drizzle';
    } else if (weatherId >= 320 && weatherId < 330) {
      return isDay ? 'partly-cloudy-day-drizzle' : 'partly-cloudy-night-drizzle';
    } else {
      return 'drizzle';
    }
  }

  /// 비 아이콘
  static String _getRainIcon(int weatherId, bool isDay) {
    if (weatherId >= 500 && weatherId < 510) {
      return 'rain';
    } else if (weatherId >= 510 && weatherId < 520) {
      return isDay ? 'partly-cloudy-day-rain' : 'partly-cloudy-night-rain';
    } else if (weatherId >= 520 && weatherId < 530) {
      return isDay ? 'partly-cloudy-day-rain' : 'partly-cloudy-night-rain';
    } else if (weatherId >= 530 && weatherId < 540) {
      return 'rain';
    } else {
      return 'rain';
    }
  }

  /// 눈 아이콘
  static String _getSnowIcon(int weatherId, bool isDay) {
    if (weatherId >= 600 && weatherId < 610) {
      return 'snow';
    } else if (weatherId >= 610 && weatherId < 620) {
      return isDay ? 'partly-cloudy-day-snow' : 'partly-cloudy-night-snow';
    } else if (weatherId >= 620 && weatherId < 630) {
      return isDay ? 'partly-cloudy-day-snow' : 'partly-cloudy-night-snow';
    } else if (weatherId >= 630 && weatherId < 640) {
      return 'snow';
    } else if (weatherId >= 640 && weatherId < 650) {
      return 'sleet';
    } else {
      return 'snow';
    }
  }

  /// 대기 현상 아이콘
  static String _getAtmosphereIcon(int weatherId) {
    if (weatherId >= 700 && weatherId < 710) {
      return 'mist';
    } else if (weatherId >= 710 && weatherId < 720) {
      return 'smoke';
    } else if (weatherId >= 720 && weatherId < 730) {
      return 'haze';
    } else if (weatherId >= 730 && weatherId < 740) {
      return 'dust';
    } else if (weatherId >= 740 && weatherId < 750) {
      return 'fog';
    } else if (weatherId >= 750 && weatherId < 760) {
      return 'dust';
    } else if (weatherId >= 760 && weatherId < 770) {
      return 'dust';
    } else if (weatherId >= 770 && weatherId < 780) {
      return 'thunderstorms';
    } else if (weatherId >= 780 && weatherId < 790) {
      return 'tornado';
    } else {
      return 'fog';
    }
  }

  /// 구름 아이콘
  static String _getCloudIcon(int weatherId, bool isDay) {
    if (weatherId == 801) {
      return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
    } else if (weatherId == 802) {
      return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
    } else if (weatherId == 803) {
      return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
    } else if (weatherId == 804) {
      return 'overcast';
    } else {
      return 'cloudy';
    }
  }

  /// 극한 기상 아이콘
  static String _getExtremeIcon(int weatherId) {
    if (weatherId >= 900 && weatherId < 910) {
      return 'tornado';
    } else if (weatherId >= 910 && weatherId < 920) {
      return 'hurricane';
    } else if (weatherId >= 920 && weatherId < 1000) {
      return 'thunderstorms';
    } else {
      return 'not-available';
    }
  }
}
