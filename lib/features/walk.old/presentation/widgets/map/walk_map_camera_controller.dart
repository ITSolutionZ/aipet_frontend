import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 산책 지도 카메라 컨트롤러 클래스
class WalkMapCameraController {
  WalkMapCameraController._();

  /// 현재 위치로 카메라 이동
  static Future<void> moveToCurrentLocation(
    GoogleMapController mapController,
    Position position, {
    double zoom = 15.0,
  }) async {
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  /// 산책 경로 전체가 보이도록 카메라 조정
  static Future<void> fitWalkRoute(
    GoogleMapController mapController,
    WalkRecordEntity walkRecord, {
    double padding = 100.0,
  }) async {
    if (walkRecord.route.length < 2) return;

    final validPoints = walkRecord.route
        .where((point) => point.latitude != 0 && point.longitude != 0)
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    if (validPoints.length < 2) return;

    final bounds = _calculateBounds(validPoints);
    await mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  /// 여러 산책 경로가 모두 보이도록 카메라 조정
  static Future<void> fitAllWalkRoutes(
    GoogleMapController mapController,
    List<WalkRecordEntity> walkRecords, {
    double padding = 100.0,
  }) async {
    final allPoints = <LatLng>[];

    for (final walkRecord in walkRecords) {
      final validPoints = walkRecord.route
          .where((point) => point.latitude != 0 && point.longitude != 0)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      allPoints.addAll(validPoints);
    }

    if (allPoints.length < 2) return;

    final bounds = _calculateBounds(allPoints);
    await mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  /// 실시간 추적 모드 카메라 설정
  static Future<void> followCurrentWalk(
    GoogleMapController mapController,
    WalkRecordEntity currentWalk, {
    double zoom = 18.0,
  }) async {
    if (currentWalk.route.isEmpty) return;

    final lastLocation = currentWalk.route.last;
    if (lastLocation.latitude == 0 && lastLocation.longitude == 0) return;

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lastLocation.latitude, lastLocation.longitude),
          zoom: zoom,
          bearing: lastLocation.heading ?? 0.0,
          tilt: 30.0, // 약간의 기울임으로 3D 효과
        ),
      ),
    );
  }

  /// 지도 줌 레벨 조정
  static Future<void> zoomToLevel(
    GoogleMapController mapController,
    double zoomLevel,
  ) async {
    await mapController.animateCamera(CameraUpdate.zoomTo(zoomLevel));
  }

  /// 특정 위치로 부드럽게 이동
  static Future<void> panToLocation(
    GoogleMapController mapController,
    double latitude,
    double longitude,
  ) async {
    await mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(latitude, longitude)),
    );
  }

  /// 경계 박스 계산
  static LatLngBounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// 기본 카메라 위치 생성
  static CameraPosition createDefaultCameraPosition({
    double latitude = 35.6762, // 도쿄 기본 위치
    double longitude = 139.6503,
    double zoom = 10.0,
  }) {
    return CameraPosition(target: LatLng(latitude, longitude), zoom: zoom);
  }
}
