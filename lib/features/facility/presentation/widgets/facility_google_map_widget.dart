import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

/// 시설 위치를 표시하는 Google Maps 위젯
class FacilityGoogleMapWidget extends StatefulWidget {
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
  State<FacilityGoogleMapWidget> createState() =>
      _FacilityGoogleMapWidgetState();
}

class _FacilityGoogleMapWidgetState extends State<FacilityGoogleMapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentPosition = position;
      });
      _setupMarkers();
    } catch (e) {
      // 위치 권한이 없거나 오류 발생 시 기본 위치 사용
      setState(() {
        _currentPosition = Position(
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
      });
      _setupMarkers();
    }
  }

  void _setupMarkers() {
    _markers.clear();

    // 메인 시설 마커
    _markers.add(
      Marker(
        markerId: MarkerId(widget.facility.id),
        position: LatLng(
          _getFacilityLatitude(widget.facility),
          _getFacilityLongitude(widget.facility),
        ),
        infoWindow: InfoWindow(
          title: widget.facility.name,
          snippet: widget.facility.type == FacilityType.grooming
              ? 'トリミング'
              : '動物病院',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.facility.type == FacilityType.grooming
              ? BitmapDescriptor.hueViolet
              : BitmapDescriptor.hueRed,
        ),
      ),
    );

    // 주변 시설 마커들
    if (widget.nearbyFacilities != null) {
      for (final facility in widget.nearbyFacilities!) {
        if (facility.id != widget.facility.id) {
          _markers.add(
            Marker(
              markerId: MarkerId(facility.id),
              position: LatLng(
                _getFacilityLatitude(facility),
                _getFacilityLongitude(facility),
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
              onTap: () => widget.onFacilityTap?.call(facility),
            ),
          );
        }
      }
    }

    // 현재 위치 마커
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: '現在地', snippet: 'あなたの現在位置'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  double _getFacilityLatitude(Facility facility) {
    // Mock 데이터에서 좌표 추출 (실제로는 facility.latitude 사용)
    // 현재는 주소 기반으로 가상 좌표 생성
    return 35.6762 + (facility.id.hashCode % 100) * 0.001;
  }

  double _getFacilityLongitude(Facility facility) {
    // Mock 데이터에서 좌표 추출 (실제로는 facility.longitude 사용)
    return 139.6503 + (facility.id.hashCode % 100) * 0.001;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setupMarkers();

    // 메인 시설로 카메라 이동
    _moveToFacility();
  }

  void _moveToFacility() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _getFacilityLatitude(widget.facility),
              _getFacilityLongitude(widget.facility),
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: _currentPosition == null
            ? _buildLoadingState()
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _getFacilityLatitude(widget.facility),
                    _getFacilityLongitude(widget.facility),
                  ),
                  zoom: 15.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onTap: (LatLng position) => widget.onMapTap?.call(),
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
