import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/entities/walk_record_entity.dart';

/// 산책 지도 폴리라인 빌더 클래스
class WalkMapPolylineBuilder {
  WalkMapPolylineBuilder._();

  /// 단일 산책 기록의 폴리라인 생성
  static Polyline? buildWalkPolyline(
    WalkRecordEntity walkRecord,
    int index, {
    Color? color,
    int width = 3,
  }) {
    if (walkRecord.route.length < 2) return null;

    final points = walkRecord.route
        .where((point) => _isValidLocation(point))
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    if (points.length < 2) return null;

    return Polyline(
      polylineId: PolylineId('walk_route_$index'),
      points: points,
      color: color ?? _getDefaultPolylineColor(walkRecord.status),
      width: width,
      geodesic: true,
      patterns: _getPolylinePatterns(walkRecord.status),
    );
  }

  /// 모든 산책 기록의 폴리라인 생성
  static Set<Polyline> buildAllPolylines(
    List<WalkRecordEntity> walkRecords, {
    Color? defaultColor,
    int defaultWidth = 3,
  }) {
    final polylines = <Polyline>{};

    for (int i = 0; i < walkRecords.length; i++) {
      final polyline = buildWalkPolyline(
        walkRecords[i],
        i,
        color: defaultColor,
        width: defaultWidth,
      );

      if (polyline != null) {
        polylines.add(polyline);
      }
    }

    return polylines;
  }

  /// 실시간 추적 폴리라인 생성
  static Polyline? buildLiveTrackingPolyline(
    WalkRecordEntity? currentWalk, {
    Color color = Colors.blue,
    int width = 4,
  }) {
    if (currentWalk == null || currentWalk.route.length < 2) return null;

    final points = currentWalk.route
        .where((point) => _isValidLocation(point))
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    if (points.length < 2) return null;

    return Polyline(
      polylineId: const PolylineId('live_tracking'),
      points: points,
      color: color,
      width: width,
      geodesic: true,
      patterns: [PatternItem.dash(10), PatternItem.gap(5)], // 점선으로 표시
    );
  }

  /// 위치가 유효한지 확인
  static bool _isValidLocation(location) {
    return location.latitude != 0 && location.longitude != 0;
  }

  /// 산책 상태에 따른 기본 폴리라인 색상
  static Color _getDefaultPolylineColor(WalkStatus status) {
    switch (status) {
      case WalkStatus.inProgress:
        return Colors.blue;
      case WalkStatus.completed:
        return Colors.green;
      case WalkStatus.paused:
        return Colors.orange;
      case WalkStatus.cancelled:
        return Colors.red;
    }
  }

  /// 산책 상태에 따른 폴리라인 패턴
  static List<PatternItem> _getPolylinePatterns(WalkStatus status) {
    switch (status) {
      case WalkStatus.inProgress:
        return [PatternItem.dash(10), PatternItem.gap(5)]; // 점선
      case WalkStatus.paused:
        return [PatternItem.dash(5), PatternItem.gap(10)]; // 짧은 점선
      case WalkStatus.cancelled:
        return [PatternItem.dash(2), PatternItem.gap(8)]; // 매우 짧은 점선
      case WalkStatus.completed:
        return []; // 실선
    }
  }
}