import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';

/// 날씨 데이터 조회 유스케이스
class GetWeatherDataUseCase {
  final HomeRepository _repository;

  GetWeatherDataUseCase(this._repository);

  /// 날씨 데이터 조회 실행
  Future<WeatherEntity?> call({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    return _repository.getCurrentWeather(
      location: location,
      userTriggered: userTriggered,
    );
  }
}
