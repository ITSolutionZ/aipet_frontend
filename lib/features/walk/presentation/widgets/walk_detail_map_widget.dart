import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_marker_builder.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/map/walk_map_polyline_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 산책 상세 지도 위젯
class WalkDetailMapWidget extends StatefulWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailMapWidget({super.key, required this.walkRecord});

  @override
  State<WalkDetailMapWidget> createState() => _WalkDetailMapWidgetState();
}

class _WalkDetailMapWidgetState extends State<WalkDetailMapWidget> {
  late GoogleMapController mapController;
  late Set<Polyline> polylines;
  late Set<Marker> markers;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Polyline 생성
    polylines = WalkMapPolylineBuilder.buildAllPolylines(
      [widget.walkRecord],
    );

    // 마커 생성 (시작점, 종료점, 활동 마커)
    markers = WalkMapMarkerBuilder.buildAllMarkers(
      walkRecords: [widget.walkRecord],
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.walkRecord.route.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'ルート情報がありません',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final startLocation = widget.walkRecord.route.first;
    final initialCamera = CameraPosition(
      target: LatLng(startLocation.latitude, startLocation.longitude),
      zoom: 15,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          // 초기 지도 카메라 설정
          _fitMapToRoute();
        },
        initialCameraPosition: initialCamera,
        polylines: polylines,
        markers: markers,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }

  /// 산책 경로를 모두 보이도록 지도 카메라 조정
  Future<void> _fitMapToRoute() async {
    if (widget.walkRecord.route.isEmpty) return;

    try {
      // 경로의 모든 포인트를 포함하는 바운드 계산
      double minLat = widget.walkRecord.route.first.latitude;
      double maxLat = widget.walkRecord.route.first.latitude;
      double minLng = widget.walkRecord.route.first.longitude;
      double maxLng = widget.walkRecord.route.first.longitude;

      for (final location in widget.walkRecord.route) {
        minLat = minLat > location.latitude ? location.latitude : minLat;
        maxLat = maxLat < location.latitude ? location.latitude : maxLat;
        minLng = minLng > location.longitude ? location.longitude : minLng;
        maxLng = maxLng < location.longitude ? location.longitude : maxLng;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
      await mapController.animateCamera(cameraUpdate);
    } catch (e) {
      debugPrint('지도 카메라 조정 실패: $e');
    }
  }
}
