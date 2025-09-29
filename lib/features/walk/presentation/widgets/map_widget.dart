import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/pet_info.dart';
import 'map/walk_map_camera_controller.dart';
import 'map/walk_map_marker_builder.dart';
import 'map/walk_map_polyline_builder.dart';

final mapWidgetProvider =
    StateNotifierProvider.family<
      MapWidgetController,
      MapWidgetState,
      MapWidgetParams
    >((ref, params) => MapWidgetController(params));

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
    getCurrentLocation();
    setupMarkersAndPolylines();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      state = state.copyWith(currentPosition: position);

      if (state.mapController != null) {
        await WalkMapCameraController.moveToCurrentLocation(
          state.mapController!,
          position,
        );
      }
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
    }
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
    final params = MapWidgetParams(
      walkRecords: walkRecords,
      selectedPet: selectedPet,
    );
    final controller = ref.read(mapWidgetProvider(params).notifier);
    final state = ref.watch(mapWidgetProvider(params));
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: state.currentPosition == null
            ? _buildLoadingState()
            : GoogleMap(
                onMapCreated: (GoogleMapController mapController) {
                  controller.setMapController(mapController);
                  controller.setupMarkersAndPolylines();

                  WalkMapCameraController.moveToCurrentLocation(
                    mapController,
                    state.currentPosition!,
                  );
                },
                initialCameraPosition:
                    WalkMapCameraController.createDefaultCameraPosition(
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
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '地図を読み込み中...',
              style: TextStyle(color: AppColors.pointGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
