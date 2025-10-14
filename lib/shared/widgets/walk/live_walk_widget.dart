import 'dart:async';
import 'dart:math' as math;

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_camera_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_marker_builder.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_polyline_builder.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/walk/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
}

final liveWalkProvider =
    StateNotifierProvider<LiveWalkController, LiveWalkState>(
      (ref) => LiveWalkController(),
    );

class LiveWalkController extends StateNotifier<LiveWalkState> {
  final _timerManager = LiveWalkTimerManager();
  final _locationTracker = LiveWalkLocationTracker();

  LiveWalkController() : super(const LiveWalkState()) {
    _initializeCurrentLocation();
    _loadSavedWalk();
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

    _timerManager.startTimer(() {
      if (state.timerState == WalkTimerState.running) {
        state = state.copyWith(elapsedTime: _timerManager.elapsedTime);
      }
    });
    _startLocationTracking();
    _updateMapMarkers();
    _moveMapToCurrentPosition();

    // 현재 산책 상태 저장
    LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord).ignore();
  }

  void pauseWalk() {
    if (state.timerState != WalkTimerState.running) return;

    state = state.copyWith(timerState: WalkTimerState.paused);
    _timerManager.stopTimer();
    _locationTracker.stopTracking();

    // 일시정지 상태 저장
    LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord);
  }

  void resumeWalk() {
    if (state.timerState != WalkTimerState.paused) return;

    state = state.copyWith(timerState: WalkTimerState.running);
    _timerManager.startTimer(() {
      if (state.timerState == WalkTimerState.running) {
        state = state.copyWith(elapsedTime: _timerManager.elapsedTime);
      }
    });
    _startLocationTracking();

    // 재시작 상태 저장
    LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord);
  }

  void stopWalk() {
    state = state.copyWith(timerState: WalkTimerState.stopped);
    _timerManager.stopTimer();
    _locationTracker.stopTracking();

    // 완료된 산책 저장
    if (state.currentWalkRecord != null) {
      LiveWalkStorageManager.saveCompletedWalk(
        state.currentWalkRecord!,
        state.distance,
      );
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
      final position = await LiveWalkLocationTracker.getCurrentPosition();
      if (position == null) return;

      final newLocation = WalkLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
      );

      final newRoute = [...state.route, newLocation];
      final newDistance = _calculateTotalDistance(newRoute);

      // WalkRecord 업데이트
      final updatedWalkRecord = state.currentWalkRecord?.copyWith(
        route: newRoute,
        distance: newDistance / 1000, // km로 변환
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        currentPosition: position,
        route: newRoute,
        distance: newDistance,
        currentWalkRecord: updatedWalkRecord,
      );

      _updateMapPolylines();
      _updateMapMarkers();
      _moveMapToCurrentPosition();

      // 위치 업데이트 시 현재 상태 저장 (백그라운드에서 실행)
      LiveWalkStorageManager.saveCurrentWalk(state.currentWalkRecord).ignore();
    } catch (e) {
      debugPrint('위치 업데이트 실패: $e');
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

  void _updateMapPolylines() {
    if (state.currentWalkRecord == null) return;

    final polyline = WalkMapPolylineBuilder.buildLiveTrackingPolyline(
      state.currentWalkRecord,
      color: AppColors.pointBrown,
      width: 4,
    );

    if (polyline != null) {
      state = state.copyWith(polylines: {polyline});
    }
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

    state = state.copyWith(markers: markers);
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

  @override
  void dispose() {
    _timerManager.stopTimer();
    _locationTracker.stopTracking();
    super.dispose();
  }
}

class LiveWalkWidget extends ConsumerWidget {
  final String? petId;
  final String? petName;

  const LiveWalkWidget({super.key, this.petId, this.petName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkState = ref.watch(liveWalkProvider);
    final walkController = ref.read(liveWalkProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(petName != null ? '$petName의 산책' : '실시간 산책'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: _buildMapSection(walkState, walkController)),
          Expanded(
            flex: 1,
            child: _buildControlSection(context, walkState, walkController),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(
    LiveWalkState walkState,
    LiveWalkController walkController,
  ) {
    if (walkState.currentPosition == null) {
      return Container(
        color: Colors.grey[100]!,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '위치 정보를 가져오는 중...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'GPS를 켜주세요',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        walkController.setMapController(controller);
        // 초기 위치로 이동
        if (walkState.currentPosition != null) {
          WalkMapCameraController.moveToCurrentLocation(
            controller,
            walkState.currentPosition!,
            zoom: 16.0,
          );
        }
      },
      initialCameraPosition:
          WalkMapCameraController.createDefaultCameraPosition(
            latitude: walkState.currentPosition!.latitude,
            longitude: walkState.currentPosition!.longitude,
            zoom: 16.0,
          ),
      markers: walkState.markers,
      polylines: walkState.polylines,
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

  Widget _buildControlSection(
    BuildContext context,
    LiveWalkState walkState,
    LiveWalkController walkController,
  ) {
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
              _buildStatsRow(walkState),
              const SizedBox(height: AppSpacing.md),
              _buildControlButtons(context, walkState, walkController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(LiveWalkState walkState) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('시간', walkState.formattedTime, Icons.timer),
            _buildStatCard('거리', walkState.formattedDistance, Icons.straighten),
            _buildStatCard(
              '상태',
              _getStatusText(walkState.timerState),
              Icons.directions_run,
            ),
          ],
        ),
        // 디버그 정보 (테스트용)
        if (walkState.currentWalkRecord != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '📱 ID: ${walkState.currentWalkRecord!.id.substring(0, 8)}... | 포인트: ${walkState.route.length}개',
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
    BuildContext context,
    LiveWalkState walkState,
    LiveWalkController walkController,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (walkState.isReady) ...[
          _buildControlButton(
            '시작',
            Icons.play_arrow,
            AppColors.pointBrown,
            () => walkController.startWalk(),
          ),
        ] else if (walkState.isRunning) ...[
          _buildControlButton(
            '일시정지',
            Icons.pause,
            Colors.orange,
            () => walkController.pauseWalk(),
          ),
          _buildControlButton(
            '완료',
            Icons.check,
            Colors.green,
            () => _showCompleteWalkDialog(context, walkState, walkController),
          ),
          _buildControlButton(
            '정지',
            Icons.stop,
            Colors.red,
            () => walkController.stopWalk(),
          ),
        ] else if (walkState.isPaused) ...[
          _buildControlButton(
            '재시작',
            Icons.play_arrow,
            AppColors.pointBrown,
            () => walkController.resumeWalk(),
          ),
          _buildControlButton(
            '완료',
            Icons.check,
            Colors.green,
            () => _showCompleteWalkDialog(context, walkState, walkController),
          ),
          _buildControlButton(
            '정지',
            Icons.stop,
            Colors.red,
            () => walkController.stopWalk(),
          ),
        ] else if (walkState.isStopped) ...[
          _buildControlButton(
            '새 산책',
            Icons.refresh,
            AppColors.pointBrown,
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(100, 40),
      ),
    );
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
        return '완료';
    }
  }

  /// 산책 완료 확인 바텀시트
  void _showCompleteWalkDialog(
    BuildContext context,
    LiveWalkState walkState,
    LiveWalkController walkController,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildCompleteWalkBottomSheet(context, walkState, walkController),
    );
  }

  Widget _buildCompleteWalkBottomSheet(
    BuildContext context,
    LiveWalkState walkState,
    LiveWalkController walkController,
  ) {
    final TextEditingController notesController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 제목
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '산책 완료',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointBrown,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 산책 요약 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          '시간',
                          walkState.formattedTime,
                          Icons.timer,
                        ),
                        _buildSummaryItem(
                          '거리',
                          walkState.formattedDistance,
                          Icons.straighten,
                        ),
                        _buildSummaryItem(
                          '포인트',
                          '${walkState.route.length}개',
                          Icons.location_on,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 메모 입력
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: '산책 메모 (선택사항)',
                  hintText: '오늘 산책은 어땠나요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note_add),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 산책 완료 처리
                        _completeWalk(
                          context,
                          walkController,
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('완료'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.pointBrown, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.pointGray),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
      ],
    );
  }

  /// 산책 완료 처리
  void _completeWalk(
    BuildContext context,
    LiveWalkController walkController,
    String? notes,
  ) {
    // 메모와 함께 산책 완료
    walkController.completeWalk(notes);

    // 바텀시트 닫기
    Navigator.of(context).pop();

    // 완료 메시지 표시
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

    // 완료 후 2초 뒤에 이전 화면으로 돌아가기
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
