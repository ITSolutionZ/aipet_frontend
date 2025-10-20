import 'dart:async';
import 'dart:math' as math;

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/services/walk_tracking_optimizer.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_camera_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_marker_builder.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_polyline_builder.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'helpers/helpers.dart';

part 'live_walk_widget.g.dart';

enum WalkTimerState { ready, running, paused, stopped }

class LiveWalkState {
  final WalkTimerState timerState;
  final Duration elapsedTime;
  final List<WalkLocation> route;
  final Position? currentPosition;
  final Position? startPosition;
  final double distance;
  final GoogleMapController? mapController;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final WalkRecordEntity? currentWalkRecord;
  final Map<String, DateTime>? proximityWarnings; // 금지구역 경고 이력

  const LiveWalkState({
    this.timerState = WalkTimerState.ready,
    this.elapsedTime = Duration.zero,
    this.route = const [],
    this.currentPosition,
    this.startPosition,
    this.distance = 0.0,
    this.mapController,
    this.polylines = const {},
    this.markers = const {},
    this.currentWalkRecord,
    this.proximityWarnings,
  });

  LiveWalkState copyWith({
    WalkTimerState? timerState,
    Duration? elapsedTime,
    List<WalkLocation>? route,
    Position? currentPosition,
    Position? startPosition,
    double? distance,
    GoogleMapController? mapController,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    WalkRecordEntity? currentWalkRecord,
    Map<String, DateTime>? proximityWarnings,
  }) {
    return LiveWalkState(
      timerState: timerState ?? this.timerState,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      route: route ?? this.route,
      currentPosition: currentPosition ?? this.currentPosition,
      startPosition: startPosition ?? this.startPosition,
      distance: distance ?? this.distance,
      mapController: mapController ?? this.mapController,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      currentWalkRecord: currentWalkRecord ?? this.currentWalkRecord,
      proximityWarnings: proximityWarnings ?? this.proximityWarnings,
    );
  }

  bool get isRunning => timerState == WalkTimerState.running;
  bool get isPaused => timerState == WalkTimerState.paused;
  bool get isStopped => timerState == WalkTimerState.stopped;
  bool get isReady => timerState == WalkTimerState.ready;

  String get formattedTime {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes % 60;
    final seconds = elapsedTime.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)}km';
    }
  }

  /// 타이머 포맷 (mm:ss 또는 hh:mm:ss 형식)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

@riverpod
class LiveWalkController extends _$LiveWalkController {
  final _timerManager = LiveWalkTimerManager();
  final _locationTracker = LiveWalkLocationTracker();

  /// 타이머 상태를 별도로 관리하여 위치/거리 변경과 독립적으로 업데이트
  /// 이를 통해 타이머 틱(1초마다)이 map/control section의 전체 리빌드를 유발하지 않음
  final ValueNotifier<Duration> _elapsedTimeNotifier = ValueNotifier(
    Duration.zero,
  );

  ValueNotifier<Duration> get elapsedTimeNotifier => _elapsedTimeNotifier;

  @override
  LiveWalkState build() {
    _initializeCurrentLocation();
    _loadSavedWalk();

    // dispose 시 ValueNotifier 정리
    ref.onDispose(() {
      _elapsedTimeNotifier.dispose();
    });

    return const LiveWalkState();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      final position = await LiveWalkLocationTracker.getCurrentPosition();
      if (position != null) {
        state = state.copyWith(currentPosition: position);
        _updateMapMarkers();
        debugPrint('현재 위치 초기화 성공: ${position.latitude}, ${position.longitude}');
      } else {
        debugPrint('위치 권한이 거부되어 기본 위치를 사용합니다');
        _setDefaultLocation();
      }
    } catch (e) {
      debugPrint('초기 위치 가져오기 실패: $e');
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    final defaultPosition = LiveWalkLocationTracker.createDefaultPosition();
    state = state.copyWith(currentPosition: defaultPosition);
    _updateMapMarkers();
  }

  /// 저장된 산책 데이터 불러오기
  Future<void> _loadSavedWalk() async {
    final savedWalk = await LiveWalkStorageManager.loadSavedWalk();
    if (savedWalk != null) {
      state = state.copyWith(
        timerState: WalkTimerState.paused, // 일시정지 상태로 복원
        currentWalkRecord: savedWalk,
        route: savedWalk.route,
        distance: savedWalk.calculatedDistance,
        elapsedTime: savedWalk.calculatedDuration,
      );
      _timerManager.setElapsedTime(savedWalk.calculatedDuration);
      _elapsedTimeNotifier.value =
          savedWalk.calculatedDuration; // ValueNotifier도 동기화
      _updateMapMarkers();
      _updateMapPolylines();
    }
  }

  void setMapController(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
    _updateMapMarkers();
  }

  void startWalk() async {
    if (state.timerState == WalkTimerState.running) return;

    final currentPosition = await LiveWalkLocationTracker.getCurrentPosition();
    if (currentPosition == null) {
      debugPrint('위치를 가져올 수 없어 산책을 시작할 수 없습니다');
      return;
    }

    final startLocation = WalkLocation(
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
      timestamp: DateTime.now(),
      accuracy: currentPosition.accuracy,
    );

    // WalkRecordEntity 생성
    final walkRecord = WalkRecordEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: 'current_pet',
      petName: '実時間 散歩',
      startTime: DateTime.now(),
      route: [startLocation],
      status: WalkStatus.inProgress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      timerState: WalkTimerState.running,
      startPosition: currentPosition,
      currentPosition: currentPosition,
      route: [startLocation],
      elapsedTime: Duration.zero,
      distance: 0.0,
      currentWalkRecord: walkRecord,
    );

    // ✅ 타이머는 ValueNotifier로 관리하여 main state 변경 없음
    _elapsedTimeNotifier.value = Duration.zero;

    _timerManager.startTimer(() {
      if (state.timerState == WalkTimerState.running) {
        // 🚫 state 변경 대신 ValueNotifier 업데이트 (map 리빌드 방지)
        _elapsedTimeNotifier.value = _timerManager.elapsedTime;
      }
    });
    _startLocationTracking();
    _updateMapMarkers();
    _moveMapToCurrentPosition();

    // 현재 산책 상태 저장
    LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord).ignore();
  }

  void pauseWalk() {
    try {
      debugPrint('⏸️ pauseWalk() 시작');

      if (state.timerState != WalkTimerState.running) {
        debugPrint('⏸️ pauseWalk() - 현재 상태가 running이 아님: ${state.timerState}');
        return;
      }

      debugPrint('⏸️ pauseWalk() - 타이머 정지');
      _timerManager.stopTimer();

      debugPrint('⏸️ pauseWalk() - 위치 추적 정지');
      _locationTracker.stopTracking();

      // 🚀 timerState만 변경! (다른 필드는 건드리지 않음)
      // _ControlSection에서는 ref.read()를 사용하므로 자동 rebuild 안됨
      debugPrint('⏸️ pauseWalk() - state 업데이트');
      state = state.copyWith(timerState: WalkTimerState.paused);

      debugPrint('⏸️ pauseWalk() - 상태 저장');
      // 일시정지 상태 저장
      LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord);

      debugPrint('✅ pauseWalk() 완료');
    } catch (e) {
      debugPrint('❌ pauseWalk() 에러: $e');
      rethrow;
    }
  }

  void resumeWalk() {
    try {
      debugPrint('▶️ resumeWalk() 시작');

      if (state.timerState != WalkTimerState.running &&
          state.timerState != WalkTimerState.paused) {
        debugPrint(
          '▶️ resumeWalk() - 상태가 running/paused 아님: ${state.timerState}',
        );
        return;
      }

      // 🚀 timerState만 변경!
      debugPrint('▶️ resumeWalk() - state 업데이트');
      state = state.copyWith(timerState: WalkTimerState.running);

      debugPrint('▶️ resumeWalk() - 타이머 시작');
      _timerManager.startTimer(() {
        // ValueNotifier로만 업데이트 (state 변경 X)
        _elapsedTimeNotifier.value = _timerManager.elapsedTime;
      });

      debugPrint('▶️ resumeWalk() - 위치 추적 시작');
      _startLocationTracking();

      debugPrint('▶️ resumeWalk() - 상태 저장');
      // 재시작 상태 저장
      LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord);

      debugPrint('✅ resumeWalk() 완료');
    } catch (e) {
      debugPrint('❌ resumeWalk() 에러: $e');
      rethrow;
    }
  }

  void stopWalk() {
    try {
      debugPrint('⏹️ stopWalk() 시작');

      // 🚀 timerState만 변경!
      debugPrint('⏹️ stopWalk() - state 업데이트');
      state = state.copyWith(timerState: WalkTimerState.stopped);

      debugPrint('⏹️ stopWalk() - 타이머 정지');
      _timerManager.stopTimer();

      debugPrint('⏹️ stopWalk() - 위치 추적 정지');
      _locationTracker.stopTracking();

      debugPrint('⏹️ stopWalk() - 산책 저장');
      // 완료된 산책 저장
      if (state.currentWalkRecord != null) {
        LiveWalkStorageManager.saveCompletedWalk(
          state.currentWalkRecord!,
          state.distance,
        );
      }

      debugPrint('✅ stopWalk() 완료');
    } catch (e) {
      debugPrint('❌ stopWalk() 에러: $e');
      rethrow;
    }
  }

  void completeWalk(String? notes) {
    if (state.currentWalkRecord != null) {
      // 메모 추가하여 완료 처리
      final updatedWalkRecord = state.currentWalkRecord!.copyWith(
        notes: notes,
        status: WalkStatus.completed,
        endTime: DateTime.now(),
        distance: state.distance / 1000, // m -> km 변환
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        timerState: WalkTimerState.stopped,
        currentWalkRecord: updatedWalkRecord,
      );

      _timerManager.stopTimer();
      _locationTracker.stopTracking();

      // 완료된 산책 저장
      LiveWalkStorageManager.saveCompletedWalk(
        updatedWalkRecord,
        state.distance,
      );
    }
  }

  void resetWalk() {
    state = state.copyWith(
      timerState: WalkTimerState.ready,
      elapsedTime: Duration.zero,
      route: [],
      startPosition: null,
      distance: 0.0,
      polylines: {},
      currentWalkRecord: null,
    );
    _timerManager.resetTimer();
    _elapsedTimeNotifier.value = Duration.zero; // ValueNotifier도 리셋
    _locationTracker.stopTracking();
    _updateMapMarkers();

    // 현재 산책 데이터 제거 (백그라운드에서 실행)
    LiveWalkStorageManager.cancelWalk().ignore();
  }

  void _startLocationTracking() {
    _locationTracker.startTracking(
      onLocationUpdate: (location) => _updateLocation(location),
      onError: () {
        debugPrint('위치 추적 에러 발생');
      },
    );
  }

  Future<void> _updateLocation(WalkLocation location) async {
    try {
      // 📊 위치 업데이트 수신 통지
      final currentTime = DateTime.now().toIso8601String();
      debugPrint(
        '📍 위치 콜백 수신[$currentTime]: lat=${location.latitude.toStringAsFixed(6)}, lng=${location.longitude.toStringAsFixed(6)}, accuracy=${location.accuracy?.toStringAsFixed(1)}m',
      );

      // WalkTrackingOptimizer를 사용한 위치 데이터 유효성 검증
      if (!WalkTrackingOptimizer.isValidLocation(location)) {
        debugPrint('❌ 유효하지 않은 위치 데이터 무시: 정확도 ${location.accuracy}m');
        return;
      }

      // 기존 경로가 있는 경우 WalkTrackingOptimizer로 위치 추가 여부 결정
      if (state.route.isNotEmpty) {
        if (!WalkTrackingOptimizer.shouldAddLocation(location, state.route)) {
          debugPrint('⏭️ 위치 변화 무시: 최적화 필터에 의해 제외됨');
          return;
        }
      }

      // 위치가 실제로 변경되었는지 확인 (GPS 정확도와 최소 이동 거리 고려)
      if (state.currentPosition != null) {
        final distance = _calculateDistance(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
          location.latitude,
          location.longitude,
        );

        // GPS 정확도와 최소 이동 거리를 동적으로 계산
        final accuracy = location.accuracy ?? 10.0; // 기본값 10m
        final minDistance = _calculateMinimumDistance(accuracy);

        // GPS 오차 범위 내 이동은 무시
        if (distance < minDistance) {
          debugPrint(
            '🚫 GPS오차범위 무시: ${distance.toStringAsFixed(2)}m (최소 ${minDistance.toStringAsFixed(1)}m 필요, 정확도: ${accuracy.toStringAsFixed(1)}m)',
          );
          return;
        }

        debugPrint(
          '✅ 위치 변경 감지: ${distance.toStringAsFixed(2)}m 이동 (정확도: ${accuracy.toStringAsFixed(1)}m)',
        );
      }

      // WalkTrackingOptimizer를 사용한 위치 평활화 (선택적)
      final smoothedLocation = state.route.length >= 3
          ? WalkTrackingOptimizer.smoothLocation(location, state.route)
          : location;

      final newRoute = [...state.route, smoothedLocation];
      final newDistance = _calculateTotalDistance(newRoute);

      // 🚀 핵심: 거리가 실제로 변경되었을 때만 state를 업데이트
      if (newDistance == state.distance) {
        debugPrint(
          '⏸️ 거리 변화 없음 (이전: ${state.distance}m, 현재: $newDistance m), state 업데이트 무시',
        );
        return;
      }

      debugPrint(
        '📊 거리 변화 감지: ${state.distance}m -> $newDistance m (${(newDistance - state.distance).toStringAsFixed(1)}m 증가)',
      );

      // WalkRecord 업데이트
      final updatedWalkRecord = state.currentWalkRecord?.copyWith(
        route: newRoute,
        distance: newDistance / 1000, // km로 변환
        updatedAt: DateTime.now(),
      );

      // Position 객체 생성 (기존 코드 호환성)
      final position = Position(
        latitude: smoothedLocation.latitude,
        longitude: smoothedLocation.longitude,
        timestamp: smoothedLocation.timestamp,
        accuracy: smoothedLocation.accuracy ?? 0,
        altitude: smoothedLocation.altitude ?? 0,
        heading: smoothedLocation.heading ?? 0,
        speed: smoothedLocation.speed ?? 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      state = state.copyWith(
        currentPosition: position,
        route: newRoute,
        distance: newDistance,
        currentWalkRecord: updatedWalkRecord,
      );

      debugPrint(
        '🔄 State 업데이트됨: 거리 $newDistance m, 경로 포인트 ${newRoute.length}개',
      );

      // 맵 업데이트
      _updateMapPolylines();
      _updateMapMarkers();

      // 위치 업데이트 시 현재 상태 저장 (백그라운드에서 실행)
      LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord).ignore();
    } catch (e) {
      debugPrint('❌ 위치 업데이트 실패: $e');
    }
  }

  double _calculateTotalDistance(List<WalkLocation> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < route.length; i++) {
      totalDistance += _calculateDistance(
        route[i - 1].latitude,
        route[i - 1].longitude,
        route[i].latitude,
        route[i].longitude,
      );
    }
    return totalDistance;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// GPS 정확도를 고려한 최소 이동 거리 계산
  /// 정확도가 낮을수록 더 큰 이동 거리가 필요함
  double _calculateMinimumDistance(double accuracy) {
    // 기본 최소 거리: 3m
    const double baseMinDistance = 3.0;

    // GPS 정확도가 10m 이하: 정확도 * 1.5
    // GPS 정확도가 10m 초과: 정확도 * 2.0 (더 보수적)
    final double accuracyMultiplier = accuracy <= 10.0 ? 1.5 : 2.0;
    final double calculatedDistance = accuracy * accuracyMultiplier;

    // 최소 3m, 최대 20m로 제한
    return math.max(baseMinDistance, math.min(calculatedDistance, 20.0));
  }

  void _updateMapPolylines() {
    if (state.currentWalkRecord == null) return;

    final polyline = WalkMapPolylineBuilder.buildLiveTrackingPolyline(
      state.currentWalkRecord,
      color: AppColors.pointBrown,
      width: 4,
    );

    if (polyline != null) {
      final newPolylines = {polyline};
      // 🚀 엄격한 중복 방지: Set 내용을 정확히 비교
      if (state.polylines.length != newPolylines.length ||
          !_arePolylinesEqual(state.polylines, newPolylines)) {
        debugPrint(
          '🔄 Polylines 업데이트: ${state.polylines.length} -> ${newPolylines.length}',
        );
        state = state.copyWith(polylines: newPolylines);
      }
    }
  }

  /// Polyline Set 비교 (정확한 내용 비교)
  bool _arePolylinesEqual(Set<Polyline> set1, Set<Polyline> set2) {
    if (set1.length != set2.length) return false;

    for (final polyline1 in set1) {
      bool found = false;
      for (final polyline2 in set2) {
        if (polyline1.polylineId == polyline2.polylineId &&
            polyline1.points.length == polyline2.points.length) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  void _updateMapMarkers() {
    final markers = <Marker>{};

    // 현재 위치 마커
    if (state.currentPosition != null) {
      markers.add(
        WalkMapMarkerBuilder.buildCurrentLocationMarker(state.currentPosition!),
      );
    }

    // 산책 시작점 마커
    if (state.currentWalkRecord != null &&
        state.currentWalkRecord!.route.isNotEmpty) {
      markers.add(
        WalkMapMarkerBuilder.buildWalkStartMarker(state.currentWalkRecord!, 0),
      );
    }

    // 🚀 엄격한 중복 방지: Set 내용을 정확히 비교
    if (state.markers.length != markers.length ||
        !_areMarkersEqual(state.markers, markers)) {
      debugPrint(
        '🔄 Markers 업데이트: ${state.markers.length} -> ${markers.length}',
      );
      state = state.copyWith(markers: markers);
    }
  }

  /// Marker Set 비교 (정확한 내용 비교)
  bool _areMarkersEqual(Set<Marker> set1, Set<Marker> set2) {
    if (set1.length != set2.length) return false;

    for (final marker1 in set1) {
      bool found = false;
      for (final marker2 in set2) {
        if (marker1.markerId == marker2.markerId &&
            marker1.position.latitude == marker2.position.latitude &&
            marker1.position.longitude == marker2.position.longitude) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  void _moveMapToCurrentPosition() {
    if (state.mapController != null && state.currentPosition != null) {
      WalkMapCameraController.moveToCurrentLocation(
        state.mapController!,
        state.currentPosition!,
        zoom: 17.0,
      );
    }
  }
}

class LiveWalkWidget extends StatelessWidget {
  final String? petId;
  final String? petName;

  const LiveWalkWidget({super.key, this.petId, this.petName});

  @override
  Widget build(BuildContext context) {
    debugPrint('👨‍👧‍👦 LiveWalkWidget.build() - 한 번만 호출되어야 함');

    return Scaffold(
      appBar: AppBar(
        title: Text(petName != null ? '${petName}の散歩' : '実時間 散歩'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Column(
        children: [
          // 맵: 위치 변경 시만 리빌드 (완전 독립)
          Expanded(flex: 3, child: _MapSection()),
          // 컨트롤: 거리 변경 시만 리빌드 (완전 독립)
          Expanded(flex: 1, child: _ControlSection()),
        ],
      ),
    );
  }
}

/// 컨트롤 섹션 - ConsumerStatefulWidget (거리 변경 시만 listen & rebuild)
class _ControlSection extends ConsumerStatefulWidget {
  const _ControlSection();

  @override
  ConsumerState<_ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends ConsumerState<_ControlSection> {
  double _cachedDistance = 0;
  WalkTimerState _cachedTimerState = WalkTimerState.ready;
  int _cachedRouteLength = 0;
  WalkRecordEntity? _cachedCurrentWalkRecord;
  int _controlBuildCount = 0;
  DateTime? _controlLastBuild;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 초기 설정
    if (!_isInitialized) {
      _isInitialized = true;
      final currentState = ref.read(liveWalkControllerProvider);
      _cachedDistance = currentState.distance;
      _cachedTimerState = currentState.timerState;
      _cachedRouteLength = currentState.route.length;
      _cachedCurrentWalkRecord = currentState.currentWalkRecord;

      // 거리 변경 listen 설정
      Future.microtask(() {
        if (mounted) {
          ref.listen(
            liveWalkControllerProvider.select((state) => state.distance),
            (prev, next) {
              if (mounted && _cachedDistance != next) {
                debugPrint('📊 거리 변경 감지: $_cachedDistance -> $next');
                setState(() {
                  _cachedDistance = next;
                });
              }
            },
          );
        }
      });
    }

    _controlBuildCount++;
    final now = DateTime.now();
    final timeSinceLastBuild = _controlLastBuild != null
        ? now.difference(_controlLastBuild!).inMilliseconds
        : 0;
    _controlLastBuild = now;

    debugPrint(
      '⚙️ _ControlSection.build() 호출 #$_controlBuildCount (${timeSinceLastBuild}ms 경과)',
    );

    // 🚀 현재 상태를 ref.read로 가져옴 (watch 제거!)
    final currentState = ref.read(liveWalkControllerProvider);
    _cachedTimerState = currentState.timerState;
    _cachedRouteLength = currentState.route.length;
    _cachedCurrentWalkRecord = currentState.currentWalkRecord;

    final walkController = ref.read(liveWalkControllerProvider.notifier);
    final formattedDistance =
        '${(_cachedDistance / 1000).toStringAsFixed(2)} km';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatsRow(
                distance: formattedDistance,
                timerState: _cachedTimerState,
                routeLength: _cachedRouteLength,
                currentWalkRecord: _cachedCurrentWalkRecord,
                elapsedTimeNotifier: walkController.elapsedTimeNotifier,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildControlButtons(
                context,
                timerState: _cachedTimerState,
                walkController: walkController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow({
    required String distance,
    required WalkTimerState timerState,
    required int routeLength,
    required WalkRecordEntity? currentWalkRecord,
    required ValueNotifier<Duration> elapsedTimeNotifier,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ⏱️ 타이머: ValueListenableBuilder로 독립적으로 업데이트됨
            _TimerDisplay(elapsedTimeNotifier: elapsedTimeNotifier),
            _buildStatCard('거리', distance, Icons.straighten),
            _buildStatCard(
              '상태',
              _getStatusText(timerState),
              Icons.directions_run,
            ),
          ],
        ),
        // 디버그 정보 (테스트용)
        if (currentWalkRecord != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '📱 ID: ${currentWalkRecord.id.substring(0, 8)}... | ポイント: $routeLength個',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.pointBrown, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(
    BuildContext context, {
    required WalkTimerState timerState,
    required LiveWalkController walkController,
  }) {
    final isReady = timerState == WalkTimerState.ready;
    final isRunning = timerState == WalkTimerState.running;
    final isPaused = timerState == WalkTimerState.paused;
    final isStopped = timerState == WalkTimerState.stopped;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (isReady) ...[
          _buildControlButton(
            '開始',
            Icons.play_arrow,
            AppColors.pointBrown,
            () => walkController.startWalk(),
          ),
        ] else if (isRunning) ...[
          _buildControlButton(
            '一時停止',
            Icons.pause,
            Colors.orange,
            () => walkController.pauseWalk(),
          ),
        ] else if (isPaused) ...[
          _buildControlButton(
            '再開',
            Icons.play_arrow,
            AppColors.pointBrown,
            () => walkController.resumeWalk(),
          ),
          _buildControlButton(
            '中止',
            Icons.stop,
            Colors.red,
            () => walkController.stopWalk(),
          ),
        ] else if (isStopped) ...[
          _buildControlButton(
            '完了',
            Icons.check_circle,
            Colors.green,
            () => _showCompleteWalkDialog(context, walkController),
          ),
          _buildControlButton(
            'リセット',
            Icons.refresh,
            Colors.grey,
            () => walkController.resetWalk(),
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCompleteWalkDialog(
    BuildContext context,
    LiveWalkController walkController,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '산책 메모',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '산책 중 특별한 일이 있었나요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeWalk(
                    context,
                    walkController,
                    notesController.text,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _completeWalk(
    BuildContext context,
    LiveWalkController walkController,
    String? notes,
  ) {
    walkController.completeWalk(notes);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('산책이 완료되었습니다!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  String _getStatusText(WalkTimerState state) {
    switch (state) {
      case WalkTimerState.ready:
        return '준비';
      case WalkTimerState.running:
        return '진행중';
      case WalkTimerState.paused:
        return '일시정지';
      case WalkTimerState.stopped:
        return '중단';
    }
  }
}

/// ⏱️ 타이머 디스플레이 - 매초 업데이트되지만 다른 위젯에 영향을 주지 않음
/// ValueListenableBuilder를 사용하여 오직 타이머만 리빌드됨
class _TimerDisplay extends StatelessWidget {
  final ValueNotifier<Duration> elapsedTimeNotifier;

  const _TimerDisplay({required this.elapsedTimeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: elapsedTimeNotifier,
      builder: (context, elapsedTime, child) {
        return Column(
          children: [
            const Icon(Icons.timer, color: AppColors.pointBrown, size: 20),
            const SizedBox(height: 4),
            const Text(
              '시간',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.pointGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              LiveWalkState.formatDuration(elapsedTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.pointBrown,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 맵 섹션 - 위치 변경 시만 리빌드 (완전 분리)
class _MapSection extends ConsumerStatefulWidget {
  const _MapSection();

  @override
  ConsumerState<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<_MapSection> {
  GoogleMapController? _mapController;
  String? _lastPositionKey;
  Set<Marker> _lastMarkers = {};
  Set<Polyline> _lastPolylines = {};
  int _buildCallCount = 0;
  DateTime? _lastBuildTime;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 초기 setup 한 번만
    if (!_isInitialized) {
      _isInitialized = true;

      // 🚀 위치 변경만 listen (타이머 완전 무시)
      Future.microtask(() {
        if (mounted) {
          ref.listen(
            liveWalkControllerProvider.select((state) {
              if (state.currentPosition == null) return null;
              return '${state.currentPosition!.latitude.toStringAsFixed(6)},${state.currentPosition!.longitude.toStringAsFixed(6)}';
            }),
            (prev, next) {
              debugPrint('🗺️ 위치 변경: $prev -> $next');
              if (mounted) setState(() {}); // 위치 변경 시만 rebuild
            },
          );
        }
      });
    }

    _buildCallCount++;
    final now = DateTime.now();
    final timeSinceLastBuild = _lastBuildTime != null
        ? now.difference(_lastBuildTime!).inMilliseconds
        : 0;
    _lastBuildTime = now;

    debugPrint(
      '🗺️ _MapSection.build() 호출 #$_buildCallCount (이전 빌드로부터 ${timeSinceLastBuild}ms 경과)',
    );

    // 🚀 ref.read()만 사용 (watch 제거!)
    final currentState = ref.read(liveWalkControllerProvider);

    final currentPosition = currentState.currentPosition;
    final markers = currentState.markers;
    final polylines = currentState.polylines;

    if (currentPosition == null) {
      return Container(
        color: Colors.grey[100]!,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '位置情報を取得中...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'GPSをオンにしてください',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 🚀 실제 변경이 있을 때만 업데이트
    final positionKey =
        '${currentPosition.latitude.toStringAsFixed(6)},${currentPosition.longitude.toStringAsFixed(6)}';
    final shouldUpdate =
        _lastPositionKey != positionKey ||
        _lastMarkers != markers ||
        _lastPolylines != polylines;

    if (shouldUpdate) {
      debugPrint('🎨 맵 업데이트 필요: positionKey=$positionKey');
      _lastPositionKey = positionKey;
      _lastMarkers = markers;
      _lastPolylines = polylines;

      // 카메라 이동 (위치 변경 시에만)
      if (_mapController != null && _lastPositionKey != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_mapController != null && mounted) {
            WalkMapCameraController.moveToCurrentLocation(
              _mapController!,
              currentPosition,
              zoom: 16.0,
            );
          }
        });
      }
    }

    return GoogleMap(
      key: const ValueKey('live_walk_map'),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        ref
            .read(liveWalkControllerProvider.notifier)
            .setMapController(controller);
        WalkMapCameraController.moveToCurrentLocation(
          controller,
          currentPosition,
          zoom: 16.0,
        );
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 16.0,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      buildingsEnabled: true,
      indoorViewEnabled: false,
      trafficEnabled: false,
    );
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}
