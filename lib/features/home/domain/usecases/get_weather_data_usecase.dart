import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

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
