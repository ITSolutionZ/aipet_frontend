import '../../shared/shared.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../features/home/data/repositories/home_repository_impl.dart';
import '../../../features/walk/data/services/local_walk_storage_service.dart';
import '../../app/services/ultra_fast_cache_service.dart';
import '../../shared/services/svg_cache_service.dart';

/// 프리로딩 서비스
///
/// 앱 시작 시 백그라운드에서 필요한 데이터를 미리 로딩하여
/// 사용자가 홈 화면에 진입했을 때 즉시 표시할 수 있도록 함
class PreloadService {
  static final PreloadService _instance = PreloadService._internal();
  factory PreloadService() => _instance;
  PreloadService._internal();

  final UltraFastCacheService _ultraFastCache = UltraFastCacheService();
  final HomeRepositoryImpl _homeRepository = HomeRepositoryImpl();

  bool _isPreloading = false;
  bool _preloadCompleted = false;

  /// 앱 시작 시 프리로딩 시작
  Future<void> startPreloading() async {
    if (_isPreloading || _preloadCompleted) return;

    _isPreloading = true;
    debugPrint('🚀 PreloadService: 앱 시작 프리로딩 시작');

    try {
      // 1. SVG 파일들 프리로딩 (최우선 - UI 렌더링 필요)
      unawaited(_preloadSvgFiles());

      // 2. 백그라운드에서 홈 데이터 프리로딩
      unawaited(_preloadHomeData());

      // 3. 산책 기록 로컬 데이터 프리로딩
      unawaited(_preloadWalkData());

      _preloadCompleted = true;
      debugPrint('✅ PreloadService: 프리로딩 완료');
    } catch (e) {
      debugPrint('❌ PreloadService: 프리로딩 실패 - $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// SVG 파일들 프리로딩
  Future<void> _preloadSvgFiles() async {
    try {
      debugPrint('🎨 PreloadService: SVG 파일들 캐싱 시작');
      final stopwatch = Stopwatch()..start();

      await SvgCacheService().preloadAllSvgs();

      stopwatch.stop();
      debugPrint(
        '✅ PreloadService: SVG 파일들 캐싱 완료 (${stopwatch.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      debugPrint('❌ PreloadService: SVG 파일들 캐싱 실패 - $e');
    }
  }

  /// 홈 데이터 프리로딩
  Future<void> _preloadHomeData() async {
    try {
      // 1. 기존 캐시가 있고 신선한지 확인
      final existingData = await _ultraFastCache.getUltraFastDashboard();
      if (existingData != null && _ultraFastCache.isDataFresh) {
        debugPrint('📱 PreloadService: 기존 캐시가 신선함 - 프리로딩 생략');
        return;
      }

      // 2. 새 데이터 로딩 (백그라운드)
      debugPrint('🔄 PreloadService: 홈 데이터 백그라운드 로딩');

      final stopwatch = Stopwatch()..start();
      await _homeRepository.getDashboardData();
      stopwatch.stop();

      debugPrint(
        '⚡ PreloadService: 홈 데이터 프리로딩 완료 (${stopwatch.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      debugPrint('❌ PreloadService: 홈 데이터 프리로딩 실패 - $e');
    }
  }

  /// 특정 기능 프리로딩 (필요시 확장)
  Future<void> preloadFeature(String featureName) async {
    debugPrint('🔄 PreloadService: $featureName 프리로딩 시작');

    switch (featureName) {
      case 'weather':
        await _preloadWeatherData();
        break;
      case 'pets':
        await _preloadPetData();
        break;
      default:
        debugPrint('⚠️ PreloadService: 알 수 없는 기능 - $featureName');
    }
  }

  /// 날씨 데이터 프리로딩
  Future<void> _preloadWeatherData() async {
    try {
      await _homeRepository.getCurrentWeather();
      debugPrint('✅ PreloadService: 날씨 데이터 프리로딩 완료');
    } catch (e) {
      debugPrint('❌ PreloadService: 날씨 데이터 프리로딩 실패 - $e');
    }
  }

  /// 펫 데이터 프리로딩
  Future<void> _preloadPetData() async {
    try {
      await _homeRepository.getPetSummaries();
      debugPrint('✅ PreloadService: 펫 데이터 프리로딩 완료');
    } catch (e) {
      debugPrint('❌ PreloadService: 펫 데이터 프리로딩 실패 - $e');
    }
  }

  /// 산책 기록 로컬 데이터 프리로딩
  Future<void> _preloadWalkData() async {
    try {
      final stopwatch = Stopwatch()..start();
      final walkRecords = await LocalWalkStorageService.loadWalkRecords();
      stopwatch.stop();

      debugPrint(
        '✅ PreloadService: 산책 기록 ${walkRecords.length}건 로드 완료 (${stopwatch.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      debugPrint('❌ PreloadService: 산책 기록 프리로딩 실패 - $e');
    }
  }

  /// 프리로딩 상태 확인
  bool get isPreloading => _isPreloading;
  bool get isPreloadCompleted => _preloadCompleted;

  /// 프리로딩 재설정 (개발용)
  void resetPreloadState() {
    _isPreloading = false;
    _preloadCompleted = false;
    debugPrint('🔄 PreloadService: 프리로딩 상태 리셋');
  }
}
