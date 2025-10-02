import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final facilityGoogleMapProvider =
    StateNotifierProvider.family<
      FacilityGoogleMapController,
      FacilityGoogleMapState,
      FacilityGoogleMapParams
    >((ref, params) => FacilityGoogleMapController(params));

class FacilityGoogleMapParams {
  final Facility facility;
  final List<Facility>? nearbyFacilities;
  final VoidCallback? onMapTap;
  final Function(Facility)? onFacilityTap;

  const FacilityGoogleMapParams({
    required this.facility,
    this.nearbyFacilities,
    this.onMapTap,
    this.onFacilityTap,
  });
}

class FacilityGoogleMapState {
  final GoogleMapController? mapController;
  final Position? currentPosition;
  final Set<Marker> markers;

  const FacilityGoogleMapState({
    this.mapController,
    this.currentPosition,
    this.markers = const {},
  });

  FacilityGoogleMapState copyWith({
    GoogleMapController? mapController,
    Position? currentPosition,
    Set<Marker>? markers,
  }) {
    return FacilityGoogleMapState(
      mapController: mapController ?? this.mapController,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
    );
  }
}

class FacilityGoogleMapController
    extends StateNotifier<FacilityGoogleMapState> {
  final FacilityGoogleMapParams params;
  final LocationCacheService _locationCache = LocationCacheService.instance;

  FacilityGoogleMapController(this.params)
    : super(const FacilityGoogleMapState()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      // 1. 먼저 캐시된 위치 확인
      final cachedPosition = _locationCache.getCachedPosition();
      if (cachedPosition != null) {
        state = state.copyWith(currentPosition: cachedPosition);
        setupMarkers();
        return;
      }

      // 2. 캐시가 없으면 GPS로 위치 가져오기
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('位置情報の取得がタイムアウトしました');
            },
          );

      // 3. 위치 정보 캐싱
      _locationCache.cachePosition(position);
      state = state.copyWith(currentPosition: position);
      setupMarkers();
    } catch (e) {
      // 4. 실패 시 기본 위치 사용 (도쿄)
      state = state.copyWith(
        currentPosition: Position(
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
        ),
      );
      setupMarkers();
    }
  }

  /// 강제로 새로운 위치 가져오기 (캐시 무시)
  Future<void> forceRefreshLocation() async {
    _locationCache.invalidateCache();
    await getCurrentLocation();
  }

  void setupMarkers() {
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: MarkerId(params.facility.id),
        position: LatLng(
          getFacilityLatitude(params.facility),
          getFacilityLongitude(params.facility),
        ),
        infoWindow: InfoWindow(
          title: params.facility.name,
          snippet: params.facility.type == FacilityType.grooming
              ? 'トリミング'
              : '動物病院',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          params.facility.type == FacilityType.grooming
              ? BitmapDescriptor.hueViolet
              : BitmapDescriptor.hueRed,
        ),
      ),
    );

    if (params.nearbyFacilities != null) {
      for (final facility in params.nearbyFacilities!) {
        if (facility.id != params.facility.id) {
          markers.add(
            Marker(
              markerId: MarkerId(facility.id),
              position: LatLng(
                getFacilityLatitude(facility),
                getFacilityLongitude(facility),
              ),
              infoWindow: InfoWindow(
                title: facility.name,
                snippet: facility.type == FacilityType.grooming
                    ? 'トリミング'
                    : '動物病院',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                facility.type == FacilityType.grooming
                    ? BitmapDescriptor.hueViolet
                    : BitmapDescriptor.hueRed,
              ),
              onTap: () => params.onFacilityTap?.call(facility),
            ),
          );
        }
      }
    }

    if (state.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            state.currentPosition!.latitude,
            state.currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: '現在地', snippet: 'あなたの現在位置'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    state = state.copyWith(markers: markers);
  }

  double getFacilityLatitude(Facility facility) {
    return 35.6762 + (facility.id.hashCode % 100) * 0.001;
  }

  double getFacilityLongitude(Facility facility) {
    return 139.6503 + (facility.id.hashCode % 100) * 0.001;
  }

  void onMapCreated(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
    setupMarkers();
    moveToFacility();
  }

  void moveToFacility() {
    if (state.mapController != null) {
      state.mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              getFacilityLatitude(params.facility),
              getFacilityLongitude(params.facility),
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }
}

class FacilityGoogleMapWidget extends ConsumerWidget {
  final Facility facility;
  final List<Facility>? nearbyFacilities;
  final VoidCallback? onMapTap;
  final Function(Facility)? onFacilityTap;

  const FacilityGoogleMapWidget({
    super.key,
    required this.facility,
    this.nearbyFacilities,
    this.onMapTap,
    this.onFacilityTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = FacilityGoogleMapParams(
      facility: facility,
      nearbyFacilities: nearbyFacilities,
      onMapTap: onMapTap,
      onFacilityTap: onFacilityTap,
    );
    final controller = ref.read(facilityGoogleMapProvider(params).notifier);
    final state = ref.watch(facilityGoogleMapProvider(params));
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: state.currentPosition == null
            ? _buildLoadingState()
            : GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    controller.getFacilityLatitude(facility),
                    controller.getFacilityLongitude(facility),
                  ),
                  zoom: 15.0,
                ),
                markers: state.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onTap: (LatLng position) => onMapTap?.call(),
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
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('地図を読み込み中...'),
          ],
        ),
      ),
    );
  }
}
