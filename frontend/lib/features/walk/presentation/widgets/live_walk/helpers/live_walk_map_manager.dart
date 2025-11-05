import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import '../../../../../../shared/shared.dart';
import '../../../../../../../features/walk/domain/entities/walk_location_entity.dart';

/// Live Walk 지도 관리자
class LiveWalkMapManager {
  /// 마커 업데이트
  static Set<Marker> updateMarkers({
    required Position? currentPosition,
    required Position? startPosition,
    required List<WalkLocation> route,
  }) {
    final markers = <Marker>{};

    // 현재 위치 마커
    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '現在位置'),
        ),
      );
    }

    // 시작 위치 마커
    if (startPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('start_location'),
          position: LatLng(startPosition.latitude, startPosition.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'スタート'),
        ),
      );
    }

    return markers;
  }

  /// Polyline 업데이트
  static Set<Polyline> updatePolylines(List<WalkLocation> route) {
    if (route.length < 2) return {};

    final polylinePoints = route
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    return {
      Polyline(
        polylineId: const PolylineId('walk_route'),
        points: polylinePoints,
        color: AppColors.pointBlue,
        width: 4,
        geodesic: true,
      ),
    };
  }

  /// 지도 카메라를 현재 위치로 이동
  static Future<void> moveToCurrentPosition(
    GoogleMapController? mapController,
    Position? currentPosition,
  ) async {
    if (mapController != null && currentPosition != null) {
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition.latitude, currentPosition.longitude),
          17,
        ),
      );
    }
  }

  /// 지도 카메라를 경로 전체가 보이도록 조정
  static Future<void> fitRouteToBounds(
    GoogleMapController? mapController,
    List<WalkLocation> route,
  ) async {
    if (mapController == null || route.isEmpty) return;

    if (route.length == 1) {
      // 단일 포인트인 경우
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(route.first.latitude, route.first.longitude),
          15,
        ),
      );
      return;
    }

    // 경계 계산
    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (final location in route) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  /// 초기 카메라 위치 가져오기
  static CameraPosition getInitialCameraPosition(Position? currentPosition) {
    if (currentPosition != null) {
      return CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15,
      );
    } else {
      // 기본 위치 (도쿄)
      return const CameraPosition(target: LatLng(35.6762, 139.6503), zoom: 15);
    }
  }
}
