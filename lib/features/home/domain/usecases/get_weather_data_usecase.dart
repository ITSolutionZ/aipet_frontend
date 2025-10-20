import 'package:aipet_frontend/shared/shared.dart';

import '../entities/weather_entity.dart';
import '../repositories/home_repository.dart';

/// 날씨 데이터 조회 유스케이스
class GetWeatherDataUseCase {
  final HomeRepository _repository;

  GetWeatherDataUseCase(this._repository);

  /// 날씨 데이터 조회 실행
  Future<Result<WeatherEntity?>> call({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    try {
      final result = await _repository.getCurrentWeather(
        location: location,
        userTriggered: userTriggered,
      );
      return Result.success('天気データを取得しました', result);
    } catch (error) {
      return Result.failure('天気データの取得に失敗しました: ${error.toString()}');
    }
  }
}
