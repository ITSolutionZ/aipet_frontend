import 'package:aipet_frontend/features/walk/data/services/walk_route_service_impl.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalkRouteServiceImpl', () {
    late WalkRouteServiceImpl service;

    setUp(() {
      service = WalkRouteServiceImpl();
    });

    group('Google Maps Polyline 인코딩/디코딩', () {
      test('should encode and decode polyline correctly', () {
        // Arrange
        final locations = [
          WalkLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            timestamp: DateTime.now(),
          ),
          WalkLocation(
            latitude: 37.5666,
            longitude: 126.9781,
            timestamp: DateTime.now().add(const Duration(minutes: 1)),
          ),
          WalkLocation(
            latitude: 37.5667,
            longitude: 126.9782,
            timestamp: DateTime.now().add(const Duration(minutes: 2)),
          ),
        ];

        // Act
        final encoded = service.encodePolyline(locations);
        final decoded = service.decodePolyline(encoded);

        // Assert
        expect(encoded, isNotEmpty);
        expect(decoded.length, equals(locations.length));

        // 정밀도 검증 (소수점 5자리까지)
        for (int i = 0; i < locations.length; i++) {
          expect(decoded[i].latitude, closeTo(locations[i].latitude, 0.00001));
          expect(
            decoded[i].longitude,
            closeTo(locations[i].longitude, 0.00001),
          );
        }
      });

      test('should handle empty route', () {
        // Act
        final encoded = service.encodePolyline([]);
        final decoded = service.decodePolyline('');

        // Assert
        expect(encoded, isEmpty);
        expect(decoded, isEmpty);
      });

      test('should handle single location', () {
        // Arrange
        final locations = [
          WalkLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            timestamp: DateTime.now(),
          ),
        ];

        // Act
        final encoded = service.encodePolyline(locations);
        final decoded = service.decodePolyline(encoded);

        // Assert
        expect(encoded, isNotEmpty);
        expect(decoded.length, equals(1));
        expect(decoded[0].latitude, closeTo(locations[0].latitude, 0.00001));
        expect(decoded[0].longitude, closeTo(locations[0].longitude, 0.00001));
      });

      test('should handle negative coordinates', () {
        // Arrange
        final locations = [
          WalkLocation(
            latitude: -37.5665,
            longitude: -126.9780,
            timestamp: DateTime.now(),
          ),
          WalkLocation(
            latitude: -37.5666,
            longitude: -126.9781,
            timestamp: DateTime.now().add(const Duration(minutes: 1)),
          ),
        ];

        // Act
        final encoded = service.encodePolyline(locations);
        final decoded = service.decodePolyline(encoded);

        // Assert
        expect(encoded, isNotEmpty);
        expect(decoded.length, equals(locations.length));

        for (int i = 0; i < locations.length; i++) {
          expect(decoded[i].latitude, closeTo(locations[i].latitude, 0.00001));
          expect(
            decoded[i].longitude,
            closeTo(locations[i].longitude, 0.00001),
          );
        }
      });
    });

    group('경로 최적화', () {
      test('should optimize route by removing duplicate points', () {
        // Arrange
        final locations = [
          WalkLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            timestamp: DateTime.now(),
          ),
          WalkLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            timestamp: DateTime.now().add(const Duration(minutes: 1)),
          ), // 중복
          WalkLocation(
            latitude: 37.5666,
            longitude: 126.9781,
            timestamp: DateTime.now().add(const Duration(minutes: 2)),
          ),
        ];

        // Act
        final optimized = service.optimizeRoute(locations);

        // Assert
        expect(optimized.length, lessThan(locations.length));
        expect(optimized.first.latitude, equals(locations.first.latitude));
        expect(optimized.last.latitude, equals(locations.last.latitude));
      });
    });

    group('경로 스무딩', () {
      test('should smooth route using 3-point average', () {
        // Arrange
        final locations = [
          WalkLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            timestamp: DateTime.now(),
          ),
          WalkLocation(
            latitude: 37.5666,
            longitude: 126.9781,
            timestamp: DateTime.now().add(const Duration(minutes: 1)),
          ),
          WalkLocation(
            latitude: 37.5667,
            longitude: 126.9782,
            timestamp: DateTime.now().add(const Duration(minutes: 2)),
          ),
        ];

        // Act
        final smoothed = service.smoothRoute(locations);

        // Assert
        expect(smoothed.length, equals(locations.length));
        expect(smoothed.first.latitude, equals(locations.first.latitude));
        expect(smoothed.last.latitude, equals(locations.last.latitude));
      });
    });
  });
}
