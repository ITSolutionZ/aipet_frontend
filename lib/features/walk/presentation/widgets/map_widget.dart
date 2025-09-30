import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../domain/entities/pet_info.dart';
import 'map/walk_map_camera_controller.dart';
import 'map/walk_map_marker_builder.dart';
import 'map/walk_map_polyline_builder.dart';

final mapWidgetProvider =
    StateNotifierProvider.family<MapWidgetController, MapWidgetState, MapWidgetParams>(
      (ref, params) => MapWidgetController(params),
    );

class MapWidgetParams {
  final List<WalkRecordEntity> walkRecords;
  final PetInfo? selectedPet;

  const MapWidgetParams({required this.walkRecords, this.selectedPet});
}

class MapWidgetState {
  final GoogleMapController? mapController;
  final Position? currentPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  const MapWidgetState({
    this.mapController,
    this.currentPosition,
    this.markers = const {},
    this.polylines = const {},
  });

  MapWidgetState copyWith({
    GoogleMapController? mapController,
    Position? currentPosition,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
  }) {
    return MapWidgetState(
      mapController: mapController ?? this.mapController,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
    );
  }
}

class MapWidgetController extends StateNotifier<MapWidgetState> {
  final MapWidgetParams params;

  MapWidgetController(this.params) : super(const MapWidgetState()) {
    debugPrint('🗺️ MapWidgetController: 초기화 시작');
    // 즉시 기본 위치를 설정한 후 실제 위치를 가져오도록 변경
    _setDefaultLocation();
    getCurrentLocation();
    setupMarkersAndPolylines();
    debugPrint('🗺️ MapWidgetController: 초기화 완료');
  }

  Future<void> getCurrentLocation() async {
    try {
      debugPrint('🗺️ MapWidget: 위치 권한 확인 시작');
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🗺️ MapWidget: 현재 위치 권한 상태 - $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('🗺️ MapWidget: 위치 권한 요청 중...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ MapWidget: 위치 권한 거부됨');
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ MapWidget: 위치 권한 영구 거부됨');
        _setDefaultLocation();
        return;
      }

      debugPrint('🗺️ MapWidget: GPS 위치 취득 중...');
      final Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏰ MapWidget: GPS 위치 취득 타임아웃');
              throw Exception('GPS 위치 취득 타임아웃');
            },
          );

      debugPrint('✅ MapWidget: GPS 위치 취득 성공 - ${position.latitude}, ${position.longitude}');
      state = state.copyWith(currentPosition: position);

      if (state.mapController != null) {
        await WalkMapCameraController.moveToCurrentLocation(state.mapController!, position);
      }
    } catch (e) {
      debugPrint('❌ MapWidget: 위치 가져오기 실패 - $e');
      _setDefaultLocation();
    }
  }

  /// 기본 위치 설정 (도쿄)
  void _setDefaultLocation() {
    debugPrint('🗺️ MapWidget: 기본 위치(도쿄) 설정 시작');
    final defaultPosition = Position(
      latitude: 35.6762,
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

    state = state.copyWith(currentPosition: defaultPosition);
    debugPrint(
      '🗺️ MapWidget: 기본 위치 설정 완료 - ${defaultPosition.latitude}, ${defaultPosition.longitude}',
    );
    debugPrint(
      '🗺️ MapWidget: 현재 State - currentPosition: ${state.currentPosition != null ? "있음" : "없음"}',
    );
  }

  void setupMarkersAndPolylines() {
    final markers = <Marker>{};
    markers.addAll(
      WalkMapMarkerBuilder.buildAllMarkers(
        walkRecords: params.walkRecords,
        currentPosition: state.currentPosition,
        selectedPet: params.selectedPet,
      ),
    );

    final polylines = <Polyline>{};
    polylines.addAll(
      WalkMapPolylineBuilder.buildAllPolylines(
        params.walkRecords,
        defaultColor: AppColors.pointBrown,
      ),
    );

    state = state.copyWith(markers: markers, polylines: polylines);
  }

  void setMapController(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
  }
}

class MapWidget extends ConsumerWidget {
  final List<WalkRecordEntity> walkRecords;
  final PetInfo? selectedPet;

  const MapWidget({super.key, required this.walkRecords, this.selectedPet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🗺️ MapWidget: build() 호출됨');
    final params = MapWidgetParams(walkRecords: walkRecords, selectedPet: selectedPet);
    final controller = ref.read(mapWidgetProvider(params).notifier);
    final state = ref.watch(mapWidgetProvider(params));

    debugPrint(
      '🗺️ MapWidget: State 확인 - currentPosition: ${state.currentPosition != null ? "있음 (${state.currentPosition!.latitude}, ${state.currentPosition!.longitude})" : "없음"}',
    );

    return state.currentPosition == null
        ? _buildLoadingState()
        : GoogleMap(
            onMapCreated: (GoogleMapController mapController) {
              controller.setMapController(mapController);
              controller.setupMarkersAndPolylines();

              WalkMapCameraController.moveToCurrentLocation(mapController, state.currentPosition!);
            },
            initialCameraPosition: WalkMapCameraController.createDefaultCameraPosition(
              latitude: state.currentPosition!.latitude,
              longitude: state.currentPosition!.longitude,
              zoom: 15.0,
            ),
            markers: state.markers,
            polylines: state.polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onCameraMove: (CameraPosition position) {
              // 카메라 이동 시 추가 로직 (필요시)
            },
          );
  }

  Widget _buildLoadingState() {
    debugPrint('🗺️ MapWidget: _buildLoadingState() 호출됨 - 위치 정보가 없어서 로딩 화면 표시');
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie 로딩 애니메이션
            lottie.Lottie.asset(
              'assets/lottie/loading.json',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              '地図を読み込み中...',
              style: TextStyle(
                color: AppColors.pointGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
