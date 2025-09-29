import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WalkDetailMapWidget extends ConsumerStatefulWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailMapWidget({super.key, required this.walkRecord});

  @override
  ConsumerState<WalkDetailMapWidget> createState() =>
      _WalkDetailMapWidgetState();
}

class _WalkDetailMapWidgetState extends ConsumerState<WalkDetailMapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupWalkDetailMap();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 권한 확인
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

      // 현재 위치 가져오기
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
      });

      // 지도 컨트롤러가 준비되면 카메라 이동
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
      // 기본 위치 사용 (도쿄 시나가와구)
      setState(() {
        _currentPosition = Position(
          latitude: 35.6092,
          longitude: 139.7301,
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
    }
  }

  void _setupWalkDetailMap() {
    _markers.clear();
    _polylines.clear();

    // 산책 경로가 있는 경우 실제 경로 사용
    if (widget.walkRecord.route.isNotEmpty) {
      _setupWalkRoute();
    } else {
      // 산책 경로가 없는 경우 샘플 경로 생성
      _setupSampleWalkRoute();
    }
  }

  void _setupWalkRoute() {
    final route = widget.walkRecord.route;
    if (route.length < 2) return;

    // 시작점 마커 (공원)
    if (route.first.latitude != 0 && route.first.longitude != 0) {
      _markers.add(
        Marker(
          markerId: const MarkerId('walk_start'),
          position: LatLng(route.first.latitude, route.first.longitude),
          infoWindow: InfoWindow(
            title: '${widget.walkRecord.title} 開始',
            snippet: '${widget.walkRecord.duration?.inMinutes ?? 0}分',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // 종료점 마커 (집)
    if (route.last.latitude != 0 && route.last.longitude != 0) {
      _markers.add(
        Marker(
          markerId: const MarkerId('walk_end'),
          position: LatLng(route.last.latitude, route.last.longitude),
          infoWindow: InfoWindow(
            title: '${widget.walkRecord.title} 終了',
            snippet:
                '${widget.walkRecord.distance?.toStringAsFixed(1) ?? '0.0'}km',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // 경로 폴리라인
    if (route.length > 1) {
      final points = route
          .where((point) => point.latitude != 0 && point.longitude != 0)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      if (points.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('walk_route'),
            points: points,
            color: AppColors.pointBrown,
            width: 4,
            geodesic: true,
          ),
        );
      }
    }
  }

  void _setupSampleWalkRoute() {
    // 샘플 경로 생성 (도쿄 시나가와구 근처)
    const baseLat = 35.6092;
    const baseLng = 139.7301;

    // 공원 (시작점)
    const parkLat = baseLat + 0.002;
    const parkLng = baseLng - 0.001;

    // 병원 (중간점)
    const hospitalLat = baseLat + 0.001;
    const hospitalLng = baseLng + 0.002;

    // 집 (종료점)
    const homeLat = baseLat - 0.001;
    const homeLng = baseLng + 0.001;

    // 마커 추가
    _markers.add(
      Marker(
        markerId: const MarkerId('park'),
        position: const LatLng(parkLat, parkLng),
        infoWindow: const InfoWindow(title: '공원', snippet: '산책 시작점'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('hospital'),
        position: const LatLng(hospitalLat, hospitalLng),
        infoWindow: const InfoWindow(title: '병원', snippet: '중간 경유지'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('home'),
        position: const LatLng(homeLat, homeLng),
        infoWindow: const InfoWindow(title: '집', snippet: '산책 종료점'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // 샘플 경로 폴리라인
    _polylines.add(
      const Polyline(
        polylineId: PolylineId('sample_route'),
        points: [
          LatLng(parkLat, parkLng),
          LatLng(hospitalLat, hospitalLng),
          LatLng(homeLat, homeLng),
        ],
        color: AppColors.pointBrown,
        width: 4,
        geodesic: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: _currentPosition == null
            ? _buildLoadingState()
            : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _setupWalkDetailMap();

                  // 초기 카메라 위치 설정
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 16.0,
                      ),
                    ),
                  );
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 16.0,
                ),
                markers: _markers,
                polylines: _polylines,
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

  @override
  void didUpdateWidget(WalkDetailMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.walkRecord != widget.walkRecord) {
      _setupWalkDetailMap();
    }
  }
}
