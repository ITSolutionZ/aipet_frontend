import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/shared.dart';
import '../../data/walk_providers.dart';
import '../../domain/entities/walk_record_entity.dart';
import 'map/walk_map_camera_controller.dart';
import 'map/walk_map_marker_builder.dart';
import 'map/walk_map_polyline_builder.dart';

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
        await WalkMapCameraController.moveToCurrentLocation(
          _mapController!,
          position,
        );
      }
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
    }
  }

  void _setupMarkersAndPolylines() {
    // 마커 생성
    _markers.clear();
    _markers.addAll(WalkMapMarkerBuilder.buildAllMarkers(
      walkRecords: widget.walkRecords,
      currentPosition: _currentPosition,
      selectedPet: widget.selectedPet,
    ));

    // 폴리라인 생성
    _polylines.clear();
    _polylines.addAll(WalkMapPolylineBuilder.buildAllPolylines(
      widget.walkRecords,
      defaultColor: AppColors.pointBrown,
    ));
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
                  WalkMapCameraController.moveToCurrentLocation(
                    controller,
                    _currentPosition!,
                  );
                },
                initialCameraPosition:
                    WalkMapCameraController.createDefaultCameraPosition(
                  latitude: _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude,
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
