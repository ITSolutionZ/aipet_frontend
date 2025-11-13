import '../../domain/domain.dart';
import '../models/weather_model.dart';

/// WeatherData를 WeatherEntity로 변환하는 매퍼
class WeatherMapper {
  /// Data layer의 WeatherData를 Domain layer의 WeatherEntity로 변환
  static WeatherEntity toEntity(WeatherData data) {
    return WeatherEntity(
      temperature: data.temperature,
      location: data.location,
      weatherId: data.weatherId,
      description: data.description,
      feelsLike: data.feelsLike,
      humidity: data.humidity,
      windSpeed: data.windSpeed,
      iconCode: data.iconCode,
      uvIndex: data.uvIndex,
      visibility: data.visibility,
      pressure: data.pressure,
    );
  }

  /// Domain layer의 WeatherLocationEntity를 Data layer의 WeatherLocation으로 변환
  static WeatherLocation toDataLocation(WeatherLocationEntity entity) {
    return WeatherLocation(
      latitude: entity.latitude,
      longitude: entity.longitude,
      name: entity.name,
    );
  }

  /// Data layer의 WeatherLocation을 Domain layer의 WeatherLocationEntity로 변환
  static WeatherLocationEntity toLocationEntity(WeatherLocation data) {
    return WeatherLocationEntity(
      latitude: data.latitude,
      longitude: data.longitude,
      name: data.name,
    );
  }
}
