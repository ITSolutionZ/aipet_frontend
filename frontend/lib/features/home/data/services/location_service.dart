import 'package:geolocator/geolocator.dart';

import '../../../../app/config/app_config.dart';
import '../../../../shared/shared.dart';
import '../constants/japanese_cities.dart';
import '../models/weather_model.dart';


/// 位置情報取得サービス
///
/// GPS、権限管理、逆ジオコーディングを担当
class LocationService extends BaseLoggingService {
  final OpenWeatherMapHttpClient _httpClient;

  LocationService({OpenWeatherMapHttpClient? httpClient})
      : _httpClient = httpClient ?? OpenWeatherMapHttpClient(),
        super('location_service');

  /// 現在位置を取得（GPS優先、失敗時はデフォルト位置）
  Future<WeatherLocation> getCurrentLocation() async {
    // テスト環境では即座にデフォルト位置を使用
    if (AppConfig.current.environment == 'test') {
      return _getDefaultLocation();
    }

    try {
      // 実際のGPS位置を最初に試行
      final realLocation = await _getRealLocation();
      if (realLocation != null) {
        return realLocation;
      }
    } catch (e) {
      logDebug('GPS取得失敗、デフォルト位置を使用: $e');
    }

    // GPS失敗時はデフォルト位置（東京品川区）を使用
    return _getDefaultLocation();
  }

  /// 実際のGPS位置を取得
  Future<WeatherLocation?> _getRealLocation() async {
    try {
      // 1. 位置サービスが有効か確認
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logDebug('位置サービスが無効です');
        return null;
      }

      // 2. 位置権限を確認および要求
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logDebug('位置権限が拒否されました');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logDebug('位置権限が永久に拒否されました');
        return null;
      }

      // 3. GPSで実際のユーザー位置を取得
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logDebug('GPS取得タイムアウト、デフォルト位置を使用');
          return Position(
            latitude: 35.6092,
            longitude: 139.7301,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        },
      );

      // 4. 逆ジオコーディングで位置名を取得
      final locationName = await getLocationName(
        position.latitude,
        position.longitude,
      );

      logDebug('GPS位置取得成功: $locationName');

      return WeatherLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: locationName,
      );
    } catch (e) {
      logError('GPS位置取得エラー: $e');
      return null;
    }
  }

  /// 位置名を取得（逆ジオコーディング）
  ///
  /// [lat] 緯度
  /// [lon] 経度
  /// 戻り値: 位置名（例: "東京付近"）
  Future<String> getLocationName(double lat, double lon) async {
    try {
      // OpenWeatherMap APIの逆ジオコーディングを使用
      final result = await _httpClient.reverseGeocode(
        latitude: lat,
        longitude: lon,
        lang: 'ja',
      );

      if (result.isSuccess && result.dataOrNull != null) {
        final locationName = result.dataOrNull!;
        logDebug('逆ジオコーディング成功: $locationName');
        return locationName;
      } else {
        logDebug('逆ジオコーディング失敗、座標から推定');
        return JapaneseCities.formatCoordinatesAsLocation(lat, lon);
      }
    } catch (e) {
      logDebug('逆ジオコーディングエラー: $e');
      return JapaneseCities.formatCoordinatesAsLocation(lat, lon);
    }
  }

  /// デフォルト位置を取得（東京都品川区）
  WeatherLocation _getDefaultLocation() {
    return const WeatherLocation(
      latitude: 35.6092,
      longitude: 139.7301,
      name: '東京都品川区',
    );
  }

  /// 位置サービスが有効か確認
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 位置権限を確認
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// 位置権限を要求
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
}
