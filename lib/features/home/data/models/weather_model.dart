class WeatherData {
  final double temperature;
  final String location;
  final int weatherId;
  final String description;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final double uvIndex;
  final int visibility;
  final double pressure;

  const WeatherData({
    required this.temperature,
    required this.location,
    required this.weatherId,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
  });

  factory WeatherData.fromOneCallJson(Map<String, dynamic> json, String location) {
    final current = json['current'] as Map<String, dynamic>;
    final weather = (current['weather'] as List).first as Map<String, dynamic>;

    return WeatherData(
      temperature: (current['temp'] as num).toDouble(),
      location: location,
      weatherId: weather['id'] as int,
      description: weather['description'] as String,
      feelsLike: (current['feels_like'] as num).toDouble(),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_speed'] as num?)?.toDouble() ?? 0.0,
      iconCode: weather['icon'] as String,
      uvIndex: (current['uvi'] as num?)?.toDouble() ?? 0.0,
      visibility: current['visibility'] as int? ?? 10000,
      pressure: (current['pressure'] as num?)?.toDouble() ?? 1013.25,
    );
  }

  // 기존 JSON 형식 지원 (폴백용)
  factory WeatherData.fromJson(Map<String, dynamic> json, String location) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      location: location,
      weatherId: weather['id'] as int,
      description: weather['description'] as String,
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      iconCode: weather['icon'] as String,
      uvIndex: 0.0, // 기본 날씨 API에서는 UV 지수 제공하지 않음
      visibility: json['visibility'] as int? ?? 10000,
      pressure: (main['pressure'] as num?)?.toDouble() ?? 1013.25,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'location': location,
        'weather_id': weatherId,
        'description': description,
        'feels_like': feelsLike,
        'humidity': humidity,
        'wind_speed': windSpeed,
        'icon_code': iconCode,
        'uv_index': uvIndex,
        'visibility': visibility,
        'pressure': pressure,
      };
}

class WeatherLocation {
  final double latitude;
  final double longitude;
  final String name;

  const WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}