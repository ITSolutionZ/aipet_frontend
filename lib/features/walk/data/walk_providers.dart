import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/walk_location_entity.dart';
import '../domain/entities/walk_record_entity.dart';
import '../domain/repositories/walk_repository.dart';
import '../domain/services/walk_tracking_optimizer.dart' as optimizer;
import 'repositories/walk_repository_impl.dart';
import 'repositories/walk_repository_mockito_impl.dart';

part 'walk_providers.g.dart';

/// WalkRepository 프로바이더 (Mockito 버전)
///
/// Google Maps API는 실제 사용하되, 나머지 로직은 Mockito를 통해 테스트 가능
@riverpod
WalkRepository walkRepository(WidgetRef ref) {
  return WalkRepositoryMockitoImpl();
}

/// Legacy WalkRepository 프로바이더 (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
@riverpod
WalkRepository legacyWalkRepository(WidgetRef ref) {
  return WalkRepositoryImpl();
}

// 산책 기록 목록 관리
@riverpod
class WalkRecordsNotifier extends _$WalkRecordsNotifier {
  @override
  List<WalkRecordEntity> build() => [];

  void setWalkRecords(List<WalkRecordEntity> records) {
    state = records;
  }

  void addWalkRecord(WalkRecordEntity record) {
    state = [record, ...state];
  }

  void updateWalkRecord(WalkRecordEntity record) {
    state = state.map((r) => r.id == record.id ? record : r).toList();
  }

  void removeWalkRecord(String recordId) {
    state = state.where((record) => record.id != recordId).toList();
  }

  List<WalkRecordEntity> getWalkRecordsByPet(String petId) {
    return state.where((record) => record.petId == petId).toList();
  }

  List<WalkRecordEntity> getRecentWalkRecords({int limit = 10}) {
    return state.take(limit).toList();
  }
}

// 현재 진행 중인 산책 관리
@riverpod
class CurrentWalkNotifier extends _$CurrentWalkNotifier {
  @override
  WalkRecordEntity? build() => null;

  void startWalk(WalkRecordEntity walk) {
    state = walk;
  }

  void updateCurrentWalk(WalkRecordEntity walk) {
    state = walk;
  }

  void endWalk() {
    state = null;
  }

  void pauseWalk() {
    if (state != null) {
      state = state!.copyWith(status: WalkStatus.paused);
    }
  }

  void resumeWalk() {
    if (state != null) {
      state = state!.copyWith(status: WalkStatus.inProgress);
    }
  }

  void addLocationToCurrentWalk(WalkLocation location) {
    if (state != null) {
      final updatedRoute = [...state!.route, location];
      state = state!.copyWith(route: updatedRoute);
    }
  }
}

// 선택된 반려동물 관리
@riverpod
class SelectedPetNotifier extends _$SelectedPetNotifier {
  @override
  PetInfo? build() => null;

  void setSelectedPet(PetInfo? pet) {
    state = pet;
  }
}

// 지도 확장 상태 관리
@riverpod
class MapExpandedNotifier extends _$MapExpandedNotifier {
  @override
  bool build() => false;

  void toggleExpanded() {
    state = !state;
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}

// 실시간 위치 추적 상태 관리
@riverpod
class LocationTrackingNotifier extends _$LocationTrackingNotifier {
  StreamSubscription<Position>? _positionSubscription;

  @override
  bool build() => false;

  /// 위치 추적 시작
  Future<void> startTracking() async {
    if (state) return; // 이미 추적 중이면 무시

    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      state = true;

      // 위치 스트림 시작
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // 5미터마다 업데이트
            ),
          ).listen((Position position) {
            // 현재 진행 중인 산책에 위치 추가
            final currentWalk = ref.read(currentWalkNotifierProvider);
            if (currentWalk != null &&
                currentWalk.status == WalkStatus.inProgress) {
              final location = WalkLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                timestamp: DateTime.now(),
                altitude: position.altitude,
                accuracy: position.accuracy,
                speed: position.speed,
                heading: position.heading,
              );

              // 성능 최적화: 유효하고 필요한 위치만 추가
              if (optimizer.WalkTrackingOptimizer.shouldAddLocation(
                location,
                currentWalk.route,
              )) {
                // 위치 평활화 적용
                final smoothedLocation =
                    optimizer.WalkTrackingOptimizer.smoothLocation(
                      location,
                      currentWalk.route.takeLast(3),
                    );

                ref
                    .read(currentWalkNotifierProvider.notifier)
                    .addLocationToCurrentWalk(smoothedLocation);
                ref
                    .read(currentLocationNotifierProvider.notifier)
                    .updateLocation(smoothedLocation);
              }
            }
          });
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  /// 위치 추적 중지
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = false;
  }
}

// 현재 위치 관리
@riverpod
class CurrentLocationNotifier extends _$CurrentLocationNotifier {
  @override
  WalkLocation? build() => null;

  void updateLocation(WalkLocation location) {
    state = location;
  }

  void clearLocation() {
    state = null;
  }
}

// 산책 통계 실시간 계산
@riverpod
class WalkStatsNotifier extends _$WalkStatsNotifier {
  @override
  WalkStats build() => const WalkStats();

  void updateStats(WalkRecordEntity walkRecord) {
    if (walkRecord.route.length < 2) return;

    // 거리 계산 (Google Maps API 또는 Haversine 공식 사용)
    double totalDistance = 0.0;
    for (int i = 1; i < walkRecord.route.length; i++) {
      final prev = walkRecord.route[i - 1];
      final curr = walkRecord.route[i];

      // 여기서 Google Maps Distance Matrix API를 사용하거나
      // Haversine 공식을 사용할 수 있습니다
      totalDistance += _calculateDistance(prev, curr);
    }

    // 시간 계산
    final duration = DateTime.now().difference(walkRecord.startTime);

    // 속도 계산 (km/h)
    final speed = duration.inMilliseconds > 0
        ? (totalDistance / (duration.inMilliseconds / 3600000))
        : 0.0;

    state = WalkStats(
      distance: totalDistance,
      duration: duration,
      speed: speed,
      steps: walkRecord.route.length,
    );
  }

  double _calculateDistance(WalkLocation from, WalkLocation to) {
    // 간단한 Haversine 공식 구현
    // 실제로는 Google Maps Distance Matrix API 사용 권장
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final lat1Rad = from.latitude * (3.14159265359 / 180);
    final lat2Rad = to.latitude * (3.14159265359 / 180);
    final deltaLat = (to.latitude - from.latitude) * (3.14159265359 / 180);
    final deltaLng = (to.longitude - from.longitude) * (3.14159265359 / 180);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c / 1000; // km 단위로 반환
  }
}

// 산책 통계 데이터 클래스
class WalkStats {
  final double distance; // km
  final Duration duration;
  final double speed; // km/h
  final int steps;

  const WalkStats({
    this.distance = 0.0,
    this.duration = Duration.zero,
    this.speed = 0.0,
    this.steps = 0,
  });

  WalkStats copyWith({
    double? distance,
    Duration? duration,
    double? speed,
    int? steps,
  }) {
    return WalkStats(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      steps: steps ?? this.steps,
    );
  }
}

class PetInfo {
  final String id;
  final String name;
  final String imagePath;

  const PetInfo({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}
