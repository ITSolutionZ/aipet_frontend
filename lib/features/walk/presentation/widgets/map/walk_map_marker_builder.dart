import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/walk_providers.dart';
import '../../../domain/entities/walk_location_entity.dart';
import '../../../domain/entities/walk_record_entity.dart';

/// 산책 지도 마커 빌더 클래스
class WalkMapMarkerBuilder {
  WalkMapMarkerBuilder._();

  /// 현재 위치 마커 생성
  static Marker buildCurrentLocationMarker(Position position) {
    return Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(title: '現在地'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  /// 산책 시작점 마커 생성
  static Marker buildWalkStartMarker(WalkRecordEntity walkRecord, int index) {
    if (walkRecord.route.isEmpty) {
      throw ArgumentError('Walk record must have at least one location');
    }

    final startLocation = walkRecord.route.first;
    return Marker(
      markerId: MarkerId('walk_start_$index'),
      position: LatLng(startLocation.latitude, startLocation.longitude),
      infoWindow: InfoWindow(
        title: '${walkRecord.title} 開始',
        snippet: '${walkRecord.duration?.inMinutes ?? 0}分',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
  }

  /// 산책 종료점 마커 생성
  static Marker buildWalkEndMarker(WalkRecordEntity walkRecord, int index) {
    if (walkRecord.route.isEmpty) {
      throw ArgumentError('Walk record must have at least one location');
    }

    final endLocation = walkRecord.route.last;
    return Marker(
      markerId: MarkerId('walk_end_$index'),
      position: LatLng(endLocation.latitude, endLocation.longitude),
      infoWindow: InfoWindow(
        title: '${walkRecord.title} 終了',
        snippet: '${walkRecord.distance?.toStringAsFixed(1) ?? '0.0'}km',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  /// 선택된 펫 마커 생성
  static Marker buildSelectedPetMarker(
    PetInfo pet,
    Position currentPosition,
  ) {
    return Marker(
      markerId: const MarkerId('selected_pet'),
      position: LatLng(
        currentPosition.latitude + 0.001, // 약간 오프셋
        currentPosition.longitude + 0.001,
      ),
      infoWindow: InfoWindow(title: pet.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );
  }

  /// 모든 마커 생성
  static Set<Marker> buildAllMarkers({
    required List<WalkRecordEntity> walkRecords,
    Position? currentPosition,
    PetInfo? selectedPet,
  }) {
    final markers = <Marker>{};

    // 현재 위치 마커
    if (currentPosition != null) {
      markers.add(buildCurrentLocationMarker(currentPosition));
    }

    // 산책 기록 마커들
    for (int i = 0; i < walkRecords.length; i++) {
      final walkRecord = walkRecords[i];

      if (walkRecord.route.isNotEmpty) {
        // 시작점과 종료점이 유효한 좌표인지 확인
        if (_isValidLocation(walkRecord.route.first)) {
          markers.add(buildWalkStartMarker(walkRecord, i));
        }

        if (_isValidLocation(walkRecord.route.last)) {
          markers.add(buildWalkEndMarker(walkRecord, i));
        }
      }
    }

    // 선택된 펫 마커
    if (selectedPet != null && currentPosition != null) {
      markers.add(buildSelectedPetMarker(selectedPet, currentPosition));
    }

    return markers;
  }

  /// 유효한 위치인지 확인
  static bool _isValidLocation(WalkLocation location) {
    return location.latitude != 0 && location.longitude != 0;
  }
}