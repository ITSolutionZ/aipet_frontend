import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/shared.dart';
import '../../data/walk_providers.dart';
import '../../domain/entities/walk_record_entity.dart';

class MapWidget extends StatefulWidget {
  final List<WalkRecordEntity> walkRecords;
  final PetInfo? selectedPet;

  const MapWidget({super.key, required this.walkRecords, this.selectedPet});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupMarkersAndPolylines();
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
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
    }
  }

  void _setupMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    // 현재 위치 마커 추가
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: '現在地'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // 산책 기록에서 마커와 경로 추가
    for (int i = 0; i < widget.walkRecords.length; i++) {
      final walkRecord = widget.walkRecords[i];
      if (walkRecord.route.isNotEmpty) {
        // 시작점 마커
        if (walkRecord.route.first.latitude != 0 &&
            walkRecord.route.first.longitude != 0) {
          _markers.add(
            Marker(
              markerId: MarkerId('walk_start_$i'),
              position: LatLng(
                walkRecord.route.first.latitude,
                walkRecord.route.first.longitude,
              ),
              infoWindow: InfoWindow(
                title: '${walkRecord.title} 開始',
                snippet: '${walkRecord.duration?.inMinutes ?? 0}分',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );
        }

        // 종료점 마커
        if (walkRecord.route.last.latitude != 0 &&
            walkRecord.route.last.longitude != 0) {
          _markers.add(
            Marker(
              markerId: MarkerId('walk_end_$i'),
              position: LatLng(
                walkRecord.route.last.latitude,
                walkRecord.route.last.longitude,
              ),
              infoWindow: InfoWindow(
                title: '${walkRecord.title} 終了',
                snippet:
                    '${walkRecord.distance?.toStringAsFixed(1) ?? '0.0'}km',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );
        }

        // 경로 폴리라인 추가
        if (walkRecord.route.length > 1) {
          final points = walkRecord.route
              .where((point) => point.latitude != 0 && point.longitude != 0)
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          if (points.length > 1) {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('walk_route_$i'),
                points: points,
                color: AppColors.pointBrown,
                width: 3,
                geodesic: true,
              ),
            );
          }
        }
      }
    }

    // 선택된 펫 마커 추가 (현재 위치 근처)
    if (widget.selectedPet != null && _currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_pet'),
          position: LatLng(
            _currentPosition!.latitude + 0.001, // 약간 오프셋
            _currentPosition!.longitude + 0.001,
          ),
          infoWindow: InfoWindow(title: widget.selectedPet!.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    }
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
                  _setupMarkersAndPolylines();

                  // 초기 카메라 위치 설정
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 15.0,
                      ),
                    ),
                  );
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 15.0,
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
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.walkRecords != widget.walkRecords ||
        oldWidget.selectedPet != widget.selectedPet) {
      _setupMarkersAndPolylines();
    }
  }
}
