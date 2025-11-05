import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../features/walk/data/services/no_entry_zone_storage_service.dart';
import '../../../../../../features/walk/domain/entities/no_entry_zone_entity.dart';
import '../../../../../../features/walk/domain/entities/pet_info.dart';
import '../../../../../../features/walk/domain/entities/walk_location_entity.dart';
import '../../../../../../features/walk/domain/entities/walk_record_entity.dart';

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
    WalkPetInfo pet,
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
    WalkPetInfo? selectedPet,
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

        // 활동 마커들 추가
        final activities = _parseActivitiesFromNotes(walkRecord.notes);
        for (int j = 0; j < activities.length; j++) {
          final activity = activities[j];
          markers.add(
            buildActivityMarker(
              activity,
              walkRecord,
              '$i-activity-$j',
            ),
          );
        }
      }
    }

    // 선택된 펫 마커
    if (selectedPet != null && currentPosition != null) {
      markers.add(buildSelectedPetMarker(selectedPet, currentPosition));
    }

    return markers;
  }

  /// 활동 마커 생성
  static Marker buildActivityMarker(
    Map<String, dynamic> activity,
    WalkRecordEntity walkRecord,
    String markerId,
  ) {
    final latitude = activity['latitude'] as double? ?? 0.0;
    final longitude = activity['longitude'] as double? ?? 0.0;
    final activityType = activity['type'] as String? ?? 'unknown';

    final icon = _getActivityIcon(activityType);
    final title = _getActivityTitle(activityType);

    return Marker(
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: '${walkRecord.petName} - $title',
        snippet: '活動記録',
      ),
      icon: icon,
    );
  }

  /// 활동 타입에 따른 마커 아이콘 가져오기
  static BitmapDescriptor _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'poop':
        // 배변: 주황색
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'pee':
      case 'marking':
        // 배뇨: 파란색
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        );
      case 'no-entry':
        // 금지 구역: 빨간색
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        // 기타: 노란색
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  /// 활동 타입의 제목 가져오기
  static String _getActivityTitle(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'poop':
        return '💩 排便';
      case 'pee':
      case 'marking':
        return '💧 排尿';
      case 'no-entry':
        return '🚫 立入禁止';
      default:
        return '活動記録';
    }
  }

  /// notes 필드에서 활동 정보 파싱
  static List<Map<String, dynamic>> _parseActivitiesFromNotes(
    String? notes,
  ) {
    if (notes == null || notes.isEmpty) return [];

    try {
      // notes 형식: "activities:[{...}, {...}]"
      if (!notes.startsWith('activities:')) return [];

      final jsonStr = notes.substring('activities:'.length);
      final activities = <Map<String, dynamic>>[];

      // 정규표현식으로 각 활동 객체 추출 (더 유연한 패턴)
      final regex = RegExp(r'\{[^}]+\}');
      final matches = regex.allMatches(jsonStr);

      for (final match in matches) {
        final activityJson = match.group(0) ?? '';
        try {
          // 'type': 'poop', 'latitude': 37.7755, 'longitude': -122.4190 형식 파싱
          final typeMatch = RegExp(r"'type':\s*'([^']+)'").firstMatch(
            activityJson,
          );
          final latMatch = RegExp(
            r"'latitude':\s*([0-9.-]+)",
          ).firstMatch(activityJson);
          final lngMatch = RegExp(
            r"'longitude':\s*([0-9.-]+)",
          ).firstMatch(activityJson);

          if (typeMatch != null && latMatch != null && lngMatch != null) {
            final type = typeMatch.group(1) ?? 'unknown';
            final lat = double.tryParse(latMatch.group(1) ?? '0') ?? 0.0;
            final lng = double.tryParse(lngMatch.group(1) ?? '0') ?? 0.0;

            if (lat != 0 && lng != 0) {
              activities.add({
                'type': type,
                'latitude': lat,
                'longitude': lng,
              });
            }
          }
        } catch (e) {
          // 파싱 실패시 무시
          continue;
        }
      }

      return activities;
    } catch (e) {
      return [];
    }
  }

  /// 금지구역 마커 생성
  static Marker buildNoEntryZoneMarker(NoEntryZone zone, int index) {
    return Marker(
      markerId: MarkerId('no_entry_$index'),
      position: LatLng(zone.latitude, zone.longitude),
      infoWindow: InfoWindow(
        title: '🚫 立入禁止',
        snippet: '${zone.description ?? '金止区域'} (${zone.radiusMeters.toInt()}m)',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  /// 모든 금지구역 마커 로드 및 추가
  static Future<Set<Marker>> loadAndBuildNoEntryZoneMarkers(
    Set<Marker> existingMarkers,
  ) async {
    try {
      final zones = await NoEntryZoneStorageService.loadNoEntryZones();
      final markers = Set<Marker>.from(existingMarkers);

      for (int i = 0; i < zones.length; i++) {
        markers.add(buildNoEntryZoneMarker(zones[i], i));
      }

      return markers;
    } catch (e) {
      return existingMarkers;
    }
  }

  /// 유효한 위치인지 확인
  static bool _isValidLocation(WalkLocation location) {
    return location.latitude != 0 && location.longitude != 0;
  }
}
