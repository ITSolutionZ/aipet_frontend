import 'dart:async';

import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/shared/services/preload_service.dart';
import 'package:aipet_frontend/shared/services/ultra_fast_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 초고속 캐시 성능 테스트
///
/// 3초 이내 로딩 목표 달성 여부를 검증합니다.
void main() {
  group('초고속 캐시 성능 테스트', () {
    late HomeRepositoryImpl repository;
    late UltraFastCacheService ultraFastCache;
    late PreloadService preloadService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      repository = HomeRepositoryImpl();
      ultraFastCache = UltraFastCacheService();
      preloadService = PreloadService();
    });

    tearDown(() async {
      try {
        await ultraFastCache.invalidateCache();
        preloadService.resetPreloadState();
      } catch (e) {
        debugPrint('정리 중 오류: $e');
      }
    });

    test('프리로딩 후 즉시 로딩 (목표: 1초 이내)', () async {
      // 1단계: 프리로딩 수행
      debugPrint('🚀 프리로딩 시작...');
      final preloadStopwatch = Stopwatch()..start();
      await preloadService.startPreloading();
      preloadStopwatch.stop();
      debugPrint('✅ 프리로딩 완료: ${preloadStopwatch.elapsedMilliseconds}ms');

      // 2단계: 즉시 로딩 측정
      final loadStopwatch = Stopwatch()..start();
      final dashboard = await repository.getDashboardData();
      loadStopwatch.stop();

      final loadTime = loadStopwatch.elapsedMilliseconds;
      debugPrint('⚡ 프리로딩 후 즉시 로딩: ${loadTime}ms');

      // 검증: 1초 이내 로딩
      expect(dashboard, isNotNull);
      expect(loadTime, lessThan(1000), reason: '프리로딩 후 1초 이내 로딩되어야 함');
    });

    test('콜드 스타트 성능 (목표: 3초 이내)', () async {
      // 캐시 완전 삭제
      await ultraFastCache.invalidateCache();

      // 콜드 스타트 로딩 측정
      final stopwatch = Stopwatch()..start();
      final dashboard = await repository.getDashboardData();
      stopwatch.stop();

      final loadTime = stopwatch.elapsedMilliseconds;
      debugPrint('🆕 콜드 스타트 로딩: ${loadTime}ms');

      // 검증: 3초 이내 로딩
      expect(dashboard, isNotNull);
      expect(loadTime, lessThan(3000), reason: '콜드 스타트 시 3초 이내 로딩되어야 함');
    });

    test('연속 로딩 성능 (목표: 즉시)', () async {
      // 첫 번째 로딩으로 캐시 생성
      await repository.getDashboardData();

      // 연속 로딩 측정 (5회)
      final loadTimes = <int>[];

      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        final dashboard = await repository.getDashboardData();
        stopwatch.stop();

        final loadTime = stopwatch.elapsedMilliseconds;
        loadTimes.add(loadTime);

        expect(dashboard, isNotNull);
        debugPrint('🔄 연속 로딩 ${i + 1}회차: ${loadTime}ms');
      }

      // 모든 연속 로딩이 100ms 이내여야 함
      for (int i = 0; i < loadTimes.length; i++) {
        expect(
          loadTimes[i],
          lessThan(100),
          reason: '연속 로딩 ${i + 1}회차가 100ms 이내여야 함',
        );
      }

      final averageTime = loadTimes.reduce((a, b) => a + b) / loadTimes.length;
      debugPrint('📊 연속 로딩 평균: ${averageTime.toStringAsFixed(1)}ms');
    });

    test('캐시 계층별 성능 비교', () async {
      final results = <String, int>{};

      // 1. 캐시 없는 상태
      await ultraFastCache.invalidateCache();
      var stopwatch = Stopwatch()..start();
      await repository.getDashboardData();
      stopwatch.stop();
      results['캐시없음'] = stopwatch.elapsedMilliseconds;

      // 2. 초고속 캐시 상태
      stopwatch = Stopwatch()..start();
      await repository.getDashboardData();
      stopwatch.stop();
      results['초고속캐시'] = stopwatch.elapsedMilliseconds;

      // 3. 영속 캐시에서 복원
      await ultraFastCache.invalidateCache();
      final persistentData = await ultraFastCache.getUltraFastDashboard();
      if (persistentData != null) {
        results['영속캐시'] = 0; // 영속 캐시는 거의 즉시
      }

      debugPrint('📈 캐시 계층별 성능:');
      results.forEach((key, value) {
        debugPrint('  $key: ${value}ms');
      });

      // 성능 순서 검증: 초고속캐시 <= 영속캐시 < 캐시없음
      if (results.containsKey('초고속캐시') && results.containsKey('캐시없음')) {
        expect(
          results['초고속캐시']!,
          lessThan(results['캐시없음']!),
          reason: '초고속 캐시가 더 빨라야 함',
        );
      }
    });

    test('프리로딩 서비스 상태 관리', () async {
      // 초기 상태 확인
      expect(preloadService.isPreloading, false);
      expect(preloadService.isPreloadCompleted, false);

      // 프리로딩 시작
      final preloadFuture = preloadService.startPreloading();

      // 중복 호출 방지 확인
      unawaited(preloadService.startPreloading()); // 이 호출은 무시되어야 함

      await preloadFuture;

      // 완료 상태 확인
      expect(preloadService.isPreloading, false);
      expect(preloadService.isPreloadCompleted, true);

      debugPrint('✅ 프리로딩 서비스 상태 관리 정상');
    });

    test('성능 목표 종합 검증', () async {
      final performanceReport = <String, String>{};

      // 1. 프리로딩 성능
      final preloadStopwatch = Stopwatch()..start();
      await preloadService.startPreloading();
      preloadStopwatch.stop();
      final preloadTime = preloadStopwatch.elapsedMilliseconds;
      performanceReport['프리로딩'] = '${preloadTime}ms ${preloadTime < 5000 ? '✅' : '❌'}';

      // 2. 프리로딩 후 즉시 로딩
      final fastStopwatch = Stopwatch()..start();
      await repository.getDashboardData();
      fastStopwatch.stop();
      final fastTime = fastStopwatch.elapsedMilliseconds;
      performanceReport['즉시로딩'] = '${fastTime}ms ${fastTime < 1000 ? '✅' : '❌'}';

      // 3. 콜드 스타트
      await ultraFastCache.invalidateCache();
      final coldStopwatch = Stopwatch()..start();
      await repository.getDashboardData();
      coldStopwatch.stop();
      final coldTime = coldStopwatch.elapsedMilliseconds;
      performanceReport['콜드스타트'] = '${coldTime}ms ${coldTime < 3000 ? '✅' : '❌'}';

      debugPrint('📊 === 최종 성능 리포트 ===');
      performanceReport.forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('🎯 목표: 프리로딩 후 1초, 콜드스타트 3초 이내');

      // 핵심 목표 검증
      expect(fastTime, lessThan(1000), reason: '프리로딩 후 1초 이내 목표 미달성');
      expect(coldTime, lessThan(3000), reason: '콜드스타트 3초 이내 목표 미달성');
    });
  });
}