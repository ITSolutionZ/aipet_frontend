import '../entities/weather_entity.dart';
import '../repositories/home_repository.dart';

/// 날씨 데이터 조회 UseCase
class GetWeatherDataUseCase {
  final HomeRepository repository;

  GetWeatherDataUseCase(this.repository);

  /// 현재 날씨 정보 조회
  /// 
  /// [location] 위치 정보 (선택사항)
  /// [userTriggered] 사용자가 직접 요청했는지 여부
  Future<WeatherEntity?> call({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    return repository.getCurrentWeather(
      location: location,
      userTriggered: userTriggered,
    );
  }
}