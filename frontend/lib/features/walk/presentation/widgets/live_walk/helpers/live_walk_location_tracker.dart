import 'dart:async';

import 'package:aipet_frontend/features/walk/domain/services/walk_tracking_optimizer.dart'
    hide LocationAccuracy;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../../../../features/walk/domain/entities/walk_location_entity.dart';
import '../../../../../../shared/shared.dart';

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

    // 🚀 Geolocator의 위치 스트림 사용 (더 효율적)
    // Timer.periodic 대신 실제 GPS 신호를 활용하므로 불필요한 호출 감소
    // GPS 오차 범위를 고려하여 distanceFilter를 크게 설정
    try {
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 15, // 최소 15m 이동할 때만 이벤트 발생 (동일한 위치로 인한 깜빡임 방지)
              timeLimit: Duration(seconds: 30),
            ),
          ).listen(
            (Position position) {
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
                LoggerService.debug(
                  '📍 위치 업데이트 수신: (${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}) 정확도: ${location.accuracy?.toStringAsFixed(1)}m',
                );
                onLocationUpdate(location);
              } else {
                LoggerService.debug(
                  '🚶 유효하지 않은 위치 데이터 무시: 정확도 ${location.accuracy}m',
                );
              }
            },
            onError: (error) {
              LoggerService.debug('❌ 위치 추적 에러: $error');
              onError();
            },
            cancelOnError: false,
          );
    } catch (e) {
      LoggerService.debug('❌ 위치 스트림 시작 실패: $e');
      onError();
    }
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
      LoggerService.debug('위치 권한 또는 GPS 오류: $e');
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
