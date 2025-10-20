import 'dart:async';

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/services/walk_tracking_optimizer.dart' hide LocationAccuracy;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Live Walk 위치 추적 관리자
class LiveWalkLocationTracker {
  StreamSubscription<Position>? _positionStream;
  Timer? _locationTimer;

  /// 위치 추적 시작
  void startTracking({
    required Function(WalkLocation) onLocationUpdate,
    required VoidCallback onError,
  }) {
    // 기존 추적 정지
    stopTracking();

    // 최적화된 위치 추적 설정 사용
    final config = WalkTrackingOptimizer.getAdaptiveTrackingConfig(
      batteryLevel: 1.0, // 배터리 레벨은 추후 실제 값으로 대체
      isCharging: false,
      walkDuration: Duration.zero,
      currentSpeed: 0.0,
    );

    // 적응형 위치 업데이트 간격 사용
    _locationTimer = Timer.periodic(config.updateInterval, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high, // 기본값 사용
            distanceFilter: config.distanceFilter,
          ),
        ).timeout(const Duration(seconds: 8));

        final location = WalkLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          heading: position.heading,
        );

        // 위치 데이터 유효성 검증
        if (WalkTrackingOptimizer.isValidLocation(location)) {
          onLocationUpdate(location);
        } else {
          debugPrint('🚶 유효하지 않은 위치 데이터 무시: 정확도 ${location.accuracy}m');
        }
      } catch (e) {
        debugPrint('위치 업데이트 실패: $e');
        onError();
      }
    });
  }

  /// 위치 추적 정지
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// 현재 위치 가져오기
  static Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('위치 권한 또는 GPS 오류: $e');
      return null;
    }
  }

  /// 기본 위치 생성
  static Position createDefaultPosition() {
    return Position(
      latitude: 35.6762, // 도쿄 기본 위치
      longitude: 139.6503,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  /// 정리
  void dispose() {
    stopTracking();
  }
}
