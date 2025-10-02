import 'dart:convert';

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
  final LocationCacheService _locationCache = LocationCacheService.instance;
  BitmapDescriptor? _poopIcon;
  BitmapDescriptor? _peeIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
    _getCurrentLocation();
    _setupWalkDetailMap();
  }

  /// 커스텀 아이콘 로드
  Future<void> _loadCustomIcons() async {
    try {
      final poopIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/poop.png',
      );
      final peeIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/marking.png',
      );
      
      setState(() {
        _poopIcon = poopIcon;
        _peeIcon = peeIcon;
      });
      
      // 아이콘 로드 후 마커 다시 생성
      _setupWalkDetailMap();
      
      debugPrint('✅ WalkDetailMap: 커스텀 아이콘 로드 완료');
    } catch (e) {
      debugPrint('⚠️ WalkDetailMap: 커스텀 아이콘 로드 실패 - $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 1. 먼저 캐시된 위치 확인
      final cachedPosition = _locationCache.getCachedPosition();
      if (cachedPosition != null) {
        setState(() {
          _currentPosition = cachedPosition;
        });
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  cachedPosition.latitude,
                  cachedPosition.longitude,
                ),
                zoom: 16.0,
              ),
            ),
          );
        }
        return;
      }

      // 2. 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      // 3. 현재 위치 가져오기
      final Position position =
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

      // 4. 위치 정보 캐싱
      _locationCache.cachePosition(position);

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
      debugPrint('位置情報の取得に失敗: $e');
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
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

    // 이 산책 기록의 배변/배뇨 마커 추가
    _addActivityMarkers();
  }

  /// 이 산책 기록의 활동 마커 추가 (배변/배뇨)
  void _addActivityMarkers() {
    if (widget.walkRecord.notes == null) return;

    try {
      final notes = widget.walkRecord.notes!;

      // activities: 형식인지 확인
      if (!notes.contains('activities:')) {
        debugPrint(
          'ℹ️ WalkDetailMap: 이 산책(${widget.walkRecord.id})에는 활동 기록 없음',
        );
        return;
      }

      // activities JSON 추출
      String activitiesJsonStr;
      if (notes.startsWith('activities:')) {
        activitiesJsonStr = notes.substring('activities:'.length);
      } else {
        final parts = notes.split('activities:');
        if (parts.length < 2) return;
        activitiesJsonStr = parts[1];
      }

      // JSON 파싱
      final activities = jsonDecode(activitiesJsonStr) as List<dynamic>;

      debugPrint(
        '🔄 WalkDetailMap: 산책 기록 ${widget.walkRecord.id}의 활동 ${activities.length}개 파싱 시작',
      );

      // 각 활동을 마커로 추가
      for (int i = 0; i < activities.length; i++) {
        final activity = activities[i] as Map<String, dynamic>;
        final type = activity['type'] as String;
        final lat = (activity['latitude'] as num).toDouble();
        final lng = (activity['longitude'] as num).toDouble();
        final timestamp = activity['timestamp'] as String;

        // 커스텀 아이콘이 로드되었으면 사용, 아니면 기본 마커
        BitmapDescriptor markerIcon;
        if (type == 'poop' && _poopIcon != null) {
          markerIcon = _poopIcon!;
        } else if (type == 'pee' && _peeIcon != null) {
          markerIcon = _peeIcon!;
        } else {
          // 기본 마커
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            type == 'poop'
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueAzure,
          );
        }

        _markers.add(
          Marker(
            markerId: MarkerId('activity_${widget.walkRecord.id}_$i'),
            position: LatLng(lat, lng),
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: type == 'poop' ? '💩 排便' : '💧 排尿',
              snippet: timestamp.substring(11, 16), // HH:mm 형식
            ),
          ),
        );

        debugPrint('✅ 마커 추가: ${type == 'poop' ? '💩' : '💧'} at ($lat, $lng)');
      }

      setState(() {}); // UI 업데이트

      debugPrint(
        '✅ WalkDetailMap: 산책 ${widget.walkRecord.id}의 ${activities.length}개 활동 마커 추가 완료',
      );
    } catch (e) {
      debugPrint('⚠️ WalkDetailMap: 활동 마커 파싱 실패 - $e');
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
        infoWindow: const InfoWindow(title: '公園', snippet: '散歩開始点'),
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
        infoWindow: const InfoWindow(title: '家', snippet: '散歩終了点'),
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
            SizedBox(height: AppSpacing.md),
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
