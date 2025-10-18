import 'package:flutter/foundation.dart';

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';

/// 산책 목업 데이터 생성기
class MockWalkDataGenerator {
  /// 목업 산책 기록 생성 (테스트용)
  static List<WalkRecordEntity> generateMockWalkRecords() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 산책 1: 완료된 산책 (경로 포함) - 오늘 오전 10시
    final walk1Route = _generateMockRoute(
      startLat: 37.7749,
      startLng: -122.4194,
      pointCount: 15,
      distanceKm: 2.5,
    );

    final walk1 = WalkRecordEntity(
      id: 'walk_001',
      petId: 'pet1',
      petName: 'マックス',
      startTime: today.add(const Duration(hours: 10)),
      endTime: today.add(const Duration(hours: 10, minutes: 30)),
      duration: const Duration(minutes: 30),
      distance: 2.5,
      route: walk1Route,
      notes: _generateMockActivities([
        {'type': 'poop', 'lat': 37.7755, 'lng': -122.4190},
        {'type': 'marking', 'lat': 37.7760, 'lng': -122.4185},
      ]),
      status: WalkStatus.completed,
      createdAt: today.add(const Duration(hours: 10)),
      updatedAt: today.add(const Duration(hours: 10, minutes: 30)),
    );

    // 산책 2: 진행 중인 산책 - 오늘 오후 2시
    final walk2Route = _generateMockRoute(
      startLat: 37.7749,
      startLng: -122.4194,
      pointCount: 8,
      distanceKm: 1.2,
    );

    final walk2 = WalkRecordEntity(
      id: 'walk_002',
      petId: 'pet1',
      petName: 'マックス',
      startTime: today.add(const Duration(hours: 14)),
      endTime: null,
      duration: null,
      distance: 1.2,
      route: walk2Route,
      notes: _generateMockActivities([
        {'type': 'poop', 'lat': 37.7752, 'lng': -122.4192},
      ]),
      status: WalkStatus.inProgress,
      createdAt: today.add(const Duration(hours: 14)),
      updatedAt: now,
    );

    // 산책 3: 일시정지된 산책 - 오늘 오후 4시
    final walk3Route = _generateMockRoute(
      startLat: 37.7749,
      startLng: -122.4194,
      pointCount: 12,
      distanceKm: 1.8,
    );

    final walk3 = WalkRecordEntity(
      id: 'walk_003',
      petId: 'pet2',
      petName: 'ベラ',
      startTime: today.add(const Duration(hours: 16)),
      endTime: null,
      duration: const Duration(minutes: 25),
      distance: 1.8,
      route: walk3Route,
      notes: _generateMockActivities([
        {'type': 'marking', 'lat': 37.7758, 'lng': -122.4188},
        {'type': 'poop', 'lat': 37.7762, 'lng': -122.4183},
        {'type': 'marking', 'lat': 37.7756, 'lng': -122.4191},
      ]),
      status: WalkStatus.paused,
      createdAt: today.add(const Duration(hours: 16)),
      updatedAt: today.add(const Duration(hours: 16, minutes: 25)),
    );

    // 산책 4: 취소된 산책 - 어제
    final walk4Route = _generateMockRoute(
      startLat: 37.7749,
      startLng: -122.4194,
      pointCount: 5,
      distanceKm: 0.8,
    );

    final yesterday = today.subtract(const Duration(days: 1));
    final walk4 = WalkRecordEntity(
      id: 'walk_004',
      petId: 'pet1',
      petName: 'マックス',
      startTime: yesterday.add(const Duration(hours: 10)),
      endTime: yesterday.add(const Duration(hours: 10, minutes: 15)),
      duration: const Duration(minutes: 15),
      distance: 0.8,
      route: walk4Route,
      notes: null,
      status: WalkStatus.cancelled,
      createdAt: yesterday.add(const Duration(hours: 10)),
      updatedAt: yesterday.add(const Duration(hours: 10, minutes: 15)),
    );

    return [walk1, walk2, walk3, walk4];
  }

  /// 금지구역 목업 데이터 생성
  static String generateMockNoEntryZones() {
    final now = DateTime.now();
    final zones = [
      {
        'id': 'zone_001',
        'latitude': 37.7750,
        'longitude': -122.4195,
        'radiusMeters': 5.0,
        'description': '工事中の建設現場',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 'zone_002',
        'latitude': 37.7765,
        'longitude': -122.4180,
        'radiusMeters': 5.0,
        'description': '犬が苦手な家',
        'createdAt': now.toIso8601String(),
      },
    ];
    return zones.toString();
  }

  /// 경로 생성 (선형 보간)
  static List<WalkLocation> _generateMockRoute({
    required double startLat,
    required double startLng,
    required int pointCount,
    required double distanceKm,
  }) {
    final route = <WalkLocation>[];
    final latChange = 0.01;
    final lngChange = 0.015;

    final now = DateTime.now();

    for (int i = 0; i < pointCount; i++) {
      final progress = i / (pointCount - 1);
      final lat = startLat + (latChange * progress);
      final lng = startLng + (lngChange * progress);

      route.add(
        WalkLocation(
          latitude: lat,
          longitude: lng,
          timestamp: now.subtract(Duration(seconds: (pointCount - i) * 10)),
          altitude: 10.0 + (i * 0.5),
          accuracy: 5.0,
          speed: 1.2,
          heading: 45.0,
        ),
      );
    }

    return route;
  }

  /// 활동 정보를 notes 형식으로 변환
  static String? _generateMockActivities(List<Map<String, dynamic>> activities) {
    if (activities.isEmpty) return null;

    final activitiesJson = activities.map((a) {
      return {
        'type': a['type'],
        'latitude': a['lat'],
        'longitude': a['lng'],
        'timestamp': DateTime.now().toIso8601String(),
      };
    }).toList();

    return 'activities:$activitiesJson';
  }

  /// 목업 데이터 초기화 (테스트 후 삭제)
  static Future<void> initializeMockData() async {
    // 나중에 사용할 초기화 로직
    debugPrint('🚀 목업 데이터 초기화 완료');
  }

  /// 목록 모의 데이터 삭제
  static Future<void> clearMockData() async {
    debugPrint('🗑️  목업 데이터 삭제 완료');
  }
}
