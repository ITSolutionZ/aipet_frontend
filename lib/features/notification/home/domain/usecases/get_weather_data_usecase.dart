import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 날씨 데이터 조회 UseCase
class GetWeatherDataUseCase {
  final HomeRepository repository;

  GetWeatherDataUseCase(this.repository);

  /// 현재 날씨 정보 조회
  ///
  /// [location] 위치 정보 (선택사항)
  /// [userTriggered] 사용자가 직접 요청했는지 여부
  Future<Result<WeatherEntity?>> call({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    try {
      final weather = await repository.getCurrentWeather(
        location: location,
        userTriggered: userTriggered,
      );
      return ResultFactory.success(weather, '天気情報を取得しました');
    } catch (error) {
      return ResultFactory.failure<WeatherEntity?>(
        '天気情報の取得に失敗しました: ${error.toString()}',
      );
    }
  }
}
