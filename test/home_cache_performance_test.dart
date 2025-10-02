import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 홈 화면 캐시 성능 테스트
///
/// 캐시가 없을 때와 있을 때의 성능 차이를 측정합니다.
void main() {
  group('홈 캐시 성능 테스트', () {
    late HomeRepositoryImpl repository;
    late CacheService cacheService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      repository = HomeRepositoryImpl();
      cacheService = CacheService();
    });

    tearDown(() async {
      try {
        await cacheService.clearAllCache();
      } catch (e) {
        debugPrint('캐시 정리 중 오류: $e');
      }
    });

    test('첫 번째 로딩 시간 측정', () async {
      final stopwatch = Stopwatch()..start();

      await repository.getDashboardData();

      stopwatch.stop();
      final firstLoadTime = stopwatch.elapsedMilliseconds;

      debugPrint('🕐 첫 번째 로딩 시간: ${firstLoadTime}ms');

      // 병렬 처리로 개선되어 250ms 정도 예상 (이전 1.25초에서 크게 개선)
      expect(firstLoadTime, greaterThan(200));
    });

    test('캐시된 두 번째 로딩 시간 측정', () async {
      // 첫 번째 로딩으로 캐시 생성
      await repository.getDashboardData();

      // 두 번째 로딩 시간 측정
      final stopwatch = Stopwatch()..start();

      await repository.getDashboardData();

      stopwatch.stop();
      final cachedLoadTime = stopwatch.elapsedMilliseconds;

      debugPrint('⚡ 캐시된 로딩 시간: ${cachedLoadTime}ms');

      // 캐시된 로딩은 100ms 미만으로 매우 빠를 것으로 예상
      expect(cachedLoadTime, lessThan(100));
    });

    test('성능 개선 비율 측정', () async {
      // 첫 번째 로딩 시간 측정
      final firstStopwatch = Stopwatch()..start();
      await repository.getDashboardData();
      firstStopwatch.stop();
      final firstLoadTime = firstStopwatch.elapsedMilliseconds;

      // 두 번째 로딩 시간 측정 (캐시 사용)
      final cachedStopwatch = Stopwatch()..start();
      await repository.getDashboardData();
      cachedStopwatch.stop();
      final cachedLoadTime = cachedStopwatch.elapsedMilliseconds;

      // 성능 개선 비율 계산
      final improvementRatio = firstLoadTime / cachedLoadTime;

      debugPrint('📊 성능 개선 비율: ${improvementRatio.toStringAsFixed(2)}x 빨라짐');
      debugPrint('📈 첫 번째: ${firstLoadTime}ms → 캐시된: ${cachedLoadTime}ms');

      // 최소 5배 이상 빨라져야 함
      expect(improvementRatio, greaterThan(5.0));
    });

    test('개별 API 캐시 성능 테스트', () async {
      // 날씨 API 캐시 테스트
      final weatherStopwatch1 = Stopwatch()..start();
      await repository.getCurrentWeather();
      weatherStopwatch1.stop();

      final weatherStopwatch2 = Stopwatch()..start();
      await repository.getCurrentWeather();
      weatherStopwatch2.stop();

      debugPrint('🌤️ 날씨 API: ${weatherStopwatch1.elapsedMilliseconds}ms → ${weatherStopwatch2.elapsedMilliseconds}ms');

      // 펫 요약 API 캐시 테스트
      final petStopwatch1 = Stopwatch()..start();
      await repository.getPetSummaries();
      petStopwatch1.stop();

      final petStopwatch2 = Stopwatch()..start();
      await repository.getPetSummaries();
      petStopwatch2.stop();

      debugPrint('🐕 펫 요약 API: ${petStopwatch1.elapsedMilliseconds}ms → ${petStopwatch2.elapsedMilliseconds}ms');

      // 캐시가 정상적으로 작동하는지 확인
      expect(weatherStopwatch2.elapsedMilliseconds, lessThan(weatherStopwatch1.elapsedMilliseconds));
      expect(petStopwatch2.elapsedMilliseconds, lessThan(petStopwatch1.elapsedMilliseconds));
    });

    test('병렬 로딩 성능 개선 테스트', () async {
      // 순차 로딩 시뮬레이션 (기존 방식)
      final sequentialStopwatch = Stopwatch()..start();
      await repository.getCurrentWeather();
      await repository.getPetSummaries();
      await repository.getWalkSummary();
      await repository.getPetHealthSummary();
      await repository.getUpcomingAppointments();
      sequentialStopwatch.stop();

      // 캐시 초기화
      await cacheService.clearAllCache();

      // 병렬 로딩 (개선된 방식)
      final parallelStopwatch = Stopwatch()..start();
      await repository.getDashboardData(); // 내부적으로 Future.wait 사용
      parallelStopwatch.stop();

      final sequentialTime = sequentialStopwatch.elapsedMilliseconds;
      final parallelTime = parallelStopwatch.elapsedMilliseconds;

      debugPrint('📊 순차 로딩: ${sequentialTime}ms');
      debugPrint('⚡ 병렬 로딩: ${parallelTime}ms');

      // 병렬 로딩이 더 빨라야 함
      expect(parallelTime, lessThan(sequentialTime));
    });
  });
}